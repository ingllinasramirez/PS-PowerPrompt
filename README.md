# PS-PowerPrompt

Entorno personalizado para PowerShell 7 que inicia una sesión de trabajo, registra lo que ocurre en la terminal y permite exportarlo fácilmente para revisión, soporte o uso con herramientas de inteligencia artificial.

**Versión actual:** `0.5.0-beta`

## Qué incluye

- Inicio automático de una sesión al abrir PowerShell.
- Registro de comandos, salidas y errores mediante `Start-Transcript`.
- Exportación en Markdown, texto y JSON.
- Exportación protegida para ocultar patrones frecuentes de información sensible.
- Reinicio o creación de una sesión nueva sin cerrar la terminal.
- Variables temporales para guardar rutas y navegar rápidamente.
- Panel flotante para exportar y abrir archivos.
- Menú contextual de Windows: **Iniciar PowerPrompt desde aquí**.
- Sonido personalizado al iniciar y sonidos del sistema para confirmaciones y errores.
- Comandos de diagnóstico, actualización y desinstalación.

## Requisitos

- Windows 10 u 11.
- PowerShell 7 o superior.
- Conexión a Internet durante la primera instalación si PowerShell 7 no está instalado.
- `winget` disponible si el instalador necesita instalar PowerShell 7 automáticamente.

## Instalación rápida

### 1. Descargar el proyecto

En GitHub, abre el repositorio y selecciona:

```text
Code > Download ZIP
```

Descomprime el archivo en una carpeta local.

También puedes clonarlo con Git:

```powershell
git clone https://github.com/ingllinasramirez/PS-PowerPrompt.git
cd PS-PowerPrompt
```

### 2. Ejecutar el instalador

Haz doble clic en:

```text
install.bat
```

También puedes ejecutarlo desde PowerShell:

```powershell
.\install.ps1
```

El instalador preguntará por:

- Nombre que se mostrará en el saludo.
- Carpeta de exportaciones.
- Carpeta de sesiones.
- Formato de exportación predeterminado.
- Reproducción del sonido de inicio.
- Apertura automática de archivos exportados.
- Inicio del panel flotante.
- Instalación del menú contextual de Windows.

Puedes presionar `Enter` para aceptar cada valor predeterminado.

### 3. Abrir PowerShell

Al finalizar, el instalador abrirá PowerShell 7. También puedes cerrar la ventana y abrir una terminal nueva.

Deberías ver un mensaje similar a este:

```text
[PowerPrompt] Buenos días, Juan.
Sesión de trabajo iniciada.
Sesión de trabajo iniciada: a1b2c3d4
Directorio: C:\Proyectos
PowerShell: 7.x
```

## Primeros comandos

Ver el estado de la sesión:

```powershell
pp-status
```

Mostrar la ayuda integrada:

```powershell
pp-help
```

Exportar la sesión actual:

```powershell
pp-export
```

Exportar ocultando patrones frecuentes de datos sensibles:

```powershell
pp-export-safe
```

Abrir el último archivo exportado:

```powershell
pp-open
```

## Comandos disponibles

### Sesiones

| Comando | Descripción |
|---|---|
| `pp-status` | Muestra el estado de la sesión actual. |
| `pp-new` | Finaliza la sesión actual y crea una nueva, eliminando variables personalizadas. |
| `pp-restart` | Reinicia la sesión y conserva las variables personalizadas. |
| `pp-stop` | Detiene la captura actual sin cerrar PowerShell. |
| `pp-start` | Inicia una captura cuando no hay una sesión activa. |
| `pp-help` | Muestra la ayuda y ejemplos dentro de PowerShell. |

### Exportación

| Comando | Descripción |
|---|---|
| `pp-export` | Exporta la sesión en el formato configurado. |
| `pp-export -Format Markdown` | Exporta en Markdown. |
| `pp-export -Format Text` | Exporta en texto plano. |
| `pp-export -Format Json` | Exporta en JSON. |
| `pp-export-safe` | Exporta y aplica sanitización preventiva. |
| `pp-open` | Abre el último archivo exportado o la última transcripción. |
| `pp-panel` | Abre el panel flotante. |

### Rutas y variables temporales

Guardar una ruta con un nombre corto:

```powershell
pp-set RUTAC "C:\Proyectos\rutac_admin"
```

Ir a esa ruta:

```powershell
pp-go RUTAC
```

Ver todas las variables:

```powershell
pp-vars
```

Consultar una variable específica:

```powershell
pp-vars RUTAC
```

Eliminarla:

```powershell
pp-unset RUTAC
```

Las variables creadas también quedan disponibles como variables de entorno con el prefijo `PP_`:

```powershell
$env:PP_RUTAC
```

### Mantenimiento

