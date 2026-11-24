@echo off
setlocal
title XCL Atualizado b7aa9f3
set "modo="
if /i "%~1"=="--verificar" set "modo=-Verificar"
echo Iniciando XCL puro b7aa9f3...
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0Iniciar-XCL-Puro.ps1" %modo%
set "resultado=%errorlevel%"
if not "%resultado%"=="0" (
    echo.
    echo O XCL atualizado retornou o codigo %resultado%.
    pause
)
exit /b %resultado%


