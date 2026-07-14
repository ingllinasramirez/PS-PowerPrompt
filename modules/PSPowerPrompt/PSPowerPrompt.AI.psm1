Set-StrictMode -Version Latest

function Get-PPAIConfigPath { Join-Path $HOME '.ps-powerprompt\config\settings.json' }

function Get-PPAIConfig {
    $path = Get-PPAIConfigPath
    if (-not (Test-Path -LiteralPath $path)) { throw "No se encontro la configuracion de PS-PowerPrompt en $path" }
    Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
}

function Save-PPAIConfig {
    param([Parameter(Mandatory)]$Config)
    $Config | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Get-PPAIConfigPath) -Encoding utf8
}

function Get-PPAIProviderDefinition {
    param([Parameter(Mandatory)]$Config,[string]$Provider)
    if (-not $Provider) { $Provider = [string]$Config.ai.defaultProvider }
    if ([string]::IsNullOrWhiteSpace($Provider)) { $Provider = 'Ollama' }
    $property = $Config.ai.providers.PSObject.Properties[$Provider]
    if ($null -eq $property) { throw "Proveedor de IA no configurado: $Provider" }
    [pscustomobject]@{ Name = $Provider; Settings = $property.Value }
}

function Get-PPAIApiKey {
    param([Parameter(Mandatory)]$Provider,[Parameter(Mandatory)]$Settings)
    $name = [string]$Settings.apiKeyEnvironmentVariable
    if ([string]::IsNullOrWhiteSpace($name)) { return $null }
    $value = [Environment]::GetEnvironmentVariable($name,'Process')
    if ([string]::IsNullOrWhiteSpace($value)) { $value = [Environment]::GetEnvironmentVariable($name,'User') }
    if ([string]::IsNullOrWhiteSpace($value)) { throw "Falta la variable de entorno $name para usar $Provider. Configurala con pp-ai-config." }
    $value
}

function Get-PPAISystemPrompt {
@'
Eres el asistente tecnico de PS-PowerPrompt para PowerShell 7 en Windows.
Responde en espanol claro y profesional.
Prioriza comandos seguros, reversibles y compatibles con PowerShell 7.
No afirmes que ejecutaste comandos. No ocultes riesgos.
Cuando propongas comandos, colocalos en bloques powershell y explica brevemente que hacen.
Si faltan datos, indica los supuestos realizados.
'@
}

function Test-PPOllamaApi {
    param([string]$BaseUrl = 'http://127.0.0.1:11434')
    try { Invoke-RestMethod -Method Get -Uri "$BaseUrl/api/tags" -TimeoutSec 5 | Out-Null; return $true } catch { return $false }
}

function Invoke-PPOllamaRequest {
    param([Parameter(Mandatory)]$Settings,[Parameter(Mandatory)][string]$Prompt)
    $endpoint = [string]$Settings.endpoint
    $model = [string]$Settings.model
    if ([string]::IsNullOrWhiteSpace($endpoint)) { $endpoint = 'http://127.0.0.1:11434/api/chat' }
    if ([string]::IsNullOrWhiteSpace($model)) { $model = 'qwen2.5-coder:3b' }
    $baseUrl = $endpoint -replace '/api/chat$',''
    if (-not (Test-PPOllamaApi -BaseUrl $baseUrl)) {
        throw 'Ollama no esta disponible. Abre Ollama o ejecuta: ollama serve'
    }
    $body = @{ model=$model; stream=$false; messages=@(
        @{ role='system'; content=(Get-PPAISystemPrompt) },
        @{ role='user'; content=$Prompt }
    ); options=@{ temperature=0.2 } } | ConvertTo-Json -Depth 8
    $response = Invoke-RestMethod -Method Post -Uri $endpoint -ContentType 'application/json' -Body $body -TimeoutSec 600
    $text = [string]$response.message.content
    if ([string]::IsNullOrWhiteSpace($text)) { throw 'Ollama devolvio una respuesta vacia.' }
    $text
}

