@echo off
setlocal
title VIctory Puro ffe310e
set "modo="
if /i "%~1"=="--verificar" set "modo=-Verificar"
echo Iniciando VIctory puro ffe310eb2098...
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0victory-test\Iniciar-VIctory.ps1" %modo%
set "resultado=%errorlevel%"
if not "%resultado%"=="0" (
    echo.
    echo VIctory puro retornou o codigo %resultado%.
    pause
)
exit /b %resultado%
