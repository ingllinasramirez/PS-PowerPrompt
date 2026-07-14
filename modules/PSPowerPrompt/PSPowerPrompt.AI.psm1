Set-StrictMode -Version Latest

function Get-PPAIConfigPath {
    Join-Path $HOME '.ps-powerprompt\config\settings.json'
}

function Get-PPAIConfig {
    $path = Get-PPAIConfigPath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "No se encontro la configuracion de PS-PowerPrompt en $path"
    }

    Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
}