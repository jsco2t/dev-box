Import-Module posh-git # can be installed with Install-Module, also need: Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Import-Module oh-my-posh # can be installed with Install-Module
Set-Theme Paradox
Import-Module Get-ChildItemColor # install with: Install-Module -AllowClobber Get-ChildItemColor

# custom functionality for directory color
Set-Alias lw Get-ChildItemColorFormatWide -option AllScope

# customize colors of theme to work better with iterm colors:
$ThemeSettings.Colors.PromptForegroundColor = [ConsoleColor]::Black