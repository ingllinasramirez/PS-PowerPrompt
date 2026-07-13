[CmdletBinding()]
param([switch]$NoLaunch)

$ErrorActionPreference = 'Stop'

function Write-Step { param([string]$Message) Write-Host "[PS-PowerPrompt] $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-WarnMessage { param([string]$Message) Write-Host "[AVISO] $Message" -ForegroundColor Yellow }

function Read-Default {
    param([string]$Prompt,[string]$Default)
    $value = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
    return $value.Trim()
}

function Read-YesNo {
    param([string]$Prompt,[bool]$Default = $true)
    $suffix = if ($Default) { 'S/n' } else { 's/N' }
    $value = Read-Host "$Prompt [$suffix]"
    if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
    return $value.Trim().ToLowerInvariant() -in @('s','si','sí','y','yes')
}

function Install-ProfileBootstrap {
    param([Parameter(Mandatory)][string]$ProfilePath,[Parameter(Mandatory)][string]$ModuleManifest)
    $start = '# >>> PS-PowerPrompt >>>'
    $end = '# <<< PS-PowerPrompt <<<'
    $directory = Split-Path -Parent $ProfilePath
    if (-not (Test-Path $directory)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
    if (-not (Test-Path $ProfilePath)) { New-Item -ItemType File -Path $ProfilePath -Force | Out-Null }
    $content = Get-Content -Path $ProfilePath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { $content = '' }
    if ($content -match [regex]::Escape($start)) { Write-WarnMessage "El perfil ya contiene PS-PowerPrompt: $ProfilePath"; return }
    $backup = "$ProfilePath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $ProfilePath $backup -Force
    $escaped = $ModuleManifest.Replace("'", "''")
    $block = @"

$start
`$powerPromptManifest = '$escaped'
if (Test-Path `$powerPromptManifest) {
    Import-Module `$powerPromptManifest -Force
    Start-PPWorkSession
} else {
    Write-Warning "PS-PowerPrompt no encontro su modulo en: `$powerPromptManifest"
}
$end
"@
    Add-Content -Path $ProfilePath -Value $block -Encoding utf8
    Write-Success "Perfil actualizado: $ProfilePath"
    Write-Host "  Respaldo: $backup" -ForegroundColor DarkGray
}

if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'PS-PowerPrompt requiere PowerShell 7 o superior.' }

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$installRoot = Join-Path $HOME '.ps-powerprompt'
$moduleSource = Join-Path $projectRoot 'modules\PSPowerPrompt'
$moduleTarget = Join-Path $installRoot 'modules\PSPowerPrompt'
$uiSource = Join-Path $projectRoot 'ui'
$uiTarget = Join-Path $installRoot 'ui'
$configSource = Join-Path $projectRoot 'config\settings.json'
$configTarget = Join-Path $installRoot 'config\settings.json'
$moduleManifest = Join-Path $moduleTarget 'PSPowerPrompt.psd1'

Write-Host ''
Write-Host 'Configuracion inicial de PS-PowerPrompt' -ForegroundColor White
Write-Host 'Presiona Enter para aceptar cualquier valor predeterminado.' -ForegroundColor DarkGray
Write-Host ''

$defaultExports = Join-Path $HOME 'Documents\PS-PowerPrompt\Exports'
$defaultSessions = Join-Path $HOME 'Documents\PS-PowerPrompt\Sessions'
$displayName = Read-Default 'Nombre para el saludo' $env:USERNAME
$exportsPath = Read-Default 'Carpeta para las exportaciones' $defaultExports
$sessionsPath = Read-Default 'Carpeta para las sesiones' $defaultSessions
$format = Read-Default 'Formato predeterminado (Markdown, Text o Json)' 'Markdown'
if ($format -notin @('Markdown','Text','Json')) { $format = 'Markdown' }
$soundEnabled = Read-YesNo '¿Activar sonidos discretos?' $true
$openAfterExport = Read-YesNo '¿Abrir el archivo automaticamente despues de exportar?' $false
$launchPanel = Read-YesNo '¿Abrir tambien el panel flotante al finalizar?' $true

