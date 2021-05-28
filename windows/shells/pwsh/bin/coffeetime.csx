#!/usr/bin/env dotnet-script

// depends on: dotnet tool install -g dotnet-script
// ref:
//  https://github.com/filipw/dotnet-script
//  https://www.hanselman.com/blog/c-and-net-core-scripting-with-the-dotnetscript-global-tool
//  https://github.com/dotnet/command-line-api
//  https://github.com/dotnet/command-line-api/blob/main/docs/Your-first-app-with-System-CommandLine.md
//  https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate
//  https://stackoverflow.com/questions/10776027/check-whether-user-is-inactive

#r "nuget: System.CommandLine, 2.0.0-beta1.21216.1"

using System;
using System.CommandLine;
using System.CommandLine.Invocation;
using System.IO;
using System.Runtime.InteropServices;

//
// Console Parameter Handling
//
int timeAwake;
int delayBeforeSleep;
bool setAwake;
bool setPreventDisplaySleep;
bool sleepAfterAwake;
bool useHibernation;

var rootCommand = new RootCommand
{
    new Option<int>(
        new [] {"--t", "--time-awake"}, // first letter of each parameter must be the same
        getDefaultValue: () => 600,
        description: "How long should the system be kept awake (in minutes)?"),
    new Option<int>(
        new [] {"--d", "--delay-before-sleep"},
        getDefaultValue: () => 10,
        description: "How long after 'awake time' ends should the system force sleep (in minutes)?"),
    new Option<bool>(
        new [] {"--a", "--awake"},
        description: "Set system to stay awake (display can still sleep)"),
    new Option<bool>(
        new [] {"--p", "--prevent-display-sleep"},
        getDefaultValue: () => true,
        description: "Set system to stay awake AND keep the display from sleeping"),
    new Option<bool>(
        new [] {"--s", "--sleep-after-wake-time"},
        getDefaultValue: () => true,
        description: "Should the system attempt to sleep automatically after the 'wake time' is complete?"),
    new Option<bool>(
        new [] {"--u", "--use-hibernation"},
        getDefaultValue: () => true,
        description: "Should the system use hibernation as the sleep method after the 'awake time' is complete?")
};

rootCommand.Description = "CoffeeTime";

// Note that the parameters of the handler method are matched according to the names of the options
rootCommand.Handler = CommandHandler.Create<int, int, bool, bool, bool, bool>((t, d, a, p, s, u) =>
{
    Console.WriteLine("CoffeeTime is using the following parameters:");
    Console.WriteLine("");
    Console.WriteLine($"  [--t, --time-awake (minutes)]: {t}");
    Console.WriteLine($"  [--d, --delay-before-sleep (minutes)]: {d}");
    Console.WriteLine($"  [--a, --awake]: {a}");
    Console.WriteLine($"  [--p, --prevent-display-sleep]: {p} (also keeps system awake)");
    Console.WriteLine($"  [--s, --sleep-after-wake-time]: {s}");
    Console.WriteLine($"  [--u, --use-hibernation]: {u}");

    timeAwake = t;
    delayBeforeSleep = d;
    setAwake = a;
    setPreventDisplaySleep = p;
    sleepAfterAwake = s;
    useHibernation = u;
});

//
// Awake/Sleep Manager
//

public static class AwakeManager
{
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
    private static extern EXECUTION_STATE SetThreadExecutionState(EXECUTION_STATE esFlags);

    [FlagsAttribute]
    private enum EXECUTION_STATE :uint
    {
        ES_AWAYMODE_REQUIRED = 0x00000040,
        ES_CONTINUOUS = 0x80000000,
        ES_DISPLAY_REQUIRED = 0x00000002,
        ES_SYSTEM_REQUIRED = 0x00000001,
        ES_USER_PRESENT = 0x00000004 // NOT SUPPORTED ANY LONGER
    }

    public static void SetSystemAwakeState()
    {
        var execStateToSet = EXECUTION_STATE.ES_CONTINUOUS | EXECUTION_STATE.ES_AWAYMODE_REQUIRED | EXECUTION_STATE.ES_SYSTEM_REQUIRED;
        var lastExecState = SetThreadExecutionState(execStateToSet);

        if (lastExecState != execStateToSet)
        {
            Console.WriteLine($"[INFO: SetSystemAwakeState] Thread execution state was set to {execStateToSet}");
            Console.WriteLine($"[INFO: SetSystemAwakeState] Prior thread execution state was: {lastExecState}");
        }
    }