function Invoke-PPOpenAICompatibleRequest {
    param([Parameter(Mandatory)][string]$Provider,[Parameter(Mandatory)]$Settings,[Parameter(Mandatory)][string]$Prompt)
    $apiKey = Get-PPAIApiKey -Provider $Provider -Settings $Settings
    $endpoint = [string]$Settings.endpoint; $model = [string]$Settings.model
    if ([string]::IsNullOrWhiteSpace($endpoint) -or [string]::IsNullOrWhiteSpace($model)) { throw "El proveedor $Provider no tiene endpoint o modelo configurado." }
    $headers = @{ Authorization="Bearer $apiKey"; 'Content-Type'='application/json' }
    $body = @{ model=$model; messages=@(@{role='system';content=(Get-PPAISystemPrompt)},@{role='user';content=$Prompt}); temperature=0.2 } | ConvertTo-Json -Depth 8
    $response = Invoke-RestMethod -Method Post -Uri $endpoint -Headers $headers -Body $body -TimeoutSec 120
    $text = [string]$response.choices[0].message.content
    if ([string]::IsNullOrWhiteSpace($text)) { throw "El proveedor $Provider devolvio una respuesta vacia." }
    $text
}

function Invoke-PPGeminiRequest {
    param([Parameter(Mandatory)]$Settings,[Parameter(Mandatory)][string]$Prompt)
    $apiKey = Get-PPAIApiKey -Provider 'Gemini' -Settings $Settings
    $model = [string]$Settings.model; $endpoint = [string]$Settings.endpoint
    if ([string]::IsNullOrWhiteSpace($model)) { throw 'Gemini no tiene un modelo configurado.' }
    if ([string]::IsNullOrWhiteSpace($endpoint)) { $endpoint='https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent' }
    $uri = $endpoint.Replace('{model}',[uri]::EscapeDataString($model)) + '?key=' + [uri]::EscapeDataString($apiKey)
    $body = @{ systemInstruction=@{parts=@(@{text=(Get-PPAISystemPrompt)})}; contents=@(@{role='user';parts=@(@{text=$Prompt})}); generationConfig=@{temperature=0.2} } | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Method Post -Uri $uri -ContentType 'application/json' -Body $body -TimeoutSec 120
    $text = [string]$response.candidates[0].content.parts[0].text
    if ([string]::IsNullOrWhiteSpace($text)) { throw 'Gemini devolvio una respuesta vacia.' }
    $text
}

function Invoke-PPWindowsCopilot {
    param([Parameter(Mandatory)][string]$Prompt)
    Set-Clipboard -Value $Prompt
    try { Start-Process 'ms-copilot:' -ErrorAction Stop | Out-Null; Write-Host 'Se abrio Copilot y el prompt quedo copiado.' -ForegroundColor Cyan; Write-Host 'Pegalo con Ctrl+V. PowerPrompt no puede leer automaticamente su respuesta.' -ForegroundColor DarkGray }
    catch { Write-Host 'No fue posible abrir Copilot. El prompt quedo en el portapapeles.' -ForegroundColor Yellow }
}

function Invoke-PPAIRequest {
    [CmdletBinding()] param([Parameter(Mandatory,Position=0)][string]$Prompt,[string]$Provider,[switch]$Raw)
    $config = Get-PPAIConfig
    if (-not $config.ai -or -not $config.ai.enabled) { throw 'La asistencia inteligente esta desactivada.' }
    $definition = Get-PPAIProviderDefinition -Config $config -Provider $Provider
    $name=$definition.Name; $settings=$definition.Settings
    Write-Host "[PowerPrompt AI] Consultando $name..." -ForegroundColor Cyan
    $answer = switch ($name) {
        'WindowsCopilot' { Invoke-PPWindowsCopilot -Prompt $Prompt; return }
        'Ollama' { Invoke-PPOllamaRequest -Settings $settings -Prompt $Prompt }
        'Gemini' { Invoke-PPGeminiRequest -Settings $settings -Prompt $Prompt }
        default { Invoke-PPOpenAICompatibleRequest -Provider $name -Settings $settings -Prompt $Prompt }
    }
    if ($Raw) { return $answer }
    Write-Host ''; Write-Host 'Respuesta sugerida' -ForegroundColor Green
    Write-Host ('-'*72) -ForegroundColor DarkGray; Write-Host $answer -ForegroundColor White
    Write-Host ('-'*72) -ForegroundColor DarkGray; Write-Host 'Revisa cualquier comando antes de ejecutarlo.' -ForegroundColor Yellow
}

