[CmdletBinding()]
param(
    [string]$ProjectRoot = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
    param([string]$Message)
    $failures.Add($Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Add-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

$requiredFiles = @(
    'install.bat',
    'install.ps1',
    'modules\PSPowerPrompt\PSPowerPrompt.psd1',
    'modules\PSPowerPrompt\PSPowerPrompt.psm1',
    'modules\PSPowerPrompt\PSPowerPrompt.Maintenance.psm1',
    'scripts\update.ps1',
    'scripts\uninstall.ps1',
    'scripts\Play-PowerPromptStartupSound.ps1',
    'scripts\Open-PowerPromptHere.ps1',
    'ui\PowerPrompt.Panel.ps1',
    'assets\aparicion.mp3'
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $ProjectRoot $relativePath
    if (Test-Path -LiteralPath $fullPath) {
        Add-Success "Existe $relativePath"
    }
    else {
        Add-Failure "Falta $relativePath"
    }
}

$parseFiles = Get-ChildItem -LiteralPath $ProjectRoot -Recurse -File | Where-Object {
    $_.Extension -in @('.ps1','.psm1','.psd1')
}

foreach ($file in $parseFiles) {
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)

    if ($errors.Count -gt 0) {
        foreach ($errorItem in $errors) {
            Add-Failure "$($file.FullName): $($errorItem.Message)"
        }
    }
    else {
        Add-Success "Sintaxis valida: $($file.Name)"
    }
}

$manifestPath = Join-Path $ProjectRoot 'modules\PSPowerPrompt\PSPowerPrompt.psd1'
if (Test-Path -LiteralPath $manifestPath) {
    try {
        $manifest = Test-ModuleManifest -Path $manifestPath
        Add-Success "Manifiesto valido: version $($manifest.Version)"

        Remove-Module PSPowerPrompt -Force -ErrorAction SilentlyContinue
        Import-Module $manifestPath -Force

        $requiredCommands = @(
            'pp-status','pp-export','pp-export-safe','pp-export-jsonl','pp-open','pp-stop','pp-panel',
            'pp-set','pp-vars','pp-unset','pp-go','pp-new','pp-restart','pp-help',
            'pp-update','pp-uninstall','pp-doctor'
        )

        foreach ($command in $requiredCommands) {
            if (Get-Command $command -ErrorAction SilentlyContinue) {
                Add-Success "Comando disponible: $command"
            }
            else {
                Add-Failure "Comando no disponible: $command"
            }
        }
    }
    catch {
        Add-Failure "No fue posible validar/importar el modulo: $($_.Exception.Message)"
    }
    finally {
        Remove-Module PSPowerPrompt -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ''
if ($failures.Count -gt 0) {
    Write-Host "Pruebas fallidas: $($failures.Count)" -ForegroundColor Red
    exit 1
}

Write-Host 'Todas las pruebas de PS-PowerPrompt finalizaron correctamente.' -ForegroundColor Green
exit 0
