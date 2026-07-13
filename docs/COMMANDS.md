# Referencia de comandos de PS-PowerPrompt

Esta guía describe los comandos disponibles en la versión actual del módulo.

## Sesiones

### `pp-status`

Muestra el identificador, hora de inicio, duración, estado de captura, archivo de transcripción, directorio actual y versión de PowerShell.

```powershell
pp-status
```

### `pp-new`

Finaliza la captura actual y crea una sesión completamente nueva en la misma ventana.

Las variables personalizadas creadas con `pp-set` se eliminan.

```powershell
pp-new
```

### `pp-restart`

Reinicia la sesión en la misma ventana y conserva las variables personalizadas creadas con `pp-set`.

```powershell
pp-restart
```

### `pp-stop`

Detiene la captura de la sesión actual sin cerrar PowerShell.

```powershell
pp-stop
```

### `pp-start`

Inicia la captura cuando no existe una sesión activa.

```powershell
pp-start
```

## Ayuda

### `pp-help`

Muestra dentro de PowerShell la lista de comandos, descripciones y ejemplos principales.

```powershell
pp-help
```

## Exportación

### `pp-export`

Exporta la sesión actual usando el formato predeterminado configurado durante la instalación.

```powershell
pp-export
```

También se puede indicar el formato:

```powershell
pp-export -Format Markdown
pp-export -Format Text
pp-export -Format Json
```

### `pp-open`

Abre el último archivo exportado. Si no existe, intenta abrir la última transcripción.

```powershell
pp-open
```

### `pp-panel`

Abre el panel flotante de PS-PowerPrompt.

```powershell
pp-panel
```

## Variables de sesión

### `pp-set`

Guarda una ruta o valor con un nombre corto durante la sesión.

```powershell
pp-set RUTAC "C:\Proyectos\rutac_admin"
```

También crea una variable de entorno con el prefijo `PP_`:

```powershell
$env:PP_RUTAC
```

### `pp-vars`

Lista todas las variables disponibles.

```powershell
pp-vars
```

Consultar una variable:

```powershell
pp-vars RUTAC
```

### `pp-unset`

Elimina una variable personalizada.

```powershell
pp-unset RUTAC
```

### `pp-go`

Cambia el directorio actual usando una variable o una ruta directa.

```powershell
pp-go RUTAC
pp-go "C:\Proyectos\otro-proyecto"
```

## Diferencia entre `pp-new` y `pp-restart`

| Comando | Crea nueva captura | Conserva variables personalizadas |
|---|---:|---:|
| `pp-new` | Sí | No |
| `pp-restart` | Sí | Sí |

Ambos comandos permiten comenzar otra sesión sin cerrar ni volver a abrir PowerShell.
