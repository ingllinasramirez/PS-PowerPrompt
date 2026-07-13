@echo off
setlocal
chcp 65001 >nul

title PS-PowerPrompt Installer

set "SCRIPT_DIR=%~dp0"
set "INSTALL_SCRIPT=%SCRIPT_DIR%install.ps1"

if not exist "%INSTALL_SCRIPT%" (
    echo [ERROR] No se encontro install.ps1 en:
    echo %INSTALL_SCRIPT%
    pause
    exit /b 1
)

echo.
echo ========================================
echo       PS-PowerPrompt Installer
echo ========================================
echo.

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
        echo Cierra esta ventana y ejecuta install.bat nuevamente.
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
