Set-StrictMode -Version Latest

function Get-PPAIConfigPath {
    Join-Path $HOME '.ps-powerprompt\config\settings.json'
}

function Get-PPAIConfig {
    $path = Get-PPAIConfigPath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "No se encontro la configuracion de PS-PowerPrompt en $path"
    }

    Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
}

function Save-PPAIConfig {
    param([Parameter(Mandatory)]$Config)

    $path = Get-PPAIConfigPath
    $Config | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $path -Encoding utf8
}

function Get-PPAIProviderDefinition {
    param(
        [Parameter(Mandatory)]$Config,
        [string]$Provider
    )

    if (-not $Provider) {
        $Provider = [string]$Config.ai.defaultProvider
    }

    if ([string]::IsNullOrWhiteSpace($Provider)) {
        $Provider = 'WindowsCopilot'
    }

    $property = $Config.ai.providers.PSObject.Properties[$Provider]
    if ($null -eq $property) {
        throw "Proveedor de IA no configurado: $Provider"
    }

    [pscustomobject]@{
        Name = $Provider
        Settings = $property.Value
    }
}

function Get-PPAIApiKey {
    param(
        [Parameter(Mandatory)]$Provider,
        [Parameter(Mandatory)]$Settings
    )

    $environmentVariable = [string]$Settings.apiKeyEnvironmentVariable
    if ([string]::IsNullOrWhiteSpace($environmentVariable)) {
        return $null
    }

    $value = [Environment]::GetEnvironmentVariable($environmentVariable, 'Process')
    if ([string]::IsNullOrWhiteSpace($value)) {
        $value = [Environment]::GetEnvironmentVariable($environmentVariable, 'User')
    }

    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Falta la variable de entorno $environmentVariable para usar $Provider. Configurala con pp-ai-config."
    }

    return $value
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

function Invoke-PPOpenAICompatibleRequest {
    param(
        [Parameter(Mandatory)][string]$Provider,
        [Parameter(Mandatory)]$Settings,
        [Parameter(Mandatory)][string]$Prompt
    )

    $apiKey = Get-PPAIApiKey -Provider $Provider -Settings $Settings
    $endpoint = [string]$Settings.endpoint
    $model = [string]$Settings.model

    if ([string]::IsNullOrWhiteSpace($endpoint) -or [string]::IsNullOrWhiteSpace($model)) {
        throw "El proveedor $Provider no tiene endpoint o modelo configurado."
    }

    $headers = @{
        Authorization = "Bearer $apiKey"
        'Content-Type' = 'application/json'
    }

    $body = @{
        model = $model
        messages = @(
            @{ role = 'system'; content = Get-PPAISystemPrompt }
            @{ role = 'user'; content = $Prompt }
        )
        temperature = 0.2
    } | ConvertTo-Json -Depth 8

    $response = Invoke-RestMethod -Method Post -Uri $endpoint -Headers $headers -Body $body -TimeoutSec 120
    $text = $response.choices[0].message.content
    if ([string]::IsNullOrWhiteSpace([string]$text)) {
        throw "El proveedor $Provider devolvio una respuesta vacia."
    }

    return [string]$text
}

function Invoke-PPGeminiRequest {
    param(
        [Parameter(Mandatory)]$Settings,
        [Parameter(Mandatory)][string]$Prompt
    )

    $apiKey = Get-PPAIApiKey -Provider 'Gemini' -Settings $Settings
    $model = [string]$Settings.model
    $endpoint = [string]$Settings.endpoint

    if ([string]::IsNullOrWhiteSpace($model)) {
        throw 'Gemini no tiene un modelo configurado.'
    }

    if ([string]::IsNullOrWhiteSpace($endpoint)) {
        $endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent'
    }

    $endpoint = $endpoint.Replace('{model}', [uri]::EscapeDataString($model))
    $uri = "$endpoint?key=$([uri]::EscapeDataString($apiKey))"
    $body = @{
        systemInstruction = @{ parts = @(@{ text = Get-PPAISystemPrompt }) }
        contents = @(@{ role = 'user'; parts = @(@{ text = $Prompt }) })
        generationConfig = @{ temperature = 0.2 }
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Method Post -Uri $uri -ContentType 'application/json' -Body $body -TimeoutSec 120
    $text = $response.candidates[0].content.parts[0].text
    if ([string]::IsNullOrWhiteSpace([string]$text)) {
        throw 'Gemini devolvio una respuesta vacia.'
    }

    return [string]$text
}

function Invoke-PPWindowsCopilot {
    param([Parameter(Mandatory)][string]$Prompt)

    Set-Clipboard -Value $Prompt
    try {
        Start-Process 'ms-copilot:' -ErrorAction Stop | Out-Null
        Write-Host 'Se abrio Copilot de Windows y el prompt quedo copiado en el portapapeles.' -ForegroundColor Cyan
        Write-Host 'Pegalo en Copilot con Ctrl+V. PowerPrompt no puede leer automaticamente su respuesta.' -ForegroundColor DarkGray
    }
    catch {
        Write-Host 'No fue posible abrir Copilot mediante el protocolo de Windows.' -ForegroundColor Yellow
        Write-Host 'El prompt quedo copiado en el portapapeles para usarlo en tu asistente preferido.' -ForegroundColor DarkGray
    }
}

function Invoke-PPAIRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)][string]$Prompt,
        [string]$Provider,
        [switch]$Raw
    )

    $config = Get-PPAIConfig
    if (-not $config.ai -or -not $config.ai.enabled) {
        throw 'La asistencia inteligente esta desactivada. Actívala desde settings.json o ejecuta nuevamente el instalador.'
    }

    $definition = Get-PPAIProviderDefinition -Config $config -Provider $Provider
    $name = $definition.Name
    $settings = $definition.Settings

    Write-Host "[PowerPrompt AI] Consultando $name..." -ForegroundColor Cyan

    $answer = switch ($name) {
        'WindowsCopilot' {
            Invoke-PPWindowsCopilot -Prompt $Prompt
            return
        }
        'Gemini' {
            Invoke-PPGeminiRequest -Settings $settings -Prompt $Prompt
        }
        default {
            Invoke-PPOpenAICompatibleRequest -Provider $name -Settings $settings -Prompt $Prompt
        }
    }

    if ($Raw) {
        return $answer
    }

    Write-Host ''
    Write-Host 'Respuesta sugerida' -ForegroundColor Green
    Write-Host ('-' * 72) -ForegroundColor DarkGray
    Write-Host $answer -ForegroundColor White
    Write-Host ('-' * 72) -ForegroundColor DarkGray
    Write-Host 'Revisa cualquier comando antes de ejecutarlo.' -ForegroundColor Yellow
}