| Comando | Descripción |
|---|---|
| `pp-doctor` | Verifica archivos, configuración, perfil y comandos instalados. |
| `pp-update` | Descarga la última versión, ejecuta pruebas y conserva la configuración. |
| `pp-uninstall` | Desinstala PowerPrompt conservando sesiones, exportaciones y configuración. |
| `pp-uninstall -RemoveData` | Desinstala PowerPrompt y elimina también los datos configurados. |

## Actualización

Después de la primera instalación, puedes actualizar PowerPrompt con:

```powershell
pp-update
```

El actualizador:

1. Descarga la rama principal del repositorio.
2. Ejecuta las pruebas automáticas.
3. Crea un respaldo de los archivos instalados.
4. Actualiza módulos, scripts, panel y recursos.
5. Conserva tu archivo de configuración.

Al terminar, ejecuta:

```powershell
pp-restart
```

O abre una terminal nueva.

## Diagnóstico

Para revisar la instalación:

```powershell
pp-doctor
```

El comando valida, entre otros puntos:

- Carpeta de instalación.
- Archivo de configuración.
- Módulo principal y módulo de mantenimiento.
- Reproductor de sonido.
- Actualizador y desinstalador.
- Bloque de carga en el perfil de PowerShell.
- Disponibilidad de los comandos principales.

## Archivos generados

Por defecto, las sesiones y exportaciones se guardan dentro de:

```text
Documents\PS-PowerPrompt\Sessions
Documents\PS-PowerPrompt\Exports
```

Estas rutas pueden cambiarse durante la instalación.

La instalación del programa se guarda en:

```text
%USERPROFILE%\.ps-powerprompt
```

## Exportación segura

`pp-export-safe` intenta ocultar patrones frecuentes como:

- Contraseñas.
- API keys.
- Tokens de acceso.
- Encabezados `Authorization`.
- Credenciales en algunas cadenas de conexión.

Ejemplo:

```text
API_KEY=[REDACTED]
Authorization: Bearer [REDACTED]
```

Esta protección es preventiva. Revisa siempre el archivo antes de compartirlo.

## Menú contextual de Windows

Si habilitaste esta opción durante la instalación, puedes hacer clic derecho sobre una carpeta o dentro del fondo del Explorador y seleccionar:

```text
Iniciar PowerPrompt desde aquí
```

PowerPrompt abrirá una terminal ubicada directamente en esa carpeta.

## Sonidos

- Al iniciar una sesión se reproduce `assets/aparicion.mp3`.
- Las confirmaciones y errores usan sonidos del sistema de Windows.
- No se reproduce sonido al escribir ni al presionar `Enter`.

Los sonidos pueden activarse o desactivarse desde:

```text
%USERPROFILE%\.ps-powerprompt\config\settings.json
```

## Desinstalación

Conservar sesiones, exportaciones y configuración:

```powershell
pp-uninstall
```

Eliminar también los datos configurados:

```powershell
pp-uninstall -RemoveData
```

El desinstalador solicita confirmación antes de continuar.

## Pruebas del proyecto

Desde la carpeta del repositorio:

```powershell
pwsh -NoLogo -NoProfile -File .\scripts\Test-PSPowerPrompt.ps1
```

Las pruebas revisan:

- Archivos requeridos.
- Sintaxis de scripts y módulos.
- Validez del manifiesto.
- Importación del módulo.
- Disponibilidad de comandos.

## Documentación adicional

- [Referencia completa de comandos](docs/COMMANDS.md)
- [Formatos de exportación](docs/EXPORTS.md)
- [Guía de pruebas](docs/TESTING.md)
- [Historial de cambios](CHANGELOG.md)

## Solución de problemas

### El comando `pp-*` no existe

Cierra todas las ventanas de PowerShell y abre una nueva. Después ejecuta:

```powershell
pp-doctor
```

Si continúa el problema, ejecuta nuevamente `install.bat` desde la última versión del repositorio.

### No se escucha el sonido de inicio

Comprueba que existan los archivos:

```powershell
Test-Path "$HOME\.ps-powerprompt\assets\aparicion.mp3"
Test-Path "$HOME\.ps-powerprompt\scripts\Play-PowerPromptStartupSound.ps1"
```

Ambos resultados deben ser `True`.

### El saludo aparece dos veces

Ejecuta nuevamente el instalador. Este limpia bloques anteriores y deja la carga de PowerPrompt en el perfil global del usuario.

### PowerShell bloquea la ejecución del instalador

Ejecuta:

```powershell
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

## Estado del proyecto

`0.5.0-beta` cubre el MVP funcional: instalación, captura de sesiones, exportación, navegación por rutas, sonidos, ayuda, diagnóstico, actualización, desinstalación y sanitización preventiva.

La siguiente etapa prevista es mejorar el análisis estructurado de comandos, salidas y errores, y posteriormente incorporar asistencia inteligente opcional.

## Licencia

Pendiente por definir.
