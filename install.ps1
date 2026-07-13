[CmdletBinding()]
param(
    [switch]$NoLaunch
)

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "[PS-PowerPrompt] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-WarnMessage {
    param([string]$Message)
    Write-Host "[AVISO] $Message" -ForegroundColor Yellow
}

function Install-ProfileBootstrap {
    param(
        [Parameter(Mandatory)]
        [string]$ProfilePath,

        [Parameter(Mandatory)]
        [string]$ModuleManifest
    )

    $profileMarkerStart = '# >>> PS-PowerPrompt >>>'
    $profileMarkerEnd = '# <<< PS-PowerPrompt <<<'
    $profileDirectory = Split-Path -Parent $ProfilePath

    if (-not (Test-Path $profileDirectory)) {
        New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
    }

    if (-not (Test-Path $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
    }

    $profileContent = Get-Content -Path $ProfilePath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $profileContent) {
        $profileContent = ''
    }

    if ($profileContent -match [regex]::Escape($profileMarkerStart)) {
        Write-WarnMessage "El perfil ya contiene PS-PowerPrompt: $ProfilePath"
        return
    }

    $backupPath = "$ProfilePath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $ProfilePath -Destination $backupPath -Force

    $escapedManifest = $ModuleManifest.Replace("'", "''")
    $bootstrap = @"

$profileMarkerStart
`$powerPromptManifest = '$escapedManifest'
if (Test-Path `$powerPromptManifest) {
    Import-Module `$powerPromptManifest -Force
    Start-PPWorkSession
} else {
    Write-Warning "PS-PowerPrompt no encontro su modulo en: `$powerPromptManifest"
}
$profileMarkerEnd
"@

    Add-Content -Path $ProfilePath -Value $bootstrap -Encoding utf8
    Write-Success "Perfil actualizado: $ProfilePath"
    Write-Host "  Respaldo: $backupPath" -ForegroundColor DarkGray
}

if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw 'PS-PowerPrompt requiere PowerShell 7 o superior.'
}

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$installRoot = Join-Path $HOME '.ps-powerprompt'
$moduleSource = Join-Path $projectRoot 'modules\PSPowerPrompt'
$moduleTarget = Join-Path $installRoot 'modules\PSPowerPrompt'
$configSource = Join-Path $projectRoot 'config\settings.json'
$configTarget = Join-Path $installRoot 'config\settings.json'
$logsRoot = Join-Path $HOME 'Documents\PS-PowerPrompt\Sessions'
$exportsRoot = Join-Path $HOME 'Documents\PS-PowerPrompt\Exports'
$moduleManifest = Join-Path $moduleTarget 'PSPowerPrompt.psd1'

Write-Step 'Preparando directorios...'
@(
    $installRoot,
    $moduleTarget,
    (Split-Path -Parent $configTarget),
    $logsRoot,
    $exportsRoot
) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

if (-not (Test-Path $moduleSource)) {
    throw "No se encontro el modulo en $moduleSource"
}

Write-Step 'Copiando modulo...'
Copy-Item -Path (Join-Path $moduleSource '*') -Destination $moduleTarget -Recurse -Force

if (-not (Test-Path $configSource)) {
    throw "No se encontro la configuracion en $configSource"
}

if (-not (Test-Path $configTarget)) {
    Copy-Item -Path $configSource -Destination $configTarget -Force
    Write-Success 'Configuracion inicial creada.'
} else {
    Write-WarnMessage 'Se conservo la configuracion existente.'
}

Write-Step 'Configurando perfiles de PowerShell...'
$profileTargets = @(
    $PROFILE.CurrentUserAllHosts,
    $PROFILE.CurrentUserCurrentHost
) | Select-Object -Unique

foreach ($profileTarget in $profileTargets) {
    Install-ProfileBootstrap -ProfilePath $profileTarget -ModuleManifest $moduleManifest
}

Write-Step 'Validando modulo y comandos...'
Import-Module $moduleManifest -Force
$requiredCommands = 'Start-PPWorkSession', 'Get-PPStatus', 'Export-PPSession', 'Open-PPLatest', 'Stop-PPSession'
foreach ($command in $requiredCommands) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "No se pudo cargar el comando $command"
    }
}

$requiredAliases = 'pp-status', 'pp-export', 'pp-open', 'pp-stop'
foreach ($alias in $requiredAliases) {
    if (-not (Get-Command $alias -ErrorAction SilentlyContinue)) {
        throw "No se pudo cargar el alias $alias"
    }
}

Write-Success 'Instalacion completada y validada.'
Write-Host ''
Write-Host 'Comandos disponibles:' -ForegroundColor White
Write-Host '  pp-status  - Ver estado de la sesion' -ForegroundColor DarkGray
Write-Host '  pp-export  - Exportar la sesion actual para compartir con una IA' -ForegroundColor DarkGray
Write-Host '  pp-open    - Abrir el ultimo registro' -ForegroundColor DarkGray
Write-Host '  pp-stop    - Finalizar la captura' -ForegroundColor DarkGray
Write-Host ''

if (-not $NoLaunch) {
    Write-Step 'Abriendo una nueva ventana de PowerShell 7 con PS-PowerPrompt...'
    $pwshCommand = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwshCommand) {
        Start-Process -FilePath $pwshCommand.Source -ArgumentList '-NoLogo'
        Write-Success 'PowerShell 7 iniciado. La nueva ventana debe mostrar el saludo de PowerPrompt.'
    } else {
        Write-WarnMessage 'No fue posible localizar pwsh para abrir la nueva ventana automaticamente.'
    }
}