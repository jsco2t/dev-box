
#
# Prompt configuration
#
Import-Module '/Users/jason/.local/share/powershell/Modules/posh-git/1.0.0/posh-git.psd1'
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'
#$GitPromptSettings.DefaultPromptPath.ForegroundColor = 'DarkCyan'
$GitPromptSettings.DefaultPromptPath.ForegroundColor = $GitPromptSettings.BranchColor.ForegroundColor

# current sytle used in terminal doesn't work well with some PS colors - adjust them here:
Set-PSReadLineOption -Colors @{
    "Operator" = [ConsoleColor]::Gray
    "Parameter" = [ConsoleColor]::Green
}

# use posh-git's prompt all the time:
function prompt {
    # Your non-prompt logic here

    # Have posh-git display its default prompt
    & $GitPromptScriptBlock
}

#
# Colorize the output
#

Import-Module Get-ChildItemColor

Function List-AllPwsh {
    if ($args[0] -ne $null -and $args[0] -eq '-la') {
        Get-ChildItem -Force $args[1..$args.Length]
    } else {
        Get-ChildItem $args
    }
}

Set-Alias ls List-AllPwsh -option AllScope

Function List-AllBash {
    bash -c 'ls -la'
}
Set-Alias ll List-AllBash -option AllScope
Set-Alias l List-AllBash -option AllScope

#
# Customize the window title
#

# using posh-git here again because we are using it's prompt infra all the time
$global:ConsoleWindowTitle = ""
function Set-Title {
    param(
        [Parameter(Mandatory = $true)]
        $Title
    )

    $global:ConsoleWindowTitle = $Title

    # basically a customized version of what posh-git uses by default - which can be found by running: $GitPromptSettings
    $GitPromptSettings.WindowTitle = { 
        param($GitStatus, [bool]$IsAdmin) "$(if ($IsAdmin) {'Admin: '})$(if ($GitStatus) {"$($GitStatus.RepoName) [$($GitStatus.Branch)$(if ($GitStatus.HasWorking -or $GitStatus.AheadBy -ne 0) { '*' })]"} else {Get-PromptPath}) - $($global:ConsoleWindowTitle)"
    }
}
Set-Title "" #"[$PID]"