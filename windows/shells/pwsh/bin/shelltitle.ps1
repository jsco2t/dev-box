param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $title
)

$ThemeSettings.Options.ConsoleTitle = $false # requires version 2.0.4+ of oh-my-posh
(Get-Host).ui.RawUI.WindowTitle = $title