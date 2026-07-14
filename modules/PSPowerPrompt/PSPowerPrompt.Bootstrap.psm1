Set-StrictMode -Version Latest

$corePath = Join-Path $PSScriptRoot 'PSPowerPrompt.psm1'
$coreScript = [scriptblock]::Create((Get-Content -LiteralPath $corePath -Raw))
$coreModule = New-Module -Name 'PSPowerPrompt.Core' -ScriptBlock $coreScript
Import-Module $coreModule -Force -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot 'PSPowerPrompt.Maintenance.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot 'PSPowerPrompt.AI.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot 'PSPowerPrompt.Branding.psm1') -Force -DisableNameChecking

function Start-PPWorkSession { [CmdletBinding()] param() & 'PSPowerPrompt.Core\Start-PPWorkSession' }
function Get-PPStatus { [CmdletBinding()] param() & 'PSPowerPrompt.Core\Get-PPStatus' }
function New-PPSession { [CmdletBinding()] param() & 'PSPowerPrompt.Core\New-PPSession' }
function Restart-PPSession { [CmdletBinding()] param() & 'PSPowerPrompt.Core\Restart-PPSession' }
function Export-PPSession { [CmdletBinding()] param([ValidateSet('Markdown','Text','Json')][string]$Format) if ($PSBoundParameters.ContainsKey('Format')) { & 'PSPowerPrompt.Core\Export-PPSession' -Format $Format } else { & 'PSPowerPrompt.Core\Export-PPSession' } }
function Export-PPLatestTranscript { [CmdletBinding()] param([ValidateSet('Markdown','Text','Json')][string]$Format) if ($PSBoundParameters.ContainsKey('Format')) { & 'PSPowerPrompt.Core\Export-PPLatestTranscript' -Format $Format } else { & 'PSPowerPrompt.Core\Export-PPLatestTranscript' } }
function Open-PPLatest { [CmdletBinding()] param() & 'PSPowerPrompt.Core\Open-PPLatest' }
function Open-PPExportFolder { [CmdletBinding()] param() & 'PSPowerPrompt.Core\Open-PPExportFolder' }
function Stop-PPSession { [CmdletBinding()] param() & 'PSPowerPrompt.Core\Stop-PPSession' }
function Show-PPPanel { [CmdletBinding()] param() & 'PSPowerPrompt.Core\Show-PPPanel' }
function Set-PPSessionVariable { [CmdletBinding()] param([Parameter(Mandatory,Position=0)][string]$Name,[Parameter(Mandatory,Position=1)][string]$Value) & 'PSPowerPrompt.Core\Set-PPSessionVariable' -Name $Name -Value $Value }
function Get-PPSessionVariable { [CmdletBinding()] param([string]$Name) if ($PSBoundParameters.ContainsKey('Name')) { & 'PSPowerPrompt.Core\Get-PPSessionVariable' -Name $Name } else { & 'PSPowerPrompt.Core\Get-PPSessionVariable' } }
function Remove-PPSessionVariable { [CmdletBinding()] param([Parameter(Mandatory)][string]$Name) & 'PSPowerPrompt.Core\Remove-PPSessionVariable' -Name $Name }
function Set-PPLocation { [CmdletBinding()] param([Parameter(Mandatory,Position=0)][string]$NameOrPath) & 'PSPowerPrompt.Core\Set-PPLocation' -NameOrPath $NameOrPath }

function Protect-PPText { [CmdletBinding()] param([Parameter(Mandatory,ValueFromPipeline)][AllowEmptyString()][string]$Text) process { & 'PSPowerPrompt.Maintenance\Protect-PPText' -Text $Text } }
function Export-PPSafeSession { [CmdletBinding()] param([ValidateSet('Markdown','Text','Json')][string]$Format) if ($PSBoundParameters.ContainsKey('Format')) { & 'PSPowerPrompt.Maintenance\Export-PPSafeSession' -Format $Format } else { & 'PSPowerPrompt.Maintenance\Export-PPSafeSession' } }
function Export-PPJsonlSession { [CmdletBinding()] param([switch]$Sanitize) & 'PSPowerPrompt.Maintenance\Export-PPJsonlSession' -Sanitize:$Sanitize }
function Invoke-PPUpdate { [CmdletBinding()] param() & 'PSPowerPrompt.Maintenance\Invoke-PPUpdate' }
function Invoke-PPUninstall { [CmdletBinding()] param([switch]$RemoveData) & 'PSPowerPrompt.Maintenance\Invoke-PPUninstall' -RemoveData:$RemoveData }
function Test-PPInstallation { [CmdletBinding()] param() & 'PSPowerPrompt.Maintenance\Test-PPInstallation' }

function Invoke-PPAIRequest { [CmdletBinding()] param([Parameter(Mandatory,Position=0)][string]$Prompt,[string]$Provider,[switch]$Raw) & 'PSPowerPrompt.AI\Invoke-PPAIRequest' -Prompt $Prompt -Provider $Provider -Raw:$Raw }
function Invoke-PPExplainCommand { [CmdletBinding()] param([Parameter(Mandatory,Position=0)][string]$Command,[string]$Provider) & 'PSPowerPrompt.AI\Invoke-PPExplainCommand' -Command $Command -Provider $Provider }
function Invoke-PPFixLastError { [CmdletBinding()] param([string]$Provider) & 'PSPowerPrompt.AI\Invoke-PPFixLastError' -Provider $Provider }
function Get-PPAIStatus { [CmdletBinding()] param() & 'PSPowerPrompt.AI\Get-PPAIStatus' }
function Set-PPAIProvider { [CmdletBinding()] param([Parameter(Mandatory,Position=0)][ValidateSet('Ollama','WindowsCopilot','OpenAI','DeepSeek','Gemini','HuggingFace','Custom')][string]$Provider,[string]$ApiKey,[string]$Model,[string]$Endpoint,[switch]$SetDefault) & 'PSPowerPrompt.AI\Set-PPAIProvider' @PSBoundParameters }
function Show-PPCorporateWelcome { [CmdletBinding()] param() & 'PSPowerPrompt.Branding\Show-PPCorporateWelcome' }

