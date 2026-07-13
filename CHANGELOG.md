# Historial de cambios

Todos los cambios relevantes de PS-PowerPrompt se documentan en este archivo.

## En desarrollo

### Agregado

- Instalador mediante `install.bat` e `install.ps1`.
- Verificación e instalación de PowerShell 7.
- Configuración interactiva de nombre, carpetas, formatos, sonidos y panel.
- Registro automático de sesiones mediante `Start-Transcript`.
- Exportación a Markdown, texto y JSON.
- Panel flotante para exportar y abrir archivos.
- Menú contextual `Iniciar PowerPrompt desde aquí`.
- Variables temporales de sesión mediante `pp-set`, `pp-vars`, `pp-unset` y `pp-go`.
- Sonido personalizado `aparicion.mp3` al iniciar una sesión.
- Sonidos del sistema para confirmaciones, errores, navegación y variables.
- Comando `pp-help` para consultar la ayuda dentro de PowerShell.
- Comando `pp-new` para crear una sesión nueva sin cerrar la terminal.
- Comando `pp-restart` para reiniciar la sesión conservando variables personalizadas.

### Corregido

- Carga duplicada del perfil de PowerShell.
- Instalador truncado que impedía mostrar la configuración.
- Copia y detección del archivo de sonido.
- Reproductor de MP3 que podía permanecer bloqueado.
- Registro del perfil global del usuario sin sobrescribir configuraciones existentes.

### Documentación

- Visión, alcance y arquitectura inicial en `README.md`.
- Guía de pruebas en `docs/TESTING.md`.
- Referencia de comandos en `docs/COMMANDS.md`.

## Estado actual

El proyecto se encuentra en una etapa de MVP funcional. Ya permite iniciar, registrar, reiniciar y exportar sesiones de PowerShell, además de ofrecer accesos rápidos, sonidos y un asistente básico de bienvenida.