Write-Step 'Preparando directorios...'
@($installRoot,$moduleTarget,$uiTarget,(Split-Path -Parent $configTarget),$sessionsPath,$exportsPath) | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

if (-not (Test-Path $moduleSource)) { throw "No se encontro el modulo en $moduleSource" }
if (-not (Test-Path $configSource)) { throw "No se encontro la configuracion en $configSource" }
if (-not (Test-Path $uiSource)) { throw "No se encontro el panel en $uiSource" }

Write-Step 'Copiando modulo y panel...'
Copy-Item (Join-Path $moduleSource '*') $moduleTarget -Recurse -Force
Copy-Item (Join-Path $uiSource '*') $uiTarget -Recurse -Force

$config = [ordered]@{
    version = 2
    user = [ordered]@{ displayName = $displayName }
    agent = [ordered]@{
        name = 'PowerPrompt'
        mode = 'greeting-only'
        message = 'Sesion de trabajo iniciada. Estoy listo para acompanarte con tus comandos.'
        soundEnabled = $soundEnabled
    }
    paths = [ordered]@{ sessions = $sessionsPath; exports = $exportsPath }
    export = [ordered]@{ defaultFormat = $format; includeMetadata = $true; openAfterExport = $openAfterExport }
    ui = [ordered]@{ launchPanelAfterInstall = $launchPanel }
    retentionDays = 90
}
$config | ConvertTo-Json -Depth 6 | Set-Content -Path $configTarget -Encoding utf8
Write-Success "Configuracion guardada en: $configTarget"

Write-Step 'Configurando perfiles de PowerShell...'
@($PROFILE.CurrentUserAllHosts,$PROFILE.CurrentUserCurrentHost) | Select-Object -Unique | ForEach-Object {
    Install-ProfileBootstrap -ProfilePath $_ -ModuleManifest $moduleManifest
}

Write-Step 'Validando modulo y comandos...'
Import-Module $moduleManifest -Force
foreach ($command in 'Start-PPWorkSession','Get-PPStatus','Export-PPSession','Export-PPLatestTranscript','Open-PPLatest','Open-PPExportFolder','Stop-PPSession','Show-PPPanel') {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) { throw "No se pudo cargar el comando $command" }
}
foreach ($alias in 'pp-status','pp-export','pp-open','pp-stop','pp-panel') {
    if (-not (Get-Command $alias -ErrorAction SilentlyContinue)) { throw "No se pudo cargar el alias $alias" }
}

Write-Success 'Instalacion completada y validada.'
Write-Host ''
Write-Host 'Comandos disponibles:' -ForegroundColor White
Write-Host '  pp-status  - Ver estado de la sesion' -ForegroundColor DarkGray
Write-Host '  pp-export  - Exportar la sesion actual' -ForegroundColor DarkGray
Write-Host '  pp-panel   - Abrir el panel flotante' -ForegroundColor DarkGray
Write-Host '  pp-open    - Abrir el ultimo registro' -ForegroundColor DarkGray
Write-Host '  pp-stop    - Finalizar la captura' -ForegroundColor DarkGray
Write-Host ''

if (-not $NoLaunch) {
    $pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
    if ($pwsh) {
        Write-Step 'Abriendo PowerShell 7 configurado...'
        Start-Process -FilePath $pwsh -ArgumentList '-NoLogo'
        if ($launchPanel) {
            Start-Sleep -Milliseconds 800
            $panel = Join-Path $uiTarget 'PowerPrompt.Panel.ps1'
            Start-Process -FilePath $pwsh -ArgumentList @('-NoLogo','-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',"`"$panel`"")
        }
    } else {
        Write-WarnMessage 'No fue posible localizar pwsh para abrir la nueva ventana automaticamente.'
    }
}
