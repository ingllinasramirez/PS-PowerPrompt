# Asistencia inteligente de PS-PowerPrompt

La version 0.7.0 incorpora asistencia inteligente local mediante Ollama. PowerPrompt no ejecuta automaticamente los comandos sugeridos por un modelo.

## Instalacion automatica

Al ejecutar `install.ps1` y aceptar la asistencia inteligente, el instalador:

1. Detecta Ollama.
2. Si no esta instalado, lo instala con `winget`.
3. Inicia la API local en `http://127.0.0.1:11434`.
4. Descarga el modelo `qwen2.5-coder:3b`.
5. Realiza una consulta de validacion.
6. Configura `Ollama` como proveedor predeterminado.

Despues de la instalacion basta con ejecutar:

```powershell
pp-ask "Como reviso los puertos ocupados en Windows?"
pp-explain "Get-Process | Sort-Object CPU -Descending | Select-Object -First 10"
pp-fix
pp-ai-status
```

## Proveedores

- `Ollama`: proveedor local, gratuito y predeterminado. La respuesta se muestra directamente en PowerShell.
- `WindowsCopilot`: abre Copilot y copia el prompt; PowerPrompt no puede recuperar su respuesta.
- `OpenAI`: API compatible con Chat Completions.
- `DeepSeek`: API compatible con OpenAI.
- `Gemini`: API `generateContent`.
- `HuggingFace`: router compatible con Chat Completions.
- `Custom`: endpoint compatible con Chat Completions.

## Cambiar el modelo local

```powershell
ollama pull qwen2.5-coder:7b
pp-ai-config Ollama -Model "qwen2.5-coder:7b" -SetDefault
```

## Configurar proveedores externos

Las claves nunca se guardan dentro de `settings.json`; se almacenan como variables de entorno del usuario.

```powershell
pp-ai-config OpenAI -ApiKey "TU_CLAVE" -Model "gpt-4.1-mini" -SetDefault
pp-ai-config DeepSeek -ApiKey "TU_CLAVE" -Model "deepseek-chat" -SetDefault
pp-ai-config Gemini -ApiKey "TU_CLAVE" -Model "gemini-2.5-flash" -SetDefault
pp-ai-config HuggingFace -ApiKey "TU_TOKEN" -Model "Qwen/Qwen2.5-Coder-32B-Instruct" -SetDefault
```

## Seguridad

- Revisa siempre los comandos sugeridos.
- No pegues secretos dentro de `pp-ask`.
- Usa `pp-export-safe` antes de compartir una sesion.
- PowerPrompt no ejecuta automaticamente las respuestas generadas por IA.
