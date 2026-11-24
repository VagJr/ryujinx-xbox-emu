@echo off
setlocal
title VIctory com XCL ffe310e
set "modo="
echo Iniciando VIctory atualizado ffe310eb2098 com XCL...
if /i "%~1"=="--verificar" set "modo=-Verificar"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0victory-test\Iniciar-VIctory.ps1" -IntegracaoXcl %modo%
set "resultado=%errorlevel%"
if not "%resultado%"=="0" (
    echo.
    echo O VIctory com XCL retornou o codigo %resultado%.
    pause
)
exit /b %resultado%