    public static void SetPreventDisplaySleepState()
    {
        var execStateToSet = EXECUTION_STATE.ES_CONTINUOUS | EXECUTION_STATE.ES_DISPLAY_REQUIRED | EXECUTION_STATE.ES_SYSTEM_REQUIRED;
        var lastExecState = SetThreadExecutionState(execStateToSet);

        if (lastExecState != execStateToSet)
        {
            Console.WriteLine($"[INFO: SetPreventDisplaySleepState] Thread execution state was set to {execStateToSet}");
            Console.WriteLine($"[INFO: SetPreventDisplaySleepState] Prior thread execution state was: {lastExecState}");
        }
    }

    public static void ClearState()
    {
        var execStateToSet = EXECUTION_STATE.ES_CONTINUOUS;
        var lastExecState = SetThreadExecutionState(EXECUTION_STATE.ES_CONTINUOUS);

        Console.WriteLine($"[INFO: ClearState] Thread execution state was set to {execStateToSet}");
        Console.WriteLine($"[INFO: ClearState] Prior thread execution state was: {lastExecState}");
    }
}

public static class SleepManager
{
    [DllImport("PowrProf.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
    private static extern bool SetSuspendState(bool hibernate, bool forceCritical, bool disableWakeEvent);

    public static void HibernateSystem()
    {
        Console.WriteLine("[INFO] System is hibernating...");
        SetSuspendState(true, true, false);
    }

    public static void SleepSystem()
    {
        Console.WriteLine("[INFO] System is going to sleep...");
        SetSuspendState(false, true, false);
    }
}

public static class UserState
{
    [StructLayout(LayoutKind.Sequential)]
    private struct LASTINPUTINFO
    {
        public uint cbSize;
        public uint dwTime;
    }

    [DllImport("user32.dll")]
    private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    public static bool UserIsActive
    {
        get
        {
            LASTINPUTINFO info = new LASTINPUTINFO();
            info.cbSize = (uint)Marshal.SizeOf(info);
            if (GetLastInputInfo(ref info))
            {
                var lastInput = TimeSpan.FromMilliseconds(Environment.TickCount - info.dwTime);

                if (lastInput.TotalMinutes < 5)
                {
                    return true;
                }
            }

            return false;
        }

    }
}

public static void ConsoleCancelHandler(object sender, ConsoleCancelEventArgs args)
{
    Console.WriteLine("[INFO] Shutdown has been requested, clearing state and exiting");
    AwakeManager.ClearState();
    Environment.Exit(0);
}

//
// 'main'
//
var ignored = rootCommand.InvokeAsync(Args.ToArray()).Result;
Console.WriteLine("");

// setup control+c handling:
Console.CancelKeyPress += new ConsoleCancelEventHandler(ConsoleCancelHandler);

if (timeAwake > 0)
{
    var endTime = DateTime.Now.AddMinutes(timeAwake);
    Console.WriteLine($"[INFO] CoffeeTime will be over at: {endTime.ToShortTimeString()}");

    if (setAwake)
    {
        AwakeManager.SetSystemAwakeState();
    }
    else
    {
        AwakeManager.SetPreventDisplaySleepState();
    }

    while (DateTime.Now < endTime)
    {
        var timeLeft = (endTime - DateTime.Now).TotalMinutes;
        Console.Title = $"CoffeeTime ends in: {(int)timeLeft}min";
        System.Threading.Thread.Sleep(5000);
    }

    // clear state:
    AwakeManager.ClearState();

    if (sleepAfterAwake)
    {
        // do not sleep/hibernate if the user is currently active:
        if (UserState.UserIsActive)
        {
            Console.WriteLine("[INFO] A user is currently active, skipping sleep");
        }
        else if (delayBeforeSleep > 0)
        {
            endTime = DateTime.Now.AddMinutes(delayBeforeSleep);
            Console.WriteLine($"[INFO] System will sleep at: {endTime.ToShortTimeString()}");

            while (DateTime.Now < endTime)
            {
                var timeLeft = (endTime - DateTime.Now).TotalMinutes;
                Console.Title = $"CoffeeTime sleeps in: {(int)timeLeft}min";
                System.Threading.Thread.Sleep(5000);
            }

            if (useHibernation)
            {
                SleepManager.HibernateSystem();
            }
            else
            {
                SleepManager.SleepSystem();
            }
        }
    }
}
