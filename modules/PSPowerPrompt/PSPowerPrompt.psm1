Set-StrictMode -Version Latest

$script:Session = $null
$script:Config = $null
$script:SessionVariables = [ordered]@{}

function Get-PPConfig {
    $configPath = Join-Path $HOME '.ps-powerprompt\config\settings.json'
    if (-not (Test-Path $configPath)) {
        throw "No se encontro la configuracion de PS-PowerPrompt en $configPath"
    }

    if (-not $script:Config) {
