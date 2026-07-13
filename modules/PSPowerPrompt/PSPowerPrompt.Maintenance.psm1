Set-StrictMode -Version Latest

function Get-PPInstallRoot {
    Join-Path $HOME '.ps-powerprompt'
}

function Invoke-PPUpdate {
    [CmdletBinding()]
    param()

    $scriptPath = Join-Path (Get-PPInstallRoot) 'scripts\update.ps1'
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        throw "No se encontro el actualizador en: $scriptPath"
    }

    & $scriptPath
}

function Invoke-PPUninstall {
    [CmdletBinding