@echo off
setlocal
chcp 65001 >nul

title PS-PowerPrompt Installer v0.5.1

set "SCRIPT_DIR=%~dp0"
set "INSTALL_SCRIPT=%SCRIPT_DIR%install.ps1"
set "ASSET_FILE=%SCRIPT_DIR%assets\aparicion.mp3"
set "PLAYER_SCRIPT=%SCRIPT_DIR%scripts\Play-PowerPromptStartupSound.ps1"

echo.
echo ========================================
echo       PS-PowerPrompt Installer v0.5.1
echo ========================================
echo.
echo Carpeta del instalador:
echo %SCRIPT_DIR%
echo.

if not exist "%INSTALL_SCRIPT%" (
    echo [ERROR] No se encontro install.ps1 en:
    echo %INSTALL_SCRIPT%
    pause
    exit /b 1
)

if not exist "%ASSET_FILE%" (
    echo [ERROR] No se encontro el sonido:
    echo %ASSET_FILE%
    echo Descarga o actualiza el repositorio completo antes de instalar.
    pause
    exit /b 1
)

if not exist "%PLAYER_SCRIPT%" (
    echo [ERROR] No se encontro el reproductor:
    echo %PLAYER_SCRIPT%
    echo Descarga o actualiza el repositorio completo antes de instalar.
    pause
    exit /b 1
)

echo El instalador hara preguntas de configuracion.
echo Presiona Enter para usar cada valor predeterminado.
echo.
pause

where pwsh >nul 2>&1
if %errorlevel% equ 0 (
    pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_SCRIPT%"
) else (
    echo PowerShell 7 no esta disponible. Intentando instalarlo con winget...
    where winget >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] winget no esta disponible.
        echo Instala PowerShell 7 manualmente y vuelve a ejecutar este archivo.
        pause
        exit /b 1
    )

    winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements
    if errorlevel 1 (
        echo [ERROR] No fue posible instalar PowerShell 7.
        pause
        exit /b 1
    )

    set "PWSH=%ProgramFiles%\PowerShell\7\pwsh.exe"
    if not exist "%PWSH%" (
        echo [ERROR] PowerShell 7 fue instalado, pero no se encontro pwsh.exe.
        pause
        exit /b 1
    )

    "%PWSH%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_SCRIPT%"
)

set "EXIT_CODE=%errorlevel%"
echo.
if "%EXIT_CODE%"=="0" (
    echo Instalacion finalizada correctamente.
) else (
    echo La instalacion termino con errores. Codigo: %EXIT_CODE%
)
echo.
pause
exit /b %EXIT_CODE%