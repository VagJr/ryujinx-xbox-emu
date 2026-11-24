[CmdletBinding()]
param(
    [switch] $PrepararShaders,
    [switch] $Diagnostico,
    [switch] $Verificar,
    [ValidateRange(1, 16)]
    [int] $ThreadsDeCompilacao = 8
)

$ErrorActionPreference = 'Stop'
$buildDir = 'build-b7aa9f3'
$bin = Join-Path $PSScriptRoot "$buildDir\release\xcl.exe"
if (!(Test-Path -LiteralPath $bin -PathType Leaf)) {
    $bin = Join-Path $PSScriptRoot '..\builds\xcl-puro\build-b7aa9f3__release__xcl.exe'
}
$game = 'C:\Users\vagmi\Downloads\GTA6.Xbox.v1.0.2.1-CYBERLEEK'
$gameExe = 'C:\Users\vagmi\Downloads\early_xmas\game_scarlett_master.exe'
$sdk = 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64'
$archive = Join-Path $game 'shaders.rpf'
$embeddedShaders = Join-Path $PSScriptRoot 'shaders-pe-early-xmas'
foreach ($file in @($bin, $gameExe, $archive, (Join-Path $sdk 'dxcompiler.dll'), (Join-Path $sdk 'dxil.dll'))) {
    if (!(Test-Path -LiteralPath $file -PathType Leaf)) { throw "Arquivo ausente. $file" }
}
if ($Verificar) {
    Write-Host "XCL puro pronto. $bin"
    return
}

$runtime = Join-Path $PSScriptRoot 'runtime'
$titleDir = Join-Path $runtime 'RockstarGamesInc.28872443D20A7'
New-Item -ItemType Directory -Path $titleDir -Force | Out-Null
$config = Join-Path $titleDir 'xcl.toml'
if (!(Test-Path -LiteralPath $config -PathType Leaf)) {
    $tomlExe = $gameExe.Replace('\', '\\')
    [IO.File]::WriteAllText($config, "exe = `"$tomlExe`"`n")
}

$previous = @{}
Get-ChildItem Env: | Where-Object Name -Like 'XCL_*' | ForEach-Object { $previous[$_.Name] = $_.Value }
try {
    foreach ($name in $previous.Keys) { [Environment]::SetEnvironmentVariable($name, $null, 'Process') }
    $env:XCL_DATA_ROOT = $runtime
    $env:XCL_DXIL_CACHE = Join-Path $PSScriptRoot 'dxil-sdk-1.8'
    $env:XCL_DXC_DIR = $sdk
    $env:XCL_ADAPTER = 'GeForce RTX 3060'
    $env:XCL_NETWORK = '0'
    $env:XCL_PSO_DISK_CACHE = '1'
    if ($PrepararShaders) {
        $env:XCL_DXC_THREADS = [string] $ThreadsDeCompilacao
        $env:XCL_PIPELINE_THREADS = '2'
        $shaderInputs = @($archive)
        if (Test-Path -LiteralPath $embeddedShaders -PathType Container) {
            $shaderInputs = @($embeddedShaders) + $shaderInputs
        }
        foreach ($shaderInput in $shaderInputs) {
            $options = @('--precompile', '--windows', '4', '--split', '1')
            if ($shaderInput -eq $embeddedShaders) { $options += '--pipelines' }
            & $bin shaders $shaderInput @options
            if ($LASTEXITCODE -ne 0) { break }
        }
    } else {
        $freeCommitMiB = [math]::Floor((Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory / 1024)
        if ($freeCommitMiB -ge 17408) {
            # XCL clamps 4096 MiB to the largest supported coherent window.
            $env:XCL_COHERENT_MB = '4096'
        } else {
            Write-Warning "Memoria virtual livre: $freeCommitMiB MiB. O XCL exige 17408 MiB para a janela grafica maxima."
        }
        if ($Diagnostico) { $env:XCL_ACTIVITY = '1' }
        & $bin run $game
    }
    $code = $LASTEXITCODE
} finally {
    Get-ChildItem Env: | Where-Object Name -Like 'XCL_*' | ForEach-Object {
        [Environment]::SetEnvironmentVariable($_.Name, $null, 'Process')
    }
    foreach ($name in $previous.Keys) { [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process') }
}
exit $code


