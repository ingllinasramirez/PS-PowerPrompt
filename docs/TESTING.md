# Primera prueba local

## Requisitos

- Windows 10 u 11.
- PowerShell 7 instalado.
- Acceso a Internet solo para descargar el repositorio.

## Instalacion

1. Descarga el repositorio como ZIP desde GitHub.
2. Descomprime el archivo en una carpeta local.
3. Ejecuta `install.bat` con doble clic.
4. Espera el mensaje `Instalacion finalizada correctamente`.
5. Cierra la ventana del instalador.
6. Abre PowerShell 7, no Windows PowerShell 5.1.

Al abrir PowerShell 7 debe aparecer el saludo de PowerPrompt y la confirmacion de que la sesion fue iniciada.

## Prueba funcional

Ejecuta los siguientes comandos, uno por uno:

```powershell
pp-status
Get-Date
Get-Location
Get-ChildItem
pp-export
```

`pp-export` debe crear un archivo Markdown dentro de:

```text
%USERPROFILE%\Documents\PS-PowerPrompt\Exports
```

El archivo contiene metadatos y la transcripcion en un bloque de texto, listo para adjuntarlo o copiarlo a una IA.

Luego ejecuta:

```powershell
pp-open
```

Debe abrir el archivo exportado mas reciente.

Para finalizar manualmente la captura:

```powershell
pp-stop
```

## Formatos adicionales

```powershell
pp-export -Format Text
pp-export -Format Json
```

## Validacion del perfil

El instalador agrega un bloque delimitado al perfil actual de PowerShell 7 y crea antes una copia de seguridad con un nombre similar a:

```text
Microsoft.PowerShell_profile.ps1.backup-20260713-103000
```

El instalador no reemplaza el contenido previo del perfil.

## Reporte de fallas

Ante un error, comparte:

- Captura de la ventana.
- Resultado de `$PSVersionTable`.
- Resultado de `$PROFILE.CurrentUserCurrentHost`.
- Archivo mas reciente de `Documents\PS-PowerPrompt\Sessions`.
