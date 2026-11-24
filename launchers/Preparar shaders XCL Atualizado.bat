@echo off
setlocal
title Preparando shaders XCL b7aa9f3
echo Compilando shaders e pipelines para a RTX 3060...
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0Iniciar-XCL-Puro.ps1" -PrepararShaders -ThreadsDeCompilacao 8
set "resultado=%errorlevel%"
if not "%resultado%"=="0" (
    echo.
    echo A preparacao de shaders retornou o codigo %resultado%.
    pause
)
exit /b %resultado%
