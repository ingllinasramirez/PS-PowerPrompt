Set-StrictMode -Version Latest

# Carga todos los componentes en el mismo ambito del modulo para que sus
# funciones y aliases puedan exportarse de forma consistente.
. (Join-Path $PSScriptRoot 'PSPowerPrompt.Maintenance.psm1')
. (Join-Path $PSScriptRoot 'PSPowerPrompt.AI.psm1')
. (Join-Path $PSScriptRoot 'PSPowerPrompt.Branding.psm1')
. (Join-Path $PSScriptRoot 'PSPowerPrompt.psm1')

# Sustituye la bienvenida basica por la presentacion corporativa.
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
    }
    catch {
        Write-Warning "No fue posible iniciar la captura automatica: $($_.Exception.Message)"
        Invoke-PPSound Error
        $active = $false
    }

    $script:Session = [pscustomobject]@{
        Id = $sessionId
        StartedAt = Get-Date
        TranscriptPath = $transcriptPath
        IsActive = $active
    }

    $script:SessionVariables['HOME'] = $HOME
    $script:SessionVariables['PWD'] = (Get-Location).Path
    $script:SessionVariables['EXPORTS'] = $paths.Exports
    $script:SessionVariables['SESSIONS'] = $paths.Sessions

    Show-PPCorporateWelcome
    Write-Host "  Sesion: $sessionId  |  Captura: $(if ($active) { 'Activa' } else { 'No disponible' })" -ForegroundColor Green
    Write-Host ''
    Invoke-PPSound Start
}

function Show-PPHelp {
    [CmdletBinding()]
    param()

    @(
        [pscustomobject]@{ Command='pp-status'; Description='Muestra el estado de la sesion actual.'; Example='pp-status' }
        [pscustomobject]@{ Command='pp-new'; Description='Crea una sesion nueva y limpia variables personalizadas.'; Example='pp-new' }
        [pscustomobject]@{ Command='pp-restart'; Description='Reinicia la sesion conservando variables personalizadas.'; Example='pp-restart' }
        [pscustomobject]@{ Command='pp-export'; Description='Exporta la sesion actual.'; Example='pp-export -Format Markdown' }
        [pscustomobject]@{ Command='pp-export-safe'; Description='Exporta ocultando datos sensibles frecuentes.'; Example='pp-export-safe' }
        [pscustomobject]@{ Command='pp-export-jsonl'; Description='Exporta la sesion como eventos JSONL.'; Example='pp-export-jsonl -Sanitize' }
        [pscustomobject]@{ Command='pp-open'; Description='Abre el ultimo archivo exportado.'; Example='pp-open' }
        [pscustomobject]@{ Command='pp-panel'; Description='Abre el panel flotante.'; Example='pp-panel' }
        [pscustomobject]@{ Command='pp-set'; Description='Guarda una ruta o valor temporal.'; Example='pp-set PROYECTO C:\Proyectos\App' }
        [pscustomobject]@{ Command='pp-vars'; Description='Lista o consulta variables temporales.'; Example='pp-vars' }
        [pscustomobject]@{ Command='pp-unset'; Description='Elimina una variable temporal.'; Example='pp-unset PROYECTO' }
        [pscustomobject]@{ Command='pp-go'; Description='Cambia a una ruta o variable registrada.'; Example='pp-go PROYECTO' }
        [pscustomobject]@{ Command='pp-ask'; Description='Consulta al proveedor de IA configurado.'; Example='pp-ask "Explica este proyecto"' }
        [pscustomobject]@{ Command='pp-explain'; Description='Explica un comando y sus riesgos.'; Example='pp-explain "Get-Process"' }
        [pscustomobject]@{ Command='pp-fix'; Description='Analiza el ultimo error de PowerShell.'; Example='pp-fix' }
        [pscustomobject]@{ Command='pp-ai-status'; Description='Muestra proveedores y credenciales disponibles.'; Example='pp-ai-status' }
        [pscustomobject]@{ Command='pp-ai-config'; Description='Configura un proveedor de IA.'; Example='pp-ai-config OpenAI -ApiKey "..." -SetDefault' }
        [pscustomobject]@{ Command='pp-doctor'; Description='Verifica la instalacion y los comandos.'; Example='pp-doctor' }
        [pscustomobject]@{ Command='pp-update'; Description='Actualiza PowerPrompt desde GitHub.'; Example='pp-update' }
        [pscustomobject]@{ Command='pp-uninstall'; Description='Desinstala PowerPrompt.'; Example='pp-uninstall' }
    ) | Format-Table -AutoSize -Wrap
}

# Aliases creados en el modulo raiz para garantizar su exposicion.
Set-Alias pp-start Start-PPWorkSession -Force
Set-Alias pp-status Get-PPStatus -Force
Set-Alias pp-new New-PPSession -Force
Set-Alias pp-restart Restart-PPSession -Force
Set-Alias pp-help Show-PPHelp -Force
Set-Alias pp-export Export-PPSession -Force
Set-Alias pp-export-safe Export-PPSafeSession -Force
Set-Alias pp-export-jsonl Export-PPJsonlSession -Force
Set-Alias pp-open Open-PPLatest -Force
Set-Alias pp-stop Stop-PPSession -Force
Set-Alias pp-panel Show-PPPanel -Force
Set-Alias pp-set Set-PPSessionVariable -Force
Set-Alias pp-vars Get-PPSessionVariable -Force
Set-Alias pp-unset Remove-PPSessionVariable -Force
Set-Alias pp-go Set-PPLocation -Force
Set-Alias pp-ask Invoke-PPAIRequest -Force
Set-Alias pp-explain Invoke-PPExplainCommand -Force
Set-Alias pp-fix Invoke-PPFixLastError -Force
Set-Alias pp-ai-status Get-PPAIStatus -Force
Set-Alias pp-ai-config Set-PPAIProvider -Force
Set-Alias pp-update Invoke-PPUpdate -Force
Set-Alias pp-uninstall Invoke-PPUninstall -Force
Set-Alias pp-doctor Test-PPInstallation -Force

Export-ModuleMember -Function @(
    'Start-PPWorkSession','Show-PPCorporateWelcome','Get-PPStatus','New-PPSession','Restart-PPSession','Show-PPHelp',
    'Export-PPSession','Export-PPLatestTranscript','Open-PPLatest','Open-PPExportFolder','Stop-PPSession','Show-PPPanel',
    'Set-PPSessionVariable','Get-PPSessionVariable','Remove-PPSessionVariable','Set-PPLocation',
    'Protect-PPText','Export-PPSafeSession','Export-PPJsonlSession',
    'Invoke-PPAIRequest','Invoke-PPExplainCommand','Invoke-PPFixLastError','Get-PPAIStatus','Set-PPAIProvider',
    'Invoke-PPUpdate','Invoke-PPUninstall','Test-PPInstallation'
) -Alias @(
    'pp-start','pp-status','pp-new','pp-restart','pp-help','pp-export','pp-export-safe','pp-export-jsonl',
    'pp-open','pp-stop','pp-panel','pp-set','pp-vars','pp-unset','pp-go',
    'pp-ask','pp-explain','pp-fix','pp-ai-status','pp-ai-config','pp-update','pp-uninstall','pp-doctor'
)
