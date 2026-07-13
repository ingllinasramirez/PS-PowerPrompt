# Cierre de la versión 0.5.0-beta

## Estado

La versión `0.5.0-beta` queda cerrada como MVP funcional de PS-PowerPrompt.

## Alcance entregado

- Instalación interactiva en Windows con PowerShell 7.
- Inicio automático de sesiones con saludo y transcripción.
- Exportación en Markdown, texto y JSON.
- Exportación protegida con sanitización preventiva.
- Reinicio y creación de nuevas sesiones sin cerrar la terminal.
- Variables temporales y navegación rápida por rutas.
- Panel flotante y menú contextual del Explorador.
- Sonido personalizado de inicio y sonidos del sistema para eventos.
- Ayuda integrada con `pp-help`.
- Diagnóstico con `pp-doctor`.
- Actualización con `pp-update`.
- Desinstalación con `pp-uninstall`.
- Pruebas automáticas y flujo de GitHub Actions para Windows.
- Documentación de instalación, uso, comandos, exportaciones y pruebas.

## Validación recomendada después de instalar

```powershell
pp-help
pp-status
pp-doctor
```

También se recomienda probar:

```powershell
pp-restart
pp-export
pp-export-safe
```

## Instalación

Para una instalación nueva o para actualizar una instalación que todavía no tenga `pp-update`:

1. Descargar la versión más reciente del repositorio.
2. Descomprimirla.
3. Ejecutar `install.bat`.
4. Cerrar las ventanas antiguas de PowerShell.
5. Abrir PowerShell 7 y ejecutar `pp-doctor`.

## Mantenimiento posterior

Actualizar:

```powershell
pp-update
```

Desinstalar conservando datos:

```powershell
pp-uninstall
```

Desinstalar eliminando también configuración, sesiones y exportaciones:

```powershell
pp-uninstall -RemoveData
```

## Consideraciones

- La versión se mantiene con etiqueta beta porque aún requiere validación en distintos equipos y configuraciones de Windows.
- La sanitización automática reduce riesgos, pero cada archivo debe revisarse antes de compartirse.
- Los sonidos dependen de la configuración de audio y de las capacidades multimedia del equipo.
- La integración con inteligencia artificial queda fuera de este MVP y corresponde a una etapa posterior.

## Documentos de referencia

- `README.md`
- `CHANGELOG.md`
- `docs/COMMANDS.md`
- `docs/EXPORTS.md`
- `docs/TESTING.md`
