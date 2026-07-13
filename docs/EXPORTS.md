# Exportaciones para IA

PS-PowerPrompt ofrece varios formatos de salida según el uso esperado.

## Markdown

```powershell
pp-export -Format Markdown
```

Formato recomendado para revisar una sesión o pegarla en una conversación con una IA.

## Texto

```powershell
pp-export -Format Text
```

Conserva la transcripción como texto plano.

## JSON

```powershell
pp-export -Format Json
```

Incluye metadatos de la sesión y la transcripción completa en una estructura JSON.

## JSONL estructurado

```powershell
pp-export-jsonl
```

Genera un archivo `.jsonl` con:

- un evento inicial `session_metadata`;
- un evento `transcript_line` por cada línea registrada;
- un campo `sequence` para conservar el orden.

Este formato facilita el procesamiento por lotes, indexación y consumo por otras aplicaciones o modelos de IA.

Para aplicar sanitización preventiva durante la generación:

```powershell
pp-export-jsonl -Sanitize
```

## Exportación protegida

```powershell
pp-export-safe
```

Genera la exportación habitual y oculta patrones frecuentes asociados con:

- contraseñas;
- tokens de acceso;
- API keys;
- secretos de cliente;
- encabezados `Authorization`;
- credenciales incluidas en algunas cadenas de conexión.

La sanitización automática es preventiva. Siempre se debe revisar el archivo antes de compartirlo, porque ningún conjunto de expresiones regulares puede reconocer todos los secretos posibles.
