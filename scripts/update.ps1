[CmdletBinding()]
param(
    [string]$Branch = 'main'
)

$ErrorActionPreference = 'Stop'
$repo = 'ingllinasramirez/PS-PowerPrompt'
$installRoot = Join-Path $HOME '.ps-powerprompt'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("ps-powerprompt-update-" + [guid]::NewGuid().ToString('N'))
$zipPath = Join-Path $tempRoot 'source.zip'
$extractPath = Join-Path $tempRoot 'source'
$backupRoot = Join-Path $installRoot ('backups\update-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))

try {
    Write-Host '[PS-PowerPrompt] Buscando la version mas reciente...' -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $tempRoot, $extractPath, $backupRoot -Force | Out-Null

    $downloadUrl = "https://codeload.github.com/$repo/zip/refs/heads/$Branch"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

    $sourceRoot = Get-ChildItem -LiteralPath $extractPath -Directory | Select-Object -First 1
    if (-not $sourceRoot) {
        throw 'No fue posible localizar el contenido descargado.'
    }

    $testScript = Join-Path $sourceRoot.FullName 'scripts\Test-PSPowerPrompt.ps1'
    if (Test-Path -LiteralPath $testScript -PathType Leaf) {
        & $testScript -ProjectRoot $sourceRoot.FullName
        if ($LASTEXITCODE -ne 0) {
            throw 'La version descargada no supero las pruebas automaticas.'
        }
    }

    foreach ($folder in @('modules','scripts','ui','assets')) {
        $installedFolder = Join-Path $installRoot $folder
        if (Test-Path -LiteralPath $installedFolder) {
            Copy-Item -LiteralPath $installedFolder -Destination $backupRoot -Recurse -Force
        }
    }

    foreach ($folder in @('modules','scripts','ui','assets')) {
        $sourceFolder = Join-Path $sourceRoot.FullName $folder
        $targetFolder = Join-Path $installRoot $folder
        if (Test-Path -LiteralPath $sourceFolder -PathType Container) {
            if (-not (Test-Path -LiteralPath $targetFolder)) {
                New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
            }
            Copy-Item -Path (Join-Path $sourceFolder '*') -Destination $targetFolder -Recurse -Force
        }
    }

    $manifest = Join-Path $installRoot 'modules\PSPowerPrompt\PSPowerPrompt.psd1'
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        throw 'La actualizacion no dejo disponible el manifiesto del modulo.'
    }

    Import-Module $manifest -Force
    $version = (Test-ModuleManifest -Path $manifest).Version

    Write-Host "PS-PowerPrompt actualizado correctamente a la version $version." -ForegroundColor Green
    Write-Host "Respaldo: $backupRoot" -ForegroundColor DarkGray
    Write-Host 'Ejecuta pp-restart o abre una terminal nueva para aplicar todos los cambios.' -ForegroundColor Yellow
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
