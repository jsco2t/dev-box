param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $GateWayIpAddress, # ex: "192.168.1.255"

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $TargetMacAddress, # ex: "B4:B6:86:37:5A:C4"

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]
    $TargetIpAddress, # ex: "192.168.1.31"

    [Parameter(Mandatory = $false)]
    [Switch]
    $Wait
)

$MacByteArray = $TargetMacAddress -split "[:-]" | ForEach-Object { [Byte] "0x$_"}

[Byte[]] $MagicPacket = (,0xFF * 6) + ($MacByteArray  * 16)

$UdpClient = New-Object System.Net.Sockets.UdpClient

$UdpClient.Connect(($GateWayIpAddress), 7)

$ignore = $UdpClient.Send($MagicPacket, $MagicPacket.Length)

$UdpClient.Close()

if ($Wait.IsPresent) {
    if ([string]::IsNullOrEmpty($TargetIpAddress)) {
        Write-Host "Wait was requested but target ip address is not present"
    } else {
        $progressPreference = 'silentlyContinue'
        $connectionTestResult = $(Test-NetConnection -ComputerName $TargetIpAddress -InformationLevel Quiet -WarningAction SilentlyContinue) 

        for ($i = 0; $i -lt 12; $i++) {
            
            if ($true -eq $connectionTestResult) {
                Write-Host "Target machine is online"
                break
            } else {
                Write-Host "Target machine is not online yet, waiting 10 seconds and trying again..."
                Sleep 10
                
                $connectionTestResult = $(Test-NetConnection -ComputerName $TargetIpAddress -InformationLevel Quiet -WarningAction SilentlyContinue) 
                $ProgressPreference = "Continue"
            }
        }
    }
}