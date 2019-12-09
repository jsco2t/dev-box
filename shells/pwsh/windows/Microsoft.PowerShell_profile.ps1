Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox
Import-Module Get-ChildItemColor # install with: Install-Module -AllowClobber Get-ChildItemColor

# custom functionality for directory color
Set-Alias lw Get-ChildItemColorFormatWide -option AllScope

# getting SSH to work with GIT:
#  - Keys need to be in a folder named .ssh under home directory
#
#  - Make sure the following service is started:
#	 Name: ssh-agent
#        DisplayName: OpenSSH Authentication Agent
#
# Set the following environmental variable:      
$env:GIT_SSH="C:\WINDOWS\System32\OpenSSH\ssh.exe"
#
#  - One time, run: ssh-add
#	When asked: provide passphrase for key
