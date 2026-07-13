[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Path,

    [ValidateRange(1, 15)]
    [int]$MaxSeconds = 8
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "No se encontro el archivo de sonido: $Path"
}

$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$alias = 'PowerPromptStartupSound'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class PowerPromptMci
{
    [DllImport("winmm.dll", CharSet = CharSet.Auto)]
    public static extern int mciSendString(
        string command,
        StringBuilder returnValue,
        int returnLength,
        IntPtr winHandle
    );
}
'@

function Invoke-MciCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Command,
        [int]$BufferLength = 0
    )

    $buffer = if ($BufferLength -gt 0) { [Text.StringBuilder]::new($BufferLength) } else { $null }
    $result = [PowerPromptMci]::mciSendString($Command, $buffer, $BufferLength, [IntPtr]::Zero)

    if ($result -ne 0) {
        throw "Windows no pudo reproducir el MP3. Codigo MCI: $result. Comando: $Command"
    }

    if ($buffer) { return $buffer.ToString() }
}

try {
    try { Invoke-MciCommand "close $alias" } catch {}
    Invoke-MciCommand ('open "{0}" type mpegvideo alias {1}' -f $resolvedPath, $alias)
    Invoke-MciCommand "setaudio $alias volume to 800"
    Invoke-MciCommand "play $alias"

    $deadline = (Get-Date).AddSeconds($MaxSeconds)
    do {
        Start-Sleep -Milliseconds 100
        $mode = (Invoke-MciCommand "status $alias mode" -BufferLength 64).Trim().ToLowerInvariant()
    } while ($mode -eq 'playing' -and (Get-Date) -lt $deadline)
}
finally {
    try { Invoke-MciCommand "stop $alias" } catch {}
    try { Invoke-MciCommand "close $alias" } catch {}
}
