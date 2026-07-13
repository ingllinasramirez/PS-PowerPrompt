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

function Invoke-PPSound {
    param([ValidateSet('Start','Success','Error')][string]$Type)
    try {
        $config = Get-PPConfig
        if (-not $config.agent.soundEnabled) { return }
        switch ($Type) {
            'Start' { [System.Media.SystemSounds]::Asterisk.Play() }
            'Success' { [System.Media.SystemSounds]::Exclamation.Play() }
            'Error' { [System.Media.SystemSounds]::Hand.Play() }
        }
    } catch {}
}

function Start-PPWorkSession {
    [CmdletBinding()]
    param()

    if ($script:Session -and $script:Session.IsActive) { return }

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
    Write-Host $config.agent.message -ForegroundColor White
    Write-Host "Sesion de trabajo iniciada: $sessionId" -ForegroundColor Green
    Write-Host "Directorio: $((Get-Location).Path)" -ForegroundColor DarkGray
    Write-Host "PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor DarkGray
    Write-Host 'Usa pp-status, pp-export, pp-panel, pp-open o pp-stop.' -ForegroundColor DarkGray
    Write-Host ''
    Invoke-PPSound Start
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
        Invoke-PPSound Error
        Write-Warning $_.Exception.Message
    }
}

function Convert-PPTranscriptToExport {
    param(
        [Parameter(Mandatory)][string]$TranscriptPath,
        [ValidateSet('Markdown','Text','Json')][string]$Format = 'Markdown'
    )

    $paths = Get-PPPaths
    $content = if (Test-Path $TranscriptPath) { Get-Content -Path $TranscriptPath -Raw -ErrorAction SilentlyContinue } else { '' }
    $startedAt = (Get-Item $TranscriptPath).CreationTime
    $baseName = "powerprompt-$($startedAt.ToString('yyyyMMdd-HHmmss'))"
    $metadata = [ordered]@{
        startedAt = $startedAt.ToString('o')
        exportedAt = (Get-Date).ToString('o')
        computer = $env:COMPUTERNAME
        user = $env:USERNAME
        powershellVersion = $PSVersionTable.PSVersion.ToString()
        currentDirectory = (Get-Location).Path
        sourceTranscript = $TranscriptPath
    }

    switch ($Format) {
        'Text' {
            $target = Join-Path $paths.Exports "$baseName.txt"
            $content | Set-Content -Path $target -Encoding utf8
        }
        'Json' {
            $target = Join-Path $paths.Exports "$baseName.json"
            [ordered]@{ metadata = $metadata; transcript = $content } | ConvertTo-Json -Depth 5 | Set-Content -Path $target -Encoding utf8
        }
        default {
            $target = Join-Path $paths.Exports "$baseName.md"
            @(
                '---',
                "started_at: $($metadata.startedAt)",
                "exported_at: $($metadata.exportedAt)",
                "computer: $($metadata.computer)",
                "user: $($metadata.user)",
                "powershell_version: $($metadata.powershellVersion)",
                "current_directory: $($metadata.currentDirectory)",
                '---','',
                '# PS-PowerPrompt Session','',
                '```text',$content,'```'
            ) -join [Environment]::NewLine | Set-Content -Path $target -Encoding utf8
        }
    }

    Invoke-PPSound Success
    return $target
}

function Export-PPSession {
    [CmdletBinding()]
    param([ValidateSet('Markdown','Text','Json')][string]$Format)

    $config = Get-PPConfig
    if (-not $Format) { $Format = $config.export.defaultFormat }
    if (-not $script:Session) { throw 'No hay una sesion iniciada en esta ventana.' }

    if ($script:Session.IsActive) {
        try { Stop-Transcript | Out-Null } catch {}
        $script:Session.IsActive = $false
    }

    $target = Convert-PPTranscriptToExport -TranscriptPath $script:Session.TranscriptPath -Format $Format
    Write-Host "Exportacion creada: $target" -ForegroundColor Green

    $paths = Get-PPPaths
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $newTranscript = Join-Path $paths.Sessions "session-$timestamp-$($script:Session.Id)-continued.txt"
    Start-Transcript -Path $newTranscript -Append | Out-Null
    $script:Session.TranscriptPath = $newTranscript
    $script:Session.IsActive = $true

    if ($config.export.openAfterExport) { Invoke-Item $target }
    return $target
}

function Export-PPLatestTranscript {
    [CmdletBinding()]
    param([ValidateSet('Markdown','Text','Json')][string]$Format)
    $config = Get-PPConfig
    if (-not $Format) { $Format = $config.export.defaultFormat }
    $paths = Get-PPPaths
    $latest = Get-ChildItem -Path $paths.Sessions -Filter '*.txt' -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) { throw 'Todavia no hay una transcripcion para exportar.' }
    $target = Convert-PPTranscriptToExport -TranscriptPath $latest.FullName -Format $Format
    if ($config.export.openAfterExport) { Invoke-Item $target }
    return $target
}

function Open-PPLatest {
    [CmdletBinding()]
    param()
    $paths = Get-PPPaths
    $latest = Get-ChildItem -Path $paths.Exports -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) { $latest = Get-ChildItem -Path $paths.Sessions -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1 }
    if (-not $latest) { Write-Host 'Todavia no hay archivos de sesion.' -ForegroundColor Yellow; return }
    Invoke-Item $latest.FullName
}

function Open-PPExportFolder {
    [CmdletBinding()]
    param()
    $paths = Get-PPPaths
    Invoke-Item $paths.Exports
}

function Show-PPPanel {
    [CmdletBinding()]
    param()
    $panel = Join-Path $HOME '.ps-powerprompt\ui\PowerPrompt.Panel.ps1'
    if (-not (Test-Path $panel)) { throw "No se encontro el panel en $panel" }
    Start-Process pwsh -ArgumentList @('-NoLogo','-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',"`"$panel`"")
}

Set-Alias pp-start Start-PPWorkSession
Set-Alias pp-status Get-PPStatus
Set-Alias pp-export Export-PPSession
Set-Alias pp-open Open-PPLatest
Set-Alias pp-stop Stop-PPSession
Set-Alias pp-panel Show-PPPanel

Export-ModuleMember -Function Start-PPWorkSession, Get-PPStatus, Export-PPSession, Export-PPLatestTranscript, Open-PPLatest, Open-PPExportFolder, Stop-PPSession, Show-PPPanel -Alias pp-start, pp-status, pp-export, pp-open, pp-stop, pp-panel
