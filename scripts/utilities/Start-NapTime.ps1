param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(2, 1440)]
    [int]
    $DurationBeforeNapping = 30,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Sleep", "Hibernate")]
    [string]
    $SleepMode = "Hibernate"
)


$endTime = [DateTime]::Now.AddMinutes($DurationBeforeNapping)

function Get-TimeRemainingMinutes() {
    $currentTime = [DateTime]::Now
    $timeRemaining = $endTime - $currentTime;
    return [int]$timeRemaining.TotalMinutes
}

function Set-WindowTitle() {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $title
    )

    if ($true -eq $UpdateWindowTitle) {
        (Get-Host).ui.RawUI.WindowTitle = $title
    }
}

try {
    for ($i = 0; $i -lt $DurationBeforeNapping; $i++) {
        $timeRemaining = Get-TimeRemainingMinutes

        # log/update status
        Write-Host "$(Get-Date -Format u): System will nap in $timeRemaining minutes"
        Set-WindowTitle "Nap starts in: $($timeRemaining)min"

        Start-Sleep 60
    }

    if (0 -le $(Get-TimeRemainingMinutes)) {
        Write-Host "Starting a nap with: $SleepMode"
        if ($SleepMode -eq 'Sleep') {
            Start-Process "$env:windir\System32\rundll32.exe"  -ArgumentList @("powrprof.dll","SetSuspendState Standby")
        } else {
            Start-Process "$env:windir\System32\rundll32.exe"  -ArgumentList @("powrprof.dll","SetSuspendState Hibernate")
        }
    }
    
} finally {
    Write-Host "exiting"
}