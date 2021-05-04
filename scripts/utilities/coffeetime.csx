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

// public static void Main(string inputOne, string inputTwo)
// {
//     Console.WriteLine("hi");
// }

var rootCommand = new RootCommand
{
    new Option<int>(
        "--int-option",
        getDefaultValue: () => 42,
        description: "An option whose argument is parsed as an int"),
    new Option<bool>(
        "--bool-option",
        "An option whose argument is parsed as a bool"),
    new Option<FileInfo>(
        "--file-option",
        "An option whose argument is parsed as a FileInfo")
};

rootCommand.Description = "My sample app";

// Note that the parameters of the handler method are matched according to the names of the options
rootCommand.Handler = CommandHandler.Create<int, bool, FileInfo>((intOption, boolOption, fileOption) =>
{
    Console.WriteLine($"The value for --int-option is: {intOption}");
    Console.WriteLine($"The value for --bool-option is: {boolOption}");
    Console.WriteLine($"The value for --file-option is: {fileOption?.FullName ?? "null"}");
});

// [DllImport("user32.dll")]
// static extern IntPtr GetForegroundWindow();

// [DllImport("user32.dll")]
// static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);

// private string GetActiveWindowTitle()
// {
//     const int nChars = 256;
//     StringBuilder Buff = new StringBuilder(nChars);
//     IntPtr handle = GetForegroundWindow();

//     if (GetWindowText(handle, Buff, nChars) > 0)
//     {
//         return Buff.ToString();
//     }
//     return null;
// }

[DllImport("kernel32.dll", CharSet = CharSet.Unicode,
        CallingConvention = CallingConvention.StdCall)]
//[DllImport("libkernel32.dll", CharSet = CharSet.Unicode)]
static extern EXECUTION_STATE SetThreadExecutionState(EXECUTION_STATE esFlags);

[FlagsAttribute]
public enum EXECUTION_STATE :uint
{
    ES_AWAYMODE_REQUIRED = 0x00000040,
    ES_CONTINUOUS = 0x80000000,
    ES_DISPLAY_REQUIRED = 0x00000002,
    ES_SYSTEM_REQUIRED = 0x00000001,
    ES_USER_PRESENT = 0x00000004 // NOT SUPPORTED ANY LONGER
}

Console.Title = "Hello";

var execStateToSet = EXECUTION_STATE.ES_CONTINUOUS;
var lastExecState = SetThreadExecutionState(execStateToSet);

Console.WriteLine(lastExecState);

//Console.WriteLine(GetActiveWindowTitle());


// Parse the incoming args and invoke the handler
return rootCommand.InvokeAsync(Args.ToArray()).Result;

