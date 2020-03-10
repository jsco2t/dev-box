Import-Module posh-git # can be installed with Install-Module, also need: Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Import-Module oh-my-posh # can be installed with Install-Module
Set-Theme Paradox
Import-Module Get-ChildItemColor # install with: Install-Module -AllowClobber Get-ChildItemColor

# custom functionality for directory color
Set-Alias lw Get-ChildItemColorFormatWide -option AllScope

# getting SSH to work with GIT:
#  - Keys need to be in a folder named .ssh under home directory
#
#  - Make sure the following service is started:
#   Name: ssh-agent
#        DisplayName: OpenSSH Authentication Agent
#
# Set the following environmental variable:
$env:GIT_SSH="C:\WINDOWS\System32\OpenSSH\ssh.exe"
#
#  - One time, run: ssh-add
#   When asked: provide passphrase for key

#
# Environment
#
$env:HOME = $env:USERPROFILE
$env:REQUESTS_CA_BUNDLE = "C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\Lib\site-packages\certifi\cacert.pem"

#
# Helper Functions
#
function Start-MM() {
    docker run -it --rm --name micro-manage 680054776144.dkr.ecr.us-east-1.amazonaws.com/defi-apps-micro-manage:master-latest
}

function Set-ShellTitle() {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $title
    )
    $ThemeSettings.Options.ConsoleTitle = $false
    (Get-Host).ui.RawUI.WindowTitle = $title
}
