[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Path
)

$ErrorActionPreference = 'SilentlyContinue'

if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    exit 0
}

Add-Type -AssemblyName PresentationCore

$player = [System.Windows.Media.MediaPlayer]::new()
$player.Open([Uri]::new((Resolve-Path -LiteralPath $Path).Path))

$deadline = (Get-Date).AddSeconds(3)
while (-not $player.NaturalDuration.HasTimeSpan -and (Get-Date) -lt $deadline) {
    Start-Sleep -Milliseconds 100
}

$player.Volume = 0.65
$player.Play()

$durationMs = 2500
if ($player.NaturalDuration.HasTimeSpan) {
    $durationMs = [Math]::Min([Math]::Max([int]$player.NaturalDuration.TimeSpan.TotalMilliseconds + 200, 500), 8000)
}

Start-Sleep -Milliseconds $durationMs
$player.Stop()
$player.Close()
