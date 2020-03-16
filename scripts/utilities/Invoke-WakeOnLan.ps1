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
    $Wait = $true
)

#
# Variables
#

#
# Helper methods
#

function Invoke-WOL() {
    $MacByteArray = $TargetMacAddress -split "[:-]" | ForEach-Object { [Byte] "0x$_"}

    [Byte[]] $MagicPacket = (,0xFF * 6) + ($MacByteArray  * 16)

    $UdpClient = New-Object System.Net.Sockets.UdpClient

    $UdpClient.Connect(($GateWayIpAddress), 7)

    $ignore = $UdpClient.Send($MagicPacket, $MagicPacket.Length)

    $UdpClient.Close()
}

function Test-TargetIsOnline() {
    $ProgressPreference = 'SilentlyContinue'
    $result = Test-NetConnection -ComputerName $TargetIpAddress -InformationLevel Quiet -WarningAction SilentlyContinue
    $ProgressPreference = 'Continue'

    return $result
}

function Write-TargetIsOnlineResult() {
    $result = Test-TargetIsOnline
    Write-Host "Target IP Address: $TargetIpAddress is currently online: $result"
}

function Get-IpAddressFromMacAddress() {
    $formattedMacAddress = $TargetMacAddress

    if ($formattedMacAddress.Contains(":")) {
        $formattedMacAddress = $formattedMacAddress.Replace(":", "-")
    }

    $ipAddress = ""

    try {
        #$ipAddress = $(arp -a | select-string $formattedMacAddress |% { $_.ToString().Trim().Split(" ")[0] })
        $ipAddress = $(Get-NetNeighbor -LinkLayerAddress "$formattedMacAddress").IPAddress

        if (![string]::IsNullOrWhitespace($ipAddress)) {
            Write-Host "Target IP Address was found from Mac Address: $ipAddress"
        } else {
            Write-Warning "Target IP Address was not found for Mac Address: $formattedMacAddress"
        }
    } catch {
        Write-Error "Failed getting IP Address for Mac Address"
    }

    return $ipAddress
}

function Set-TargetIpAddressIfNotPresent() {
    if ([string]::IsNullOrWhitespace($TargetIpAddress)) {
        $ipForMacAddress = Get-IpAddressFromMacAddress
        Set-Variable -Name "TargetIpAddress" -Value "$ipForMacAddress" -scope 1 -Force #1 == parent scope
    }
}

function Wait-ForTargetOnline() {
    if ($Wait.IsPresent) {
        if ([string]::IsNullOrWhitespace($TargetIpAddress)) {
            Write-Error "Wait was requested but target ip address is not present"
            exit -1
        } else {
            $connectionTestResult = Test-TargetIsOnline
    
            for ($i = 0; $i -lt 12; $i++) {
                
                if ($true -eq $connectionTestResult) {
                    Write-Host "Target machine is online"
                    break
                } else {
                    Write-Host "Target machine is not online yet, waiting 10 seconds and trying again..."
                    Sleep 10
                    
                    $connectionTestResult = Test-TargetIsOnline
                }
            }
        }
    }
}

#
# Do Stuff
#
Invoke-WOL
Set-TargetIpAddressIfNotPresent
Write-TargetIsOnlineResult
Wait-ForTargetOnline


