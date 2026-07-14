# Asistencia inteligente de PS-PowerPrompt

La version 0.6.0 agrega una capa opcional de asistencia inteligente. PowerPrompt no ejecuta automaticamente los comandos sugeridos por un modelo.

## Comandos

```powershell
pp-ask "Como reviso los puertos ocupados en Windows?"
pp-explain "Get-Process | Sort-Object CPU -Descending | Select-Object -First 10"
pp-fix
pp-ai-status
```

## Proveedores

- `WindowsCopilot`: abre Copilot de Windows y copia el prompt al portapapeles. La respuesta se gestiona en la aplicacion de Copilot.
- `OpenAI`: API compatible con Chat Completions.
- `DeepSeek`: API compatible con OpenAI.
- `Gemini`: API `generateContent`.
- `HuggingFace`: router de inferencia compatible con Chat Completions.
- `Custom`: cualquier servicio compatible con el formato de Chat Completions.

## Configuracion

La clave nunca se guarda dentro de `settings.json`. `pp-ai-config` la almacena como variable de entorno del usuario.

```powershell
pp-ai-config OpenAI -ApiKey "TU_CLAVE" -Model "gpt-4.1-mini" -SetDefault
pp-ai-config DeepSeek -ApiKey "TU_CLAVE" -Model "deepseek-chat" -SetDefault
pp-ai-config Gemini -ApiKey "TU_CLAVE" -Model "gemini-2.5-flash" -SetDefault
pp-ai-config HuggingFace -ApiKey "TU_TOKEN" -Model "Qwen/Qwen2.5-Coder-32B-Instruct" -SetDefault
```

Para un endpoint compatible personalizado:

```powershell
pp-ai-config Custom `
  -ApiKey "TU_CLAVE" `
  -Endpoint "https://servidor.example/v1/chat/completions" `
  -Model "modelo-local" `
  -SetDefault
```

## Variables de entorno

| Proveedor | Variable |
|---|---|
| OpenAI | `PP_OPENAI_API_KEY` |
| DeepSeek | `PP_DEEPSEEK_API_KEY` |
| Gemini | `PP_GEMINI_API_KEY` |
| HuggingFace | `PP_HUGGINGFACE_API_KEY` |
| Custom | `PP_CUSTOM_AI_API_KEY` |

## Seguridad

- Revisa siempre los comandos sugeridos.
- No pegues secretos dentro de `pp-ask`.
- Usa `pp-export-safe` antes de compartir una sesion.
- PowerPrompt no ejecuta de forma automatica las respuestas generadas por IA.
