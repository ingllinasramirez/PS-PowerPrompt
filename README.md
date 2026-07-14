# PS-PowerPrompt

Entorno profesional para PowerShell 7 que inicia una sesión de trabajo, registra comandos, salidas y errores, permite exportar la actividad y agrega asistencia inteligente local o mediante proveedores externos.

**Versión actual:** `0.7.0`

Desarrollado por **Ingeniero Juan Pablo Llinás Ramírez – Puro Ingenio Samario**.

## Características principales

- Bienvenida corporativa al abrir PowerShell.
- Captura automática de sesiones mediante `Start-Transcript`.
- Exportación en Markdown, texto, JSON y JSONL.
- Exportación protegida para ocultar patrones frecuentes de datos sensibles.
- Variables temporales para guardar rutas y navegar rápidamente.
- Panel flotante y menú contextual de Windows.
- Diagnóstico, actualización y desinstalación.
- Asistencia inteligente local con Ollama.
- Compatibilidad opcional con Windows Copilot, OpenAI, DeepSeek, Gemini, Hugging Face y endpoints personalizados.

## Asistencia inteligente local

La opción recomendada es **Ollama** con el modelo:

```text
qwen2.5-coder:3b
```

Durante la instalación, PS-PowerPrompt puede:

1. Detectar si Ollama ya está instalado.
2. Instalar Ollama automáticamente con `winget`.
3. Iniciar su API local.
4. Descargar el modelo recomendado.
5. Ejecutar una consulta de validación.
6. Configurar Ollama como proveedor predeterminado.

Después de completar la instalación, las respuestas aparecen directamente dentro de PowerShell.

## Requisitos

- Windows 10 u 11.
- PowerShell 7 o superior.
- `winget` para la instalación automática de Ollama.
- Conexión a Internet durante la instalación inicial y descarga del modelo.
- Espacio disponible para el modelo local.

## Instalación

Clona el repositorio:

```powershell
git clone https://github.com/ingllinasramirez/PS-PowerPrompt.git
cd PS-PowerPrompt
```

Ejecuta las pruebas:

```powershell
pwsh -NoLogo -NoProfile -File .\scripts\Test-PSPowerPrompt.ps1
```

Ejecuta el instalador:

```powershell
.\install.ps1
```

Para instalar y configurar la IA local, acepta esta opción:

```text
¿Instalar y configurar la asistencia inteligente local con Ollama? [S/n]
```

La descarga de `qwen2.5-coder:3b` puede tardar varios minutos.

## Comandos de sesión

```powershell
pp-status
pp-new
pp-restart
pp-stop
pp-help
```

## Comandos de exportación

```powershell
pp-export
pp-export -Format Markdown
pp-export -Format Text
pp-export -Format Json
pp-export-safe
pp-export-jsonl
pp-export-jsonl -Sanitize
pp-open
pp-panel
```

## Variables y navegación

```powershell
pp-set PROYECTO "C:\Proyectos\MiApp"
pp-vars
pp-vars PROYECTO
pp-go PROYECTO
pp-unset PROYECTO
```

Las variables también quedan disponibles como variables de entorno:

```powershell
$env:PP_PROYECTO
```

## Comandos de inteligencia artificial

Consultar al proveedor configurado:

```powershell
pp-ask "Explícame la estructura de este proyecto"
```

Explicar un comando:

```powershell
pp-explain "Get-ChildItem -Recurse | Sort-Object Length -Descending"
```

Analizar el último error:

```powershell
pp-fix
```

Consultar el estado de los proveedores:

```powershell
pp-ai-status
```

Configurar Ollama como proveedor predeterminado:

```powershell
pp-ai-config Ollama -Model "qwen2.5-coder:3b" -SetDefault
```

Configurar un proveedor externo:

```powershell
pp-ai-config OpenAI -ApiKey "TU_CLAVE" -Model "gpt-4.1-mini" -SetDefault
pp-ai-config DeepSeek -ApiKey "TU_CLAVE" -Model "deepseek-chat" -SetDefault
pp-ai-config Gemini -ApiKey "TU_CLAVE" -Model "gemini-2.5-flash" -SetDefault
pp-ai-config HuggingFace -ApiKey "TU_TOKEN" -Model "Qwen/Qwen2.5-Coder-32B-Instruct" -SetDefault
```

Las claves se almacenan como variables de entorno del usuario y no dentro de `settings.json`.

## Proveedores disponibles

- `Ollama`: modelo local, gratuito y con respuesta directa en PowerShell.
- `WindowsCopilot`: abre Copilot y copia el prompt; la respuesta se consulta manualmente.
- `OpenAI`: API compatible con Chat Completions.
- `DeepSeek`: API compatible con OpenAI.
- `Gemini`: API `generateContent`.
- `HuggingFace`: router de inferencia compatible con Chat Completions.
- `Custom`: endpoint personalizado compatible con Chat Completions.

## Mantenimiento

```powershell
pp-doctor
pp-update
pp-uninstall
pp-uninstall -RemoveData
```

## Actualización

Desde una instalación existente:

```powershell
pp-update
```

Desde el repositorio local:

```powershell
git pull origin main
.\install.ps1
```

## Seguridad

- PS-PowerPrompt no ejecuta automáticamente los comandos sugeridos por una IA.
- Revisa siempre cualquier comando antes de ejecutarlo.
- No incluyas contraseñas, tokens o claves dentro de `pp-ask`.
- Usa `pp-export-safe` o `pp-export-jsonl -Sanitize` antes de compartir una sesión.

## Documentación adicional

- `docs/AI.md`: configuración y uso de proveedores de inteligencia artificial.
- `docs/COMMANDS.md`: referencia de comandos.
- `docs/EXPORT-FORMATS.md`: formatos de exportación.
- `docs/TESTING.md`: ejecución de pruebas.
- `CHANGELOG.md`: historial de cambios.

## Licencia

Pendiente de definición.
