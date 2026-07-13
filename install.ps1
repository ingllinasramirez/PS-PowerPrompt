[CmdletBinding()]
param()

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
$profilePath = $PROFILE.CurrentUserCurrentHost
$profileDirectory = Split-Path -Parent $profilePath
$profileMarkerStart = '# >>> PS-PowerPrompt >>>'
$profileMarkerEnd = '# <<< PS-PowerPrompt <<<'
$moduleManifest = Join-Path $moduleTarget 'PSPowerPrompt.psd1'

Write-Step 'Preparando directorios...'
@(
    $installRoot,
    $moduleTarget,
    (Split-Path -Parent $configTarget),
    $logsRoot,
    $exportsRoot,
    $profileDirectory
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

if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$profileContent = Get-Content -Path $profilePath -Raw
if ($profileContent -notmatch [regex]::Escape($profileMarkerStart)) {
    $backupPath = "$profilePath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $profilePath -Destination $backupPath -Force

    $bootstrap = @"

$profileMarkerStart
`$powerPromptManifest = '$($moduleManifest.Replace("'", "''"))'
if (Test-Path `$powerPromptManifest) {
    Import-Module `$powerPromptManifest -Force
    Start-PPWorkSession
}
$profileMarkerEnd
"@

    Add-Content -Path $profilePath -Value $bootstrap -Encoding utf8
    Write-Success "Perfil actualizado. Respaldo: $backupPath"
} else {
    Write-WarnMessage 'El perfil ya contiene el bloque de PS-PowerPrompt.'
}

Write-Step 'Validando modulo...'
Import-Module $moduleManifest -Force
$requiredCommands = 'Start-PPWorkSession', 'Get-PPStatus', 'Export-PPSession', 'Open-PPLatest', 'Stop-PPSession'
foreach ($command in $requiredCommands) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "No se pudo cargar el comando $command"
    }
}

Write-Success 'Instalacion completada.'
Write-Host ''
Write-Host 'Cierra esta ventana y abre PowerShell 7.' -ForegroundColor White
Write-Host 'Comandos disponibles:' -ForegroundColor White
Write-Host '  pp-status  - Ver estado de la sesion' -ForegroundColor DarkGray
Write-Host '  pp-export  - Exportar la sesion actual para compartir con una IA' -ForegroundColor DarkGray
Write-Host '  pp-open    - Abrir el ultimo registro' -ForegroundColor DarkGray
Write-Host '  pp-stop    - Finalizar la captura' -ForegroundColor DarkGray
