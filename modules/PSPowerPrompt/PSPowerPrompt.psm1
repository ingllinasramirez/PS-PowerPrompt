Set-StrictMode -Version Latest

$script:Session = $null
$script:Config = $null

function Get-PPConfig {
    $configPath = Join-Path $HOME '.ps-powerprompt\config\settings.json'
    if (-not (Test-Path $configPath)) {
        throw "No se encontro la configuracion de PS-PowerPrompt en $configPath"
    }

    if (-not $script:Config) {
        $script:Config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
    }

    return $script:Config
}

function Get-PPPaths {
    $config = Get-PPConfig
    $sessions = [Environment]::ExpandEnvironmentVariables($config.paths.sessions)
    $exports = [Environment]::ExpandEnvironmentVariables($config.paths.exports)

    foreach ($path in @($sessions, $exports)) {
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }

    [pscustomobject]@{
        Sessions = $sessions
        Exports = $exports
    }
}

function Start-PPWorkSession {
    [CmdletBinding()]
    param()

    if ($script:Session -and $script:Session.IsActive) {
        return
    }

    $paths = Get-PPPaths
    $config = Get-PPConfig
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $sessionId = [guid]::NewGuid().ToString('N').Substring(0, 8)
    $transcriptPath = Join-Path $paths.Sessions "session-$timestamp-$sessionId.txt"

    try {
        Start-Transcript -Path $transcriptPath -Append | Out-Null
        $active = $true
    } catch {
        Write-Warning "No fue posible iniciar la captura automatica: $($_.Exception.Message)"
        $active = $false
    }

    $script:Session = [pscustomobject]@{
        Id = $sessionId
        StartedAt = Get-Date
        TranscriptPath = $transcriptPath
        IsActive = $active
    }

    $hour = (Get-Date).Hour
    $greeting = if ($hour -lt 12) { 'Buenos dias' } elseif ($hour -lt 19) { 'Buenas tardes' } else { 'Buenas noches' }
    $userName = if ($config.user.displayName) { $config.user.displayName } else { $env:USERNAME }

    Write-Host ''
    Write-Host "[$($config.agent.name)] $greeting, $userName." -ForegroundColor Cyan
    Write-Host "Sesion de trabajo iniciada: $sessionId" -ForegroundColor Green
    Write-Host "Directorio: $((Get-Location).Path)" -ForegroundColor DarkGray
    Write-Host "PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor DarkGray
    Write-Host 'Usa pp-status, pp-export, pp-open o pp-stop.' -ForegroundColor DarkGray
    Write-Host ''
}

function Get-PPStatus {
    [CmdletBinding()]
    param()

    if (-not $script:Session) {
        Write-Host 'No hay una sesion administrada por PS-PowerPrompt en esta ventana.' -ForegroundColor Yellow
        return
    }

    [pscustomobject]@{
        SessionId = $script:Session.Id
        StartedAt = $script:Session.StartedAt
        Duration = (Get-Date) - $script:Session.StartedAt
        CaptureActive = $script:Session.IsActive
        Transcript = $script:Session.TranscriptPath
        CurrentDirectory = (Get-Location).Path
        PowerShell = $PSVersionTable.PSVersion.ToString()
    } | Format-List
}

function Stop-PPSession {
    [CmdletBinding()]
    param()

    if (-not $script:Session -or -not $script:Session.IsActive) {
        Write-Host 'No hay una captura activa.' -ForegroundColor Yellow
        return
    }

    try {
        Stop-Transcript | Out-Null
        $script:Session.IsActive = $false
        Write-Host "Captura finalizada: $($script:Session.TranscriptPath)" -ForegroundColor Green
    } catch {
        Write-Warning $_.Exception.Message
    }
}

function Export-PPSession {
    [CmdletBinding()]
    param(
        [ValidateSet('Markdown', 'Text', 'Json')]
        [string]$Format = 'Markdown'
    )

    if (-not $script:Session) {
        throw 'No hay una sesion iniciada en esta ventana.'
    }

    if ($script:Session.IsActive) {
        try { Stop-Transcript | Out-Null } catch {}
        $script:Session.IsActive = $false
    }

    $paths = Get-PPPaths
    $content = if (Test-Path $script:Session.TranscriptPath) {
        Get-Content -Path $script:Session.TranscriptPath -Raw
    } else {
        ''
    }

    $baseName = "powerprompt-$($script:Session.StartedAt.ToString('yyyyMMdd-HHmmss'))-$($script:Session.Id)"
    $metadata = [ordered]@{
        sessionId = $script:Session.Id
        startedAt = $script:Session.StartedAt.ToString('o')
        exportedAt = (Get-Date).ToString('o')
        computer = $env:COMPUTERNAME
        user = $env:USERNAME
        powershellVersion = $PSVersionTable.PSVersion.ToString()
        currentDirectory = (Get-Location).Path
        sourceTranscript = $script:Session.TranscriptPath
    }

    switch ($Format) {
        'Text' {
            $target = Join-Path $paths.Exports "$baseName.txt"
            $content | Set-Content -Path $target -Encoding utf8
        }
        'Json' {
            $target = Join-Path $paths.Exports "$baseName.json"
            [ordered]@{ metadata = $metadata; transcript = $content } |
                ConvertTo-Json -Depth 5 |
                Set-Content -Path $target -Encoding utf8
        }
        default {
            $target = Join-Path $paths.Exports "$baseName.md"
            $frontMatter = @(
                '---',
                "session_id: $($metadata.sessionId)",
                "started_at: $($metadata.startedAt)",
                "exported_at: $($metadata.exportedAt)",
                "computer: $($metadata.computer)",
                "user: $($metadata.user)",
                "powershell_version: $($metadata.powershellVersion)",
                "current_directory: $($metadata.currentDirectory)",
                '---',
                '',
                '# PS-PowerPrompt Session',
                '',
                '```text',
                $content,
                '```'
            ) -join [Environment]::NewLine
            $frontMatter | Set-Content -Path $target -Encoding utf8
        }
    }

    Write-Host "Exportacion creada: $target" -ForegroundColor Green
    Write-Host 'La captura se reiniciara para continuar la sesion.' -ForegroundColor DarkGray

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $newTranscript = Join-Path $paths.Sessions "session-$timestamp-$($script:Session.Id)-continued.txt"
    Start-Transcript -Path $newTranscript -Append | Out-Null
    $script:Session.TranscriptPath = $newTranscript
    $script:Session.IsActive = $true

    return $target
}

function Open-PPLatest {
    [CmdletBinding()]
    param()

    $paths = Get-PPPaths
    $latest = Get-ChildItem -Path $paths.Exports -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latest) {
        $latest = Get-ChildItem -Path $paths.Sessions -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
    }

    if (-not $latest) {
        Write-Host 'Todavia no hay archivos de sesion.' -ForegroundColor Yellow
        return
    }

    Invoke-Item $latest.FullName
}

Set-Alias pp-start Start-PPWorkSession
Set-Alias pp-status Get-PPStatus
Set-Alias pp-export Export-PPSession
Set-Alias pp-open Open-PPLatest
Set-Alias pp-stop Stop-PPSession

Export-ModuleMember -Function Start-PPWorkSession, Get-PPStatus, Export-PPSession, Open-PPLatest, Stop-PPSession -Alias pp-start, pp-status, pp-export, pp-open, pp-stop