function Invoke-PPExplainCommand {
    [CmdletBinding()] param([Parameter(Mandatory,Position=0)][string]$Command,[string]$Provider)
    Invoke-PPAIRequest -Prompt "Explica este comando de PowerShell. Incluye objetivo, partes, riesgos y alternativa segura cuando aplique.`n`nCOMANDO:`n$Command" -Provider $Provider
}

function Invoke-PPFixLastError {
    [CmdletBinding()] param([string]$Provider)
    $lastError=$global:Error|Select-Object -First 1
    if (-not $lastError) { Write-Host 'No hay un error reciente disponible en $Error.' -ForegroundColor Yellow; return }
    $prompt="Analiza este error reciente de PowerShell y propone una solucion segura paso a paso. No ejecutes nada.`nDirectorio: $((Get-Location).Path)`nPowerShell: $($PSVersionTable.PSVersion)`n`nERROR:`n$($lastError|Out-String)"
    Invoke-PPAIRequest -Prompt $prompt -Provider $Provider
}

function Get-PPAIStatus {
    [CmdletBinding()] param()
    $config=Get-PPAIConfig
    $rows=foreach($property in $config.ai.providers.PSObject.Properties){
        $settings=$property.Value; $envName=[string]$settings.apiKeyEnvironmentVariable
        $ready = if($property.Name -eq 'Ollama'){ Test-PPOllamaApi -BaseUrl (([string]$settings.endpoint)-replace '/api/chat$','') }
        elseif([string]::IsNullOrWhiteSpace($envName)){ $property.Name -eq 'WindowsCopilot' }
        else { -not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($envName,'User')) -or -not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($envName,'Process')) }
        [pscustomobject]@{Provider=$property.Name;Enabled=[bool]$settings.enabled;Model=[string]$settings.model;Ready=$ready;Default=$property.Name -eq [string]$config.ai.defaultProvider}
    }
    Write-Host "Asistencia inteligente: $([bool]$config.ai.enabled)" -ForegroundColor Cyan
    $rows|Format-Table -AutoSize
}

function Set-PPAIProvider {
    [CmdletBinding()] param([Parameter(Mandatory,Position=0)][ValidateSet('Ollama','WindowsCopilot','OpenAI','DeepSeek','Gemini','HuggingFace','Custom')][string]$Provider,[string]$ApiKey,[string]$Model,[string]$Endpoint,[switch]$SetDefault)
    $config=Get-PPAIConfig; $property=$config.ai.providers.PSObject.Properties[$Provider]
    if($null -eq $property){throw "Proveedor no disponible: $Provider"}
    $settings=$property.Value
    if($Model){$settings.model=$Model}; if($Endpoint){$settings.endpoint=$Endpoint}
    $settings.enabled=$true; $config.ai.enabled=$true
    if($SetDefault -or [string]::IsNullOrWhiteSpace([string]$config.ai.defaultProvider)){$config.ai.defaultProvider=$Provider}
    if($ApiKey){$envName=[string]$settings.apiKeyEnvironmentVariable;if([string]::IsNullOrWhiteSpace($envName)){throw "$Provider no requiere API key."};[Environment]::SetEnvironmentVariable($envName,$ApiKey,'User');Set-Item -Path "Env:$envName" -Value $ApiKey}
    Save-PPAIConfig -Config $config
    Write-Host "Proveedor configurado: $Provider" -ForegroundColor Green
    Write-Host "Proveedor predeterminado: $($config.ai.defaultProvider)" -ForegroundColor DarkGray
}

Set-Alias pp-ask Invoke-PPAIRequest
Set-Alias pp-explain Invoke-PPExplainCommand
Set-Alias pp-fix Invoke-PPFixLastError
Set-Alias pp-ai-status Get-PPAIStatus
Set-Alias pp-ai-config Set-PPAIProvider
Export-ModuleMember -Function Invoke-PPAIRequest,Invoke-PPExplainCommand,Invoke-PPFixLastError,Get-PPAIStatus,Set-PPAIProvider,Test-PPOllamaApi -Alias pp-ask,pp-explain,pp-fix,pp-ai-status,pp-ai-config