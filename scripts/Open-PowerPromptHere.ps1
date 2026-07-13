[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$Path = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    throw "La carpeta no existe: $Path"
}

Set-Location -LiteralPath $Path

$panelEnabled = $false
$configPath = Join-Path $HOME '.ps-powerprompt\config\settings.json'
if (Test-Path $configPath) {
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        $panelEnabled = [bool]$config.ui.launchPanelWithContextMenu
    } catch {}
}

if ($panelEnabled) {
    $panel = Join-Path $HOME '.ps-powerprompt\ui\PowerPrompt.Panel.ps1'
    if (Test-Path $panel) {
        Start-Process pwsh -ArgumentList @('-NoLogo','-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',"`"$panel`"")
    }
}

Write-Host "PowerPrompt iniciado en: $Path" -ForegroundColor Cyan