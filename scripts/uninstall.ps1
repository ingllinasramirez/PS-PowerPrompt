[CmdletBinding()]
param(
    [switch]$RemoveData,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$installRoot = Join-Path $HOME '.ps-powerprompt'

function Remove-ProfileBootstrap {
    param([string]$ProfilePath)

    if (-not (Test-Path -LiteralPath $ProfilePath -PathType Leaf)) { return }

    $content = Get-Content -LiteralPath $ProfilePath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { return }

    $start = '# >>> PS-PowerPrompt >>>'
    $end = '# <<< PS-PowerPrompt <<<'
    $pattern = '(?s)' + [regex]::Escape($start) + '.*?' + [regex]::Escape($end)
    $cleaned = [regex]::Replace($content, $pattern, '').TrimEnd()

    if ($cleaned -ne $content) {
        $backup = "$ProfilePath.backup-uninstall-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $ProfilePath -Destination $backup -Force
        Set-Content -LiteralPath $ProfilePath -Value $cleaned -Encoding utf8
        Write-Host "Perfil restaurado: $ProfilePath" -ForegroundColor Green
    }
}

if (-not $Force) {
    $message = if ($RemoveData) {
        'Se eliminaran PowerPrompt, su configuracion y las carpetas de sesiones/exportaciones configuradas. Continuar? [s/N]'
    } else {
        'Se eliminara PowerPrompt, pero se conservaran la configuracion y los datos de sesiones/exportaciones. Continuar? [s/N]'
    }

    $answer = Read-Host $message
    if ($answer.Trim().ToLowerInvariant() -notin @('s','si','sí','y','yes')) {
        Write-Host 'Desinstalacion cancelada.' -ForegroundColor Yellow
        exit 0
    }
}

$configPath = Join-Path $installRoot 'config\settings.json'
$config = $null
if (Test-Path -LiteralPath $configPath -PathType Leaf) {
    try { $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json } catch {}
}

try {
    try { Stop-Transcript | Out-Null } catch {}

    Remove-ProfileBootstrap -ProfilePath $PROFILE.CurrentUserAllHosts
    Remove-ProfileBootstrap -ProfilePath $PROFILE.CurrentUserCurrentHost

    foreach ($key in @(
        'HKCU:\Software\Classes\Directory\Background\shell\PSPowerPrompt',
        'HKCU:\Software\Classes\Directory\shell\PSPowerPrompt'
    )) {
        if (Test-Path $key) {
            Remove-Item -Path $key -Recurse -Force
        }
    }

    if ($RemoveData) {
        if ($config) {
            foreach ($configuredPath in @($config.paths.sessions, $config.paths.exports)) {
                if ($configuredPath) {
                    $expanded = [Environment]::ExpandEnvironmentVariables([string]$configuredPath)
                    if (Test-Path -LiteralPath $expanded) {
                        Remove-Item -LiteralPath $expanded -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            }
        }

        if (Test-Path -LiteralPath $installRoot) {
            Remove-Item -LiteralPath $installRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    else {
        foreach ($folder in @('modules','scripts','ui','assets','backups')) {
            $target = Join-Path $installRoot $folder
            if (Test-Path -LiteralPath $target) {
                Remove-Item -LiteralPath $target -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Write-Host 'PS-PowerPrompt fue desinstalado correctamente.' -ForegroundColor Green
    if (-not $RemoveData) {
        Write-Host "Configuracion conservada en: $configPath" -ForegroundColor DarkGray
    }
    Write-Host 'Cierra esta terminal para completar la salida del modulo cargado.' -ForegroundColor Yellow
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
