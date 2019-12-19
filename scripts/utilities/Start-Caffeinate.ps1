param($keepAwakeDurationMinutes = 60)

$shell = New-Object -com "Wscript.Shell"

for ($i = 0; $i -lt $keepAwakeDurationMinutes; $i++) {
    Start-Sleep 60
    Write-Host "Sending keep-awake signal:`t$(Get-Date -Format u)"
    $shell.sendKeys("{F15}")
}