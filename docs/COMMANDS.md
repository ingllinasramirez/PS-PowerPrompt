# Referencia de comandos de PS-PowerPrompt

Esta guía describe los comandos disponibles en PS-PowerPrompt `0.7.0`.

## Sesiones

### `pp-status`

Muestra el identificador, hora de inicio, duración, estado de captura, archivo de transcripción, directorio actual y versión de PowerShell.

```powershell
pp-status
```

### `pp-new`

Finaliza la captura actual y crea una sesión nueva. Elimina las variables personalizadas creadas con `pp-set`.

```powershell
pp-new
```

### `pp-restart`

Reinicia la sesión conservando las variables personalizadas.

```powershell
pp-restart
```

### `pp-stop`

Detiene la captura sin cerrar PowerShell.

```powershell
pp-stop
```

### `pp-start`

Inicia una nueva captura cuando no existe una sesión activa.

```powershell
pp-start
```

## Ayuda y diagnóstico

### `pp-help`

Muestra la lista de comandos, descripciones, ejemplos y el proveedor de IA local recomendado.

```powershell
pp-help
```

### `pp-doctor`

Verifica instalación, configuración, perfil, scripts y comandos principales.

```powershell
pp-doctor
```

## Exportación

### `pp-export`

Exporta la sesión actual usando el formato predeterminado.

```powershell
pp-export
pp-export -Format Markdown
pp-export -Format Text
pp-export -Format Json
```

### `pp-export-safe`

Exporta la sesión y oculta patrones frecuentes de contraseñas, tokens, API keys y encabezados de autorización.

```powershell
pp-export-safe
pp-export-safe -Format Markdown
```

### `pp-export-jsonl`

Exporta la sesión como eventos JSONL, útil para análisis automatizado, agentes y procesamiento por lotes.

```powershell
pp-export-jsonl
pp-export-jsonl -Sanitize
```

### `pp-open`

Abre el último archivo exportado o la última transcripción disponible.

```powershell
pp-open
```

### `pp-panel`

Abre el panel flotante.

```powershell
pp-panel
```

## Variables y navegación

### `pp-set`

Guarda una ruta o valor con un nombre corto.

```powershell
pp-set RUTAC "C:\Proyectos\rutac_admin"
```

También crea una variable de entorno:

```powershell
$env:PP_RUTAC
```

### `pp-vars`

Lista o consulta variables temporales.

```powershell
pp-vars
pp-vars RUTAC
```

### `pp-unset`

Elimina una variable personalizada.

```powershell
pp-unset RUTAC
```

### `pp-go`

Cambia el directorio usando una variable o una ruta directa.

```powershell
pp-go RUTAC
pp-go "C:\Proyectos\otro-proyecto"
```

## Inteligencia artificial

### `pp-ask`

Envía una consulta al proveedor configurado. Con Ollama, la respuesta aparece directamente en la terminal.

```powershell
pp-ask "Explícame la estructura de este proyecto"
pp-ask "Genera un comando seguro para listar archivos grandes"
```

También se puede seleccionar un proveedor específico:

```powershell
pp-ask "Explica este error" -Provider Ollama
pp-ask "Explica este error" -Provider Gemini
```

### `pp-explain`

Explica un comando de PowerShell, sus partes, riesgos y posibles alternativas.

```powershell
pp-explain "Get-ChildItem -Recurse | Sort-Object Length -Descending"
```

### `pp-fix`

Analiza el último error almacenado en `$Error` y propone una solución segura.

```powershell
pp-fix
pp-fix -Provider Ollama
```

### `pp-ai-status`

Muestra los proveedores registrados, modelo configurado, disponibilidad de credenciales y proveedor predeterminado.

```powershell
pp-ai-status
```

### `pp-ai-config`

Configura un proveedor y opcionalmente lo establece como predeterminado.

Ollama local:

```powershell
pp-ai-config Ollama -Model "qwen2.5-coder:3b" -SetDefault
```

OpenAI:

```powershell
pp-ai-config OpenAI -ApiKey "TU_CLAVE" -Model "gpt-4.1-mini" -SetDefault
```

DeepSeek:

```powershell
pp-ai-config DeepSeek -ApiKey "TU_CLAVE" -Model "deepseek-chat" -SetDefault
```

Gemini:

```powershell
pp-ai-config Gemini -ApiKey "TU_CLAVE" -Model "gemini-2.5-flash" -SetDefault
```

Hugging Face:

```powershell
pp-ai-config HuggingFace -ApiKey "TU_TOKEN" -Model "Qwen/Qwen2.5-Coder-32B-Instruct" -SetDefault
```

Proveedor personalizado:

```powershell
pp-ai-config Custom `
    -ApiKey "TU_CLAVE" `
    -Endpoint "https://servidor.example/v1/chat/completions" `
    -Model "modelo-personalizado" `
    -SetDefault
```

## Proveedores disponibles

| Proveedor | Respuesta directa | Requiere clave |
|---|---:|---:|
| Ollama | Sí | No |
| WindowsCopilot | No | No |
| OpenAI | Sí | Sí |
| DeepSeek | Sí | Sí |
| Gemini | Sí | Sí |
| HuggingFace | Sí | Sí |
| Custom | Sí | Depende del servicio |

## Mantenimiento

### `pp-update`

Descarga la rama principal, ejecuta pruebas, crea un respaldo y actualiza la instalación.

```powershell
pp-update
```

### `pp-uninstall`

Desinstala el módulo, scripts, panel, menú contextual y bloque del perfil.

```powershell
pp-uninstall
pp-uninstall -RemoveData
```

## Diferencia entre `pp-new` y `pp-restart`

| Comando | Crea nueva captura | Conserva variables personalizadas |
|---|---:|---:|
| `pp-new` | Sí | No |
| `pp-restart` | Sí | Sí |