function Show-PPHelp {
    [CmdletBinding()]
    param()

    Write-Host ''
    Write-Host 'PS-PowerPrompt 0.7.0' -ForegroundColor Cyan
    Write-Host 'IA local predeterminada: Ollama / qwen2.5-coder:3b' -ForegroundColor Green
    Write-Host 'Las respuestas de Ollama aparecen directamente en esta terminal.' -ForegroundColor DarkGray
    Write-Host ''

    @(
        [pscustomobject]@{Command='pp-start';Description='Inicia una captura cuando no existe una sesion activa.';Example='pp-start'}
        [pscustomobject]@{Command='pp-status';Description='Muestra el estado de la sesion actual.';Example='pp-status'}
        [pscustomobject]@{Command='pp-new';Description='Crea una sesion nueva y limpia variables personalizadas.';Example='pp-new'}
        [pscustomobject]@{Command='pp-restart';Description='Reinicia la sesion conservando variables.';Example='pp-restart'}
        [pscustomobject]@{Command='pp-stop';Description='Detiene la captura actual.';Example='pp-stop'}
        [pscustomobject]@{Command='pp-export';Description='Exporta la sesion actual.';Example='pp-export -Format Markdown'}
        [pscustomobject]@{Command='pp-export-safe';Description='Exporta ocultando datos sensibles.';Example='pp-export-safe'}
        [pscustomobject]@{Command='pp-export-jsonl';Description='Exporta como eventos JSONL.';Example='pp-export-jsonl -Sanitize'}
        [pscustomobject]@{Command='pp-open';Description='Abre el ultimo archivo exportado.';Example='pp-open'}
        [pscustomobject]@{Command='pp-panel';Description='Abre el panel flotante.';Example='pp-panel'}
        [pscustomobject]@{Command='pp-set';Description='Guarda una ruta o valor temporal.';Example='pp-set PROYECTO C:\Proyectos\App'}
        [pscustomobject]@{Command='pp-vars';Description='Lista o consulta variables temporales.';Example='pp-vars'}
        [pscustomobject]@{Command='pp-unset';Description='Elimina una variable temporal.';Example='pp-unset PROYECTO'}
        [pscustomobject]@{Command='pp-go';Description='Cambia a una ruta registrada.';Example='pp-go PROYECTO'}
        [pscustomobject]@{Command='pp-ask';Description='Consulta a la IA y muestra la respuesta en PowerShell.';Example='pp-ask "Explica este proyecto"'}
        [pscustomobject]@{Command='pp-explain';Description='Explica un comando, riesgos y alternativas.';Example='pp-explain "Get-Process"'}
        [pscustomobject]@{Command='pp-fix';Description='Analiza el ultimo error de PowerShell.';Example='pp-fix'}
        [pscustomobject]@{Command='pp-ai-status';Description='Muestra proveedores, modelos y disponibilidad.';Example='pp-ai-status'}
        [pscustomobject]@{Command='pp-ai-config';Description='Configura o cambia el proveedor de IA.';Example='pp-ai-config Ollama -Model "qwen2.5-coder:3b" -SetDefault'}
        [pscustomobject]@{Command='pp-doctor';Description='Verifica la instalacion y comandos.';Example='pp-doctor'}
        [pscustomobject]@{Command='pp-update';Description='Actualiza PowerPrompt desde GitHub.';Example='pp-update'}
        [pscustomobject]@{Command='pp-uninstall';Description='Desinstala PowerPrompt.';Example='pp-uninstall'}
    ) | Format-Table -AutoSize -Wrap

    Write-Host ''
    Write-Host 'Ejemplos de IA local' -ForegroundColor Yellow
    Write-Host '  pp-ask "Como listar los archivos mas pesados de esta carpeta"' -ForegroundColor White
    Write-Host '  pp-explain "Get-ChildItem -Recurse"' -ForegroundColor White
    Write-Host '  pp-fix' -ForegroundColor White
    Write-Host ''
}

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

Export-ModuleMember -Function Start-PPWorkSession,Show-PPCorporateWelcome,Get-PPStatus,New-PPSession,Restart-PPSession,Show-PPHelp,Export-PPSession,Export-PPLatestTranscript,Open-PPLatest,Open-PPExportFolder,Stop-PPSession,Show-PPPanel,Set-PPSessionVariable,Get-PPSessionVariable,Remove-PPSessionVariable,Set-PPLocation,Protect-PPText,Export-PPSafeSession,Export-PPJsonlSession,Invoke-PPAIRequest,Invoke-PPExplainCommand,Invoke-PPFixLastError,Get-PPAIStatus,Set-PPAIProvider,Invoke-PPUpdate,Invoke-PPUninstall,Test-PPInstallation -Alias pp-start,pp-status,pp-new,pp-restart,pp-help,pp-export,pp-export-safe,pp-export-jsonl,pp-open,pp-stop,pp-panel,pp-set,pp-vars,pp-unset,pp-go,pp-ask,pp-explain,pp-fix,pp-ai-status,pp-ai-config,pp-update,pp-uninstall,pp-doctor
