[CmdletBinding()]
param([switch]$NoLaunch)

$ErrorActionPreference = 'Stop'
$InstallerVersion = '0.5.1'

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

function Read-Default {
    param(
        [string]$Prompt,
        [string]$Default
    )

    $value = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $Default
    }

    return $value.Trim()
}

function Read-YesNo {
    param(
        [string]$Prompt,
        [bool]$Default = $true
    )

    $suffix = if ($Default) { 'S/n' } else { 's/N' }
    $value = Read-Host "$Prompt [$suffix]"

    if ([string]::IsNullOrWhiteSpace($value)) {
        return $Default
    }

    return $value.Trim().ToLowerInvariant() -in @('s','si','sí','y','yes')
}

function Remove-ProfileBootstrap {
    param([Parameter(Mandatory)][string]$ProfilePath)

    if (-not (Test-Path -LiteralPath $ProfilePath)) {
        return
    }

    $start = '# >>> PS-PowerPrompt >>>'
    $end = '# <<< PS-PowerPrompt <<<'
    $content = Get-Content -LiteralPath $ProfilePath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) {
        return
    }

    $pattern = '(?s)' + [regex]::Escape($start) + '.*?' + [regex]::Escape($end)
    $cleaned = [regex]::Replace($content, $pattern, '').TrimEnd()

    if ($cleaned -ne $content) {
        $backup = "$ProfilePath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $ProfilePath -Destination $backup -Force
        Set-Content -LiteralPath $ProfilePath -Value $cleaned -Encoding utf8
        Write-Success "Se retiro un inicio duplicado de: $ProfilePath"
    }
}

function Install-ProfileBootstrap {
    param(
        [Parameter(Mandatory)][string]$ProfilePath,
        [Parameter(Mandatory)][string]$ModuleManifest
    )

    $start = '# >>> PS-PowerPrompt >>>'
    $end = '# <<< PS-PowerPrompt <<<'
    $directory = Split-Path -Parent $ProfilePath

    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    if (-not (Test-Path -LiteralPath $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
    }

    $content = Get-Content -LiteralPath $ProfilePath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) {
        $content = ''
    }

    $pattern = '(?s)' + [regex]::Escape($start) + '.*?' + [regex]::Escape($end)
    $content = [regex]::Replace($content, $pattern, '').TrimEnd()

    $backup = "$ProfilePath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -LiteralPath $ProfilePath -Destination $backup -Force

    $escapedManifest = $ModuleManifest.Replace("'", "''")
    $block = @"

$start
`$powerPromptManifest = '$escapedManifest'
if (Test-Path -LiteralPath `$powerPromptManifest) {
    Import-Module `$powerPromptManifest -Force
    Start-PPWorkSession
} else {
    Write-Warning "PS-PowerPrompt no encontro su modulo en: `$powerPromptManifest"
}
$end
"@

    Set-Content -LiteralPath $ProfilePath -Value ($content + $block) -Encoding utf8
    Write-Success "Perfil configurado: $ProfilePath"
}

function Install-ContextMenu {
    param(
        [Parameter(Mandatory)][string]$PwshPath,
        [Parameter(Mandatory)][string]$LauncherPath
    )

    $items = @(
        @{ Root = 'HKCU:\Software\Classes\Directory\Background\shell\PSPowerPrompt'; Argument = '%V' },
        @{ Root = 'HKCU:\Software\Classes\Directory\shell\PSPowerPrompt'; Argument = '%1' }
    )

    foreach ($item in $items) {
        $commandKey = Join-Path $item.Root 'command'
        New-Item -Path $commandKey -Force | Out-Null
        Set-ItemProperty -Path $item.Root -Name '(default)' -Value 'Iniciar PowerPrompt desde aqui'
        Set-ItemProperty -Path $item.Root -Name 'Icon' -Value "$PwshPath,0"
        $command = '"{0}" -NoLogo -ExecutionPolicy Bypass -NoExit -File "{1}" "{2}"' -f $PwshPath, $LauncherPath, $item.Argument
        Set-ItemProperty -Path $commandKey -Name '(default)' -Value $command
    }

    Write-Success 'Menu contextual de Explorador instalado.'
}

if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw 'PS-PowerPrompt requiere PowerShell 7 o superior.'
}

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$installRoot = Join-Path $HOME '.ps-powerprompt'
$moduleSource = Join-Path $projectRoot 'modules\PSPowerPrompt'
$moduleTarget = Join-Path $installRoot 'modules\PSPowerPrompt'
$uiSource = Join-Path $projectRoot 'ui'
$uiTarget = Join-Path $installRoot 'ui'
$scriptsSource = Join-Path $projectRoot 'scripts'
$scriptsTarget = Join-Path $installRoot 'scripts'
$assetsSource = Join-Path $projectRoot 'assets'
$assetsTarget = Join-Path $installRoot 'assets'
$configTarget = Join-Path $installRoot 'config\settings.json'
$moduleManifest = Join-Path $moduleTarget 'PSPowerPrompt.psd1'
$launcherTarget = Join-Path $scriptsTarget 'Open-PowerPromptHere.ps1'

Write-Host ''
Write-Host "PS-PowerPrompt Installer $InstallerVersion" -ForegroundColor White
Write-Host 'Presiona Enter para aceptar cualquier valor predeterminado.' -ForegroundColor DarkGray
Write-Host ''

$defaultExports = Join-Path $HOME 'Documents\PS-PowerPrompt\Exports'
$defaultSessions = Join-Path $HOME 'Documents\PS-PowerPrompt\Sessions'
$displayName = Read-Default 'Nombre para el saludo' $env:USERNAME
$exportsPath = Read-Default 'Carpeta para las exportaciones' $defaultExports
$sessionsPath = Read-Default 'Carpeta para las sesiones' $defaultSessions
$format = Read-Default 'Formato predeterminado (Markdown, Text o Json)' 'Markdown'
if ($format -notin @('Markdown','Text','Json')) {
    $format = 'Markdown'
}

