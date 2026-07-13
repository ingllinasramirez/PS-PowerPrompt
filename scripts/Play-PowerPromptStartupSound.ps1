[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    exit 0
}

$resolvedPath = (Resolve-Path -LiteralPath $Path).Path

try {
    $wmp = New-Object -ComObject WMPlayer.OCX
    $wmp.settings.volume = 70
    $wmp.URL = $resolvedPath
    $wmp.controls.play()

    $deadline = (Get-Date).AddSeconds(10)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 100

        if ($wmp.playState -eq 3) {
            break
        }
    }

    $durationMs = 2500
    if ($wmp.currentMedia -and $wmp.currentMedia.duration -gt 0) {
        $durationMs = [Math]::Min([Math]::Max([int]($wmp.currentMedia.duration * 1000) + 250, 500), 10000)
    }

    Start-Sleep -Milliseconds $durationMs
    $wmp.controls.stop()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($wmp)
    exit 0
}
catch {
    try {
        Add-Type -AssemblyName PresentationCore
        $player = [System.Windows.Media.MediaPlayer]::new()
        $player.Open([Uri]::new($resolvedPath))

        $deadline = (Get-Date).AddSeconds(5)
        while (-not $player.NaturalDuration.HasTimeSpan -and (Get-Date) -lt $deadline) {
            Start-Sleep -Milliseconds 100
        }

        $player.Volume = 0.7
        $player.Play()

        $durationMs = 2500
        if ($player.NaturalDuration.HasTimeSpan) {
            $durationMs = [Math]::Min([Math]::Max([int]$player.NaturalDuration.TimeSpan.TotalMilliseconds + 250, 500), 10000)
        }

        Start-Sleep -Milliseconds $durationMs
        $player.Stop()
        $player.Close()
        exit 0
    }
    catch {
        exit 0
    }
}