function Invoke-PPExplainCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)][string]$Command,
        [string]$Provider
    )

    $prompt = @"
Explica este comando de PowerShell de forma breve pero completa.
Incluye: objetivo, partes del comando, riesgos, efectos secundarios y una alternativa mas segura cuando aplique.

COMANDO:
$Command
"@
    Invoke-PPAIRequest -Prompt $prompt -Provider $Provider
}

function Invoke-PPFixLastError {
    [CmdletBinding()]
    param([string]$Provider)

    $lastError = $global:Error | Select-Object -First 1
    if (-not $lastError) {
        Write-Host 'No hay un error reciente disponible en $Error.' -ForegroundColor Yellow
        return
    }

    $prompt = @"
Analiza este error reciente de PowerShell y propone una solucion segura paso a paso.
No ejecutes nada. Incluye comandos de diagnostico antes de cualquier cambio destructivo.
Directorio actual: $((Get-Location).Path)
PowerShell: $($PSVersionTable.PSVersion)

ERROR:
$($lastError | Out-String)
"@
    Invoke-PPAIRequest -Prompt $prompt -Provider $Provider
}

function Get-PPAIStatus {
    [CmdletBinding()]
    param()

    $config = Get-PPAIConfig
    $rows = foreach ($property in $config.ai.providers.PSObject.Properties) {
        $settings = $property.Value
        $environmentVariable = [string]$settings.apiKeyEnvironmentVariable
        $credentialReady = if ([string]::IsNullOrWhiteSpace($environmentVariable)) {
            $property.Name -eq 'WindowsCopilot'
        } else {
            -not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($environmentVariable, 'User')) -or
            -not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($environmentVariable, 'Process'))
        }

        [pscustomobject]@{
            Provider = $property.Name
            Enabled = [bool]$settings.enabled
            Model = [string]$settings.model
            CredentialReady = $credentialReady
            Default = $property.Name -eq [string]$config.ai.defaultProvider
        }
    }

    Write-Host "Asistencia inteligente: $([bool]$config.ai.enabled)" -ForegroundColor Cyan
    $rows | Format-Table -AutoSize
}

function Set-PPAIProvider {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)][ValidateSet('WindowsCopilot','OpenAI','DeepSeek','Gemini','HuggingFace','Custom')][string]$Provider,
        [string]$ApiKey,
        [string]$Model,
        [string]$Endpoint,
        [switch]$SetDefault
    )

    $config = Get-PPAIConfig
    $property = $config.ai.providers.PSObject.Properties[$Provider]
    if ($null -eq $property) {
        throw "Proveedor no disponible: $Provider"
    }

    $settings = $property.Value
    if ($Model) { $settings.model = $Model }
    if ($Endpoint) { $settings.endpoint = $Endpoint }
    $settings.enabled = $true
    $config.ai.enabled = $true

    if ($SetDefault -or [string]::IsNullOrWhiteSpace([string]$config.ai.defaultProvider)) {
        $config.ai.defaultProvider = $Provider
    }

    if ($ApiKey) {
        $environmentVariable = [string]$settings.apiKeyEnvironmentVariable
        if ([string]::IsNullOrWhiteSpace($environmentVariable)) {
            throw "$Provider no requiere una API key."
        }
        [Environment]::SetEnvironmentVariable($environmentVariable, $ApiKey, 'User')
        Set-Item -Path "Env:$environmentVariable" -Value $ApiKey
    }

    Save-PPAIConfig -Config $config
    Write-Host "Proveedor configurado: $Provider" -ForegroundColor Green
    Write-Host "Proveedor predeterminado: $($config.ai.defaultProvider)" -ForegroundColor DarkGray
    if ($ApiKey) {
        Write-Host 'La clave se guardo como variable de entorno del usuario y no dentro de settings.json.' -ForegroundColor DarkGray
    }
}

Set-Alias pp-ask Invoke-PPAIRequest
Set-Alias pp-explain Invoke-PPExplainCommand
Set-Alias pp-fix Invoke-PPFixLastError
Set-Alias pp-ai-status Get-PPAIStatus
Set-Alias pp-ai-config Set-PPAIProvider

Export-ModuleMember -Function Invoke-PPAIRequest, Invoke-PPExplainCommand, Invoke-PPFixLastError, Get-PPAIStatus, Set-PPAIProvider -Alias pp-ask, pp-explain, pp-fix, pp-ai-status, pp-ai-config