$soundEnabled = Read-YesNo '¿Reproducir aparicion.mp3 al iniciar la terminal?' $true
$openAfterExport = Read-YesNo '¿Abrir el archivo automaticamente despues de exportar?' $false
$launchPanel = Read-YesNo '¿Abrir tambien el panel flotante al finalizar?' $true
$installContextMenu = Read-YesNo '¿Agregar "Iniciar PowerPrompt desde aqui" al clic derecho?' $true
$panelWithContextMenu = Read-YesNo '¿Abrir el panel al iniciar desde el clic derecho?' $false

Write-Step 'Validando archivos del proyecto...'
foreach ($requiredPath in @($moduleSource, $uiSource, $scriptsSource)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "No se encontro el recurso requerido: $requiredPath"
    }
}

$sourceSound = Join-Path $assetsSource 'aparicion.mp3'
if ($soundEnabled -and -not (Test-Path -LiteralPath $sourceSound -PathType Leaf)) {
    throw "No se encontro el sonido requerido: $sourceSound"
}

Write-Step 'Preparando directorios...'
@(
    $installRoot,
    $moduleTarget,
    $uiTarget,
    $scriptsTarget,
    $assetsTarget,
    (Split-Path -Parent $configTarget),
    $sessionsPath,
    $exportsPath
) | ForEach-Object {
    if (-not (Test-Path -LiteralPath $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

Write-Step 'Copiando modulo, panel, scripts y recursos...'
Copy-Item -Path (Join-Path $moduleSource '*') -Destination $moduleTarget -Recurse -Force
Copy-Item -Path (Join-Path $uiSource '*') -Destination $uiTarget -Recurse -Force
Copy-Item -Path (Join-Path $scriptsSource '*') -Destination $scriptsTarget -Recurse -Force
if (Test-Path -LiteralPath $assetsSource) {
    Copy-Item -Path (Join-Path $assetsSource '*') -Destination $assetsTarget -Recurse -Force
}

$startupSound = Join-Path $assetsTarget 'aparicion.mp3'
$playerScript = Join-Path $scriptsTarget 'Play-PowerPromptStartupSound.ps1'

if ($soundEnabled) {
    if (-not (Test-Path -LiteralPath $startupSound -PathType Leaf)) {
        throw "El instalador no pudo copiar: $startupSound"
    }
    if (-not (Test-Path -LiteralPath $playerScript -PathType Leaf)) {
        throw "El instalador no pudo copiar: $playerScript"
    }
}

$config = [ordered]@{
    version = 5
    user = [ordered]@{
        displayName = $displayName
    }
    agent = [ordered]@{
        name = 'PowerPrompt'
        mode = 'greeting-only'
        message = 'Sesion de trabajo iniciada. Estoy listo para acompanarte con tus comandos.'
        soundEnabled = $soundEnabled
        startupSound = $startupSound
    }
    paths = [ordered]@{
        sessions = $sessionsPath
        exports = $exportsPath
    }
    export = [ordered]@{
        defaultFormat = $format
        includeMetadata = $true
        openAfterExport = $openAfterExport
    }
    ui = [ordered]@{
        launchPanelAfterInstall = $launchPanel
        launchPanelWithContextMenu = $panelWithContextMenu
    }
    explorer = [ordered]@{
        contextMenuEnabled = $installContextMenu
    }
    retentionDays = 90
}

$config | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $configTarget -Encoding utf8
Write-Success "Configuracion guardada en: $configTarget"

Write-Step 'Corrigiendo perfiles de PowerShell...'
Remove-ProfileBootstrap -ProfilePath $PROFILE.CurrentUserCurrentHost
Install-ProfileBootstrap -ProfilePath $PROFILE.CurrentUserAllHosts -ModuleManifest $moduleManifest

$pwshCommand = Get-Command pwsh -ErrorAction SilentlyContinue
$pwsh = if ($pwshCommand) { $pwshCommand.Source } else { $null }

if ($installContextMenu -and $pwsh) {
    Write-Step 'Configurando menu contextual del Explorador...'
    Install-ContextMenu -PwshPath $pwsh -LauncherPath $launcherTarget
}

Write-Step 'Validando modulo y comandos...'
Import-Module $moduleManifest -Force
foreach ($command in @(
    'Start-PPWorkSession',
    'Get-PPStatus',
    'Export-PPSession',
    'Open-PPLatest',
    'Open-PPExportFolder',
    'Stop-PPSession',
    'Show-PPPanel',
    'Set-PPSessionVariable',
    'Get-PPSessionVariable',
    'Remove-PPSessionVariable',
    'Set-PPLocation'
)) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "No se pudo cargar el comando $command"
    }
}

Write-Success 'Instalacion completada y validada.'
Write-Host "  Sonido: $startupSound" -ForegroundColor DarkGray
Write-Host "  Reproductor: $playerScript" -ForegroundColor DarkGray
Write-Host ''

if (-not $NoLaunch -and $pwsh) {
    Write-Step 'Abriendo PowerShell 7 configurado...'
    Start-Process -FilePath $pwsh -ArgumentList '-NoLogo'

    if ($launchPanel) {
        Start-Sleep -Milliseconds 800
        $panel = Join-Path $uiTarget 'PowerPrompt.Panel.ps1'
        Start-Process -FilePath $pwsh -ArgumentList @(
            '-NoLogo',
            '-NoProfile',
            '-STA',
            '-ExecutionPolicy',
            'Bypass',
            '-File',
            "`"$panel`""
        )
    }
}