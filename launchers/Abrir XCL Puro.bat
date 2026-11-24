@echo off
setlocal
title XCL Atualizado 930e8b4
set "modo="
if /i "%~1"=="--verificar" set "modo=-Verificar"
echo Iniciando XCL 930e8b4...
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0xcl-puro\Iniciar-XCL-Puro.ps1" -SincronizacaoAtual %modo%
set "resultado=%errorlevel%"
if not "%resultado%"=="0" (
    echo.
    echo O XCL atualizado retornou o codigo %resultado%.
    pause
)
exit /b %resultado%


