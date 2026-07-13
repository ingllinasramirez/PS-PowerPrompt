# Historial de cambios

Todos los cambios relevantes de PS-PowerPrompt se documentan en este archivo.

## 0.5.0-beta

### Agregado

- Instalador mediante `install.bat` e `install.ps1`.
- Verificación e instalación de PowerShell 7.
- Configuración interactiva de nombre, carpetas, formatos, sonidos y panel.
- Registro automático de sesiones mediante `Start-Transcript`.
- Exportación a Markdown, texto y JSON.
- Exportación protegida mediante `pp-export-safe`.
- Sanitización preventiva de contraseñas, tokens, API keys, encabezados de autorización y credenciales frecuentes en cadenas de conexión.
- Panel flotante para exportar y abrir archivos.
- Menú contextual `Iniciar PowerPrompt desde aquí`.
- Variables temporales de sesión mediante `pp-set`, `pp-vars`, `pp-unset` y `pp-go`.
- Sonido personalizado `aparicion.mp3` al iniciar una sesión.
- Sonidos del sistema para confirmaciones, errores, navegación y variables.
- Comando `pp-help` para consultar la ayuda dentro de PowerShell.
- Comando `pp-new` para crear una sesión nueva sin cerrar la terminal.
- Comando `pp-restart` para reiniciar la sesión conservando variables personalizadas.
- Comando `pp-doctor` para revisar el estado de la instalación.
- Comando `pp-update` para actualizar desde GitHub conservando la configuración y creando respaldo.
- Comando `pp-uninstall` para retirar PowerPrompt y conservar o eliminar los datos según la opción elegida.
- Pruebas automáticas de archivos requeridos, sintaxis, manifiesto, importación y comandos exportados.
- Flujo de GitHub Actions para ejecutar las pruebas en Windows.

### Corregido

- Carga duplicada del perfil de PowerShell.
- Instalador truncado que impedía mostrar la configuración.
- Copia y detección del archivo de sonido.
- Reproductor de MP3 que podía permanecer bloqueado.
- Registro del perfil global del usuario sin sobrescribir configuraciones existentes.
- Ejecución de las pruebas del actualizador en un proceso aislado para evitar cerrar prematuramente la actualización.
- Exportación de los alias de mantenimiento `pp-doctor`, `pp-update`, `pp-uninstall` y `pp-export-safe` desde el módulo principal.

### Documentación

- Guía principal de instalación y uso en `README.md`.
- Guía de pruebas en `docs/TESTING.md`.
- Referencia de comandos en `docs/COMMANDS.md`.
- Guía de formatos y sanitización en `docs/EXPORTS.md`.
- Notas de cierre en `docs/RELEASE-0.5.0-beta.md`.

## Estado actual

La versión `0.5.0-beta` cubre el MVP funcional: instalación, captura de sesiones, exportación para IA, rutas rápidas, reinicio de sesiones, ayuda, sonidos, diagnóstico, actualización, desinstalación y protección preventiva de información sensible.

La sanitización automática es una ayuda de seguridad y no sustituye la revisión humana antes de compartir archivos.
