Set-StrictMode -Version Latest

function Show-PPCorporateWelcome {
    [CmdletBinding()]
    param()

    $configPath = Join-Path $HOME '.ps-powerprompt\config\settings.json'
    $config = if (Test-Path -LiteralPath $configPath) {
        Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    } else {
        $null
    }

    $displayName = if ($config -and $config.user.displayName) { [string]$config.user.displayName } else { $env:USERNAME }
    $brandName = if ($config -and $config.brand.name) { [string]$config.brand.name } else { 'PS-PowerPrompt' }
    $tagline = if ($config -and $config.brand.tagline) { [string]$config.brand.tagline } else { 'Entorno profesional de productividad para PowerShell' }
    $company = if ($config -and $config.brand.company) { [string]$config.brand.company } else { 'Puro Ingenio Samario' }
    $aiProvider = if ($config -and $config.ai.enabled) { [string]$config.ai.defaultProvider } else { 'Desactivada' }
    $hour = (Get-Date).Hour
    $greeting = if ($hour -lt 12) { 'Buenos dias' } elseif ($hour -lt 19) { 'Buenas tardes' } else { 'Buenas noches' }
    $width = 72
    $line = [string]::new([char]0x2500, $width)

    try {
        $Host.UI.RawUI.WindowTitle = "$brandName | $((Get-Location).Path)"
    } catch {}

    Write-Host ''
    Write-Host ([char]0x250C + $line + [char]0x2510) -ForegroundColor DarkCyan
    Write-Host ([char]0x2502 + ('  {0,-68}' -f $brandName) + [char]0x2502) -ForegroundColor Cyan
    Write-Host ([char]0x2502 + ('  {0,-68}' -f $tagline) + [char]0x2502) -ForegroundColor White
    Write-Host ([char]0x251C + $line + [char]0x2524) -ForegroundColor DarkCyan
    Write-Host ([char]0x2502 + ('  {0,-68}' -f "$greeting, $displayName") + [char]0x2502) -ForegroundColor Green
    Write-Host ([char]0x2502 + ('  {0,-68}' -f "Equipo: $env:COMPUTERNAME  |  PowerShell: $($PSVersionTable.PSVersion)") + [char]0x2502) -ForegroundColor Gray
    Write-Host ([char]0x2502 + ('  {0,-68}' -f "Ruta: $((Get-Location).Path)") + [char]0x2502) -ForegroundColor Gray
    Write-Host ([char]0x2502 + ('  {0,-68}' -f "Asistencia IA: $aiProvider") + [char]0x2502) -ForegroundColor Gray
    Write-Host ([char]0x251C + $line + [char]0x2524) -ForegroundColor DarkCyan
    Write-Host ([char]0x2502 + ('  {0,-68}' -f 'pp-help  comandos | pp-ask  consultar IA | pp-status  sesion') + [char]0x2502) -ForegroundColor Yellow
    Write-Host ([char]0x2502 + ('  {0,-68}' -f "Desarrollado por $company") + [char]0x2502) -ForegroundColor DarkGray
    Write-Host ([char]0x2514 + $line + [char]0x2518) -ForegroundColor DarkCyan
}

Export-ModuleMember -Function Show-PPCorporateWelcome
