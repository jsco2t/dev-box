param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [int]
    $SleepDurationMinutes = 120,

    [Parameter(Mandatory = $true)]
    [ValidateSet("SystemPreventSleepAndLock", "SystemPreventLock", "SystemPreventSleep", "KeyInput")]
    [string]
    $PreventionMode

)

$SleepManagerMethodDefinition = @'
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
static extern EXECUTION_STATE SetThreadExecutionState(EXECUTION_STATE esFlags);

[FlagsAttribute]
public enum EXECUTION_STATE :uint
{
    ES_AWAYMODE_REQUIRED = 0x00000040,
    ES_CONTINUOUS = 0x80000000,
    ES_DISPLAY_REQUIRED = 0x00000002,
    ES_SYSTEM_REQUIRED = 0x00000001
}

//
// SetExecutionState code
//
public static void PreventSleepAndLock()
{
    Console.WriteLine("Setting Sleep Manager Thread Execution State: Prevent Sleep and Lock");
    SetThreadExecutionState(EXECUTION_STATE.ES_CONTINUOUS | EXECUTION_STATE.ES_AWAYMODE_REQUIRED | EXECUTION_STATE.ES_DISPLAY_REQUIRED);
}

public static void PreventSleep()
{
    Console.WriteLine("Setting Sleep Manager Thread Execution State: Prevent Sleep");
    SetThreadExecutionState(EXECUTION_STATE.ES_CONTINUOUS | EXECUTION_STATE.ES_AWAYMODE_REQUIRED);
}

public static void PreventLock()
{
    Console.WriteLine("Setting Sleep Manager Thread Execution State: Prevent Lock");
    SetThreadExecutionState(EXECUTION_STATE.ES_CONTINUOUS | EXECUTION_STATE.ES_DISPLAY_REQUIRED);
}

public static void ClearThreadExecutionState()
{
    Console.WriteLine("Clearing Sleep Manager Thread Execution State");
    SetThreadExecutionState(EXECUTION_STATE.ES_CONTINUOUS);
}

'@

if ($PreventionMode -eq "KeyInput") {
    $shell = New-Object -com "Wscript.Shell"

    for ($i = 0; $i -lt $SleepDurationMinutes; $i++) {
        Start-Sleep 60
        Write-Host "Sending keep-awake signal:`t$(Get-Date -Format u)"
        $shell.sendKeys("{F15}")
        #$shell.sendKeys("{NUMLOCK}{NUMLOCK}")
        #$shell.sendKeys("^") # contrl
    }
} else {

    try {
        $SleepManager = Add-Type -MemberDefinition $SleepManagerMethodDefinition -Name 'SleepManager' -Namespace 'Win32' -PassThru

        if ($PreventionMode -eq "SystemPreventSleepAndLock") {

            [Win32.SleepManager]::PreventSleepAndLock()

        } elseif ($PreventionMode -eq "SystemPreventLock") {

            [Win32.SleepManager]::PreventLock()
        
        } else {

            [Win32.SleepManager]::PreventSleep()

        }

        for ($i = 0; $i -lt $SleepDurationMinutes; $i++) {
            Write-Host "Coffee Mode [$($PreventionMode)] running:`t$(Get-Date -Format u)"

            Start-Sleep 60
        }

        [Win32.SleepManager]::ClearThreadExecutionState();
    }
    finally {
        if ($null -ne $SleepManager) {
            [Win32.SleepManager]::ClearThreadExecutionState();
        }
        Write-Host "exiting"
    }

}


