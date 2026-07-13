# PS-PowerPrompt

Entorno personalizado para PowerShell orientado a productividad, trazabilidad de sesiones y asistencia inteligente.

## Objetivo

PS-PowerPrompt busca convertir una sesión normal de PowerShell en un entorno de trabajo más claro, portable y fácil de compartir con personas o con herramientas de inteligencia artificial.

La prioridad inicial del proyecto es resolver dos necesidades:

1. Exportar de forma sencilla lo que ocurre en la terminal, sin tener que seleccionar, copiar y pegar manualmente.
2. Iniciar cada sesión con un asistente básico que salude al usuario, prepare el entorno de trabajo y deje lista la captura de la sesión.

## Alcance inicial

### 1. Captura y exportación de la sesión

El sistema deberá poder registrar:

- Comandos ejecutados.
- Salida estándar.
- Mensajes de error.
- Fecha y hora de inicio y fin.
- Equipo y usuario de la sesión.
- Ruta de trabajo actual.
- Versión de PowerShell.

La exportación deberá generarse en formatos fáciles de leer tanto por personas como por inteligencias artificiales.

Formatos previstos para el MVP:

- `TXT`: copia legible de la sesión.
- `MD`: sesión estructurada en Markdown.
- `JSONL`: eventos de consola línea por línea, útiles para procesamiento automático.

Ejemplo conceptual de una sesión en Markdown:

```markdown
# Sesión de PowerShell

- Inicio: 2026-07-13 10:30:00
- Equipo: SISTEMAS
- PowerShell: 7.6.3
- Ruta inicial: C:\Proyectos

## Comando

```powershell
composer install
```

## Salida

```text
Installing dependencies...
```

## Estado

Código de salida: 0
```

### 2. Asistente de inicio

En la primera versión, el asistente no modificará comandos ni tomará decisiones por el usuario.

Su función será:

- Saludar al usuario.
- Mostrar la fecha y hora.
- Indicar la ruta actual.
- Detectar la versión de PowerShell.
- Confirmar que la sesión se está registrando.
- Crear una carpeta de trabajo para los registros.
- Mostrar comandos rápidos disponibles.

Ejemplo esperado:

```text
Hola, Juan Pablo.
Tu sesión de trabajo ha comenzado.
PowerShell 7.6.3
Ruta actual: C:\Proyectos\PS-PowerPrompt
Registro activo: Documents\PowerPrompt\Sessions\2026-07-13_10-30-00
```

## Visión futura del asistente

En fases posteriores, el asistente podrá:

- Explicar comandos antes de ejecutarlos.
- Detectar errores frecuentes.
- Sugerir correcciones.
- Proponer comandos más seguros o eficientes.
- Resumir la sesión.
- Preparar automáticamente contexto para enviarlo a una IA.
- Ocultar o anonimizar datos sensibles antes de exportar.
- Integrarse con una API de inteligencia artificial.

## Arquitectura propuesta

```text
PS-PowerPrompt/
├── install.bat
├── install.ps1
├── update.ps1
├── uninstall.ps1
├── profile/
│   └── Microsoft.PowerShell_profile.ps1
├── modules/
│   └── PowerPrompt/
│       ├── PowerPrompt.psd1
│       ├── PowerPrompt.psm1
│       ├── Public/
│       └── Private/
├── config/
│   └── settings.example.json
├── themes/
│   └── powerprompt.omp.json
├── docs/
└── README.md
```

## Responsabilidad de cada componente

### `install.bat`

Punto de entrada para usuarios que prefieran hacer doble clic.

Su responsabilidad será mínima:

- Comprobar que PowerShell está disponible.
- Lanzar `install.ps1` con los parámetros adecuados.
- Mostrar un mensaje claro si ocurre un error.

### `install.ps1`

Contendrá la lógica principal de instalación:

- Verificar PowerShell 7.
- Verificar Windows Terminal.
- Instalar dependencias faltantes.
- Crear copias de seguridad del perfil existente.
- Copiar el módulo y la configuración.
- Registrar el perfil de PS-PowerPrompt.
- Validar que la instalación haya quedado operativa.

### Perfil de PowerShell

El perfil cargará el módulo y ejecutará el inicio de sesión de PS-PowerPrompt.

### Módulo `PowerPrompt`

Contendrá las funciones reutilizables del proyecto, por ejemplo:

- `Start-PowerPromptSession`
- `Stop-PowerPromptSession`
- `Export-PowerPromptSession`
- `Show-PowerPromptWelcome`
- `Get-PowerPromptStatus`

## Principios del proyecto

- La instalación debe ser repetible.
- El instalador debe poder ejecutarse en otro computador.
- El perfil existente del usuario no debe perderse.
- Toda modificación debe crear una copia de seguridad.
- Los archivos generados deben ser legibles sin depender de software propietario.
- No se deben guardar contraseñas, tokens ni secretos sin advertencia.
- El usuario debe mantener el control de los comandos ejecutados.
- El asistente no ejecutará correcciones automáticamente en las primeras versiones.

## MVP propuesto

La primera versión funcional deberá:

- Instalar PowerShell 7 si no está disponible.
- Preparar el perfil del usuario.
- Saludar al abrir PowerShell.
- Crear una carpeta por sesión.
- Iniciar una transcripción automáticamente.
- Guardar metadatos básicos de la sesión.
- Detener y cerrar correctamente el registro.
- Exportar la sesión a Markdown.
- Incluir un comando para abrir la carpeta de la sesión.

Comandos previstos:

```powershell
pp-status
pp-export
pp-open
pp-stop
pp-help
```

## Hoja de ruta

### Fase 1. Base del proyecto

- Definir arquitectura.
- Crear instalador inicial.
- Crear módulo de PowerShell.
- Crear saludo de inicio.
- Crear registro automático por sesión.

### Fase 2. Exportación para IA

- Convertir la sesión a Markdown.
- Generar eventos en JSONL.
- Separar comandos, salida y errores.
- Agregar metadatos del entorno.

### Fase 3. Asistente local

- Ayuda contextual sobre comandos.
- Sugerencias sin ejecución automática.
- Resumen de errores de la sesión.

### Fase 4. Integración con IA

- Integración opcional mediante API.
- Resumen automático de sesiones.
- Sugerencias de corrección.
- Sanitización de información sensible.

## Estado actual

Proyecto en etapa inicial de definición y construcción del MVP.

## Convención de commits

Se utilizarán mensajes de commit breves y descriptivos:

```text
docs: define project vision and initial MVP
feat: add session startup greeting
feat: add automatic transcript capture
feat: add markdown session export
fix: preserve existing PowerShell profile
```

## Licencia

Pendiente por definir.
