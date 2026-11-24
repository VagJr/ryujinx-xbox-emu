[CmdletBinding()]
param(
    [ValidateSet('series-x', 'series-s')] [string] $Console = 'series-x',
    [ValidateRange(1, 8)] [int] $PipelineWorkers = 2,
    [switch] $Software,
    [string] $DataDir,
    [switch] $PrepareOnly,
    [switch] $IntegracaoXcl,
    [switch] $ImagemXcl,
    [switch] $DiagnosticoGpu,
    [switch] $Verificar,
    [ValidateRange(1, 64)] [int] $ListasPorSubmissao = 8,
    [ValidateRange(1, 16)] [int] $ShaderJobs = 4,
    [string] $VictoryExecutable
)

$ErrorActionPreference = 'Stop'
if ($ImagemXcl) { $IntegracaoXcl = $true }
if (!$PSBoundParameters.ContainsKey('VictoryExecutable')) {
    $relative = if ($ImagemXcl) {
        'build-ffe310e\release\victory.exe'
    } elseif ($IntegracaoXcl) {
        'build-ffe310e\release\victory.exe'
    } else {
        'build-ffe310e\release\victory.exe'
    }
    $VictoryExecutable = Join-Path $PSScriptRoot $relative
}
if (!$PSBoundParameters.ContainsKey('DataDir')) {
    $relative = if ($ImagemXcl) { 'rtx-xcl-imagem\data' } elseif ($IntegracaoXcl) { 'rtx-xcl\data' } else { 'rtx\data' }
    $DataDir = Join-Path $PSScriptRoot $relative
}
$bin = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($VictoryExecutable)
$game = 'C:\Users\vagmi\Downloads\GTA6.Xbox.v1.0.2.1-CYBERLEEK'
$exe = 'C:\Users\vagmi\Downloads\early_xmas\game_scarlett_master.exe'
$dxil = Join-Path $PSScriptRoot '..\xcl-test\tools\dxc-1.9\bin\x64\dxil.dll'
$files = @($bin, $exe, (Join-Path $game 'MicrosoftGame.config'))
if ($ImagemXcl) {
    $helper = Join-Path $PSScriptRoot '..\xcl-victory\build-d5442d2-pipelines\release\xcl.exe'
    $sdk = 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64'
    $files += @($helper, (Join-Path $sdk 'dxcompiler.dll'), (Join-Path $sdk 'dxil.dll'))
}
foreach ($file in $files) {
    if (!(Test-Path -LiteralPath $file -PathType Leaf)) { throw "Arquivo ausente. $file" }
}
if ($Verificar) {
    Write-Host "VIctory pronto. $bin"
    return
}
if ($IntegracaoXcl -and !$PSBoundParameters.ContainsKey('DataDir')) {
    $titleProfile = Join-Path $DataDir '7952987A'
    $savedProfile = Join-Path $PSScriptRoot 'rtx-saved\data\7952987A'
    foreach ($folder in @('saves', 'storage')) {
        $source = Join-Path $savedProfile $folder
        $destination = Join-Path $titleProfile $folder
        if ((Test-Path -LiteralPath $source -PathType Container) -and !(Test-Path -LiteralPath $destination)) {
            New-Item -ItemType Directory -Path $titleProfile -Force | Out-Null
            Copy-Item -LiteralPath $source -Destination $destination -Recurse
        }
    }
}

$cache = if ($Software) { 'warp\cache' } else { 'rtx\cache' }
$variables = @{
    VICTORY_GAME_DIR = $game
    VICTORY_DATA_DIR = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DataDir)
    VICTORY_CACHE_DIR = (Join-Path $PSScriptRoot $cache)
    VICTORY_PIPELINE_WORKERS = "$PipelineWorkers"
    VICTORY_D3D12_WARP = $(if ($Software) { '1' })
    VICTORY_HOST_WAVE32 = $(if (!$Software) { '1' })
    VICTORY_DXIL = $(if (Test-Path -LiteralPath $dxil -PathType Leaf) { (Resolve-Path -LiteralPath $dxil).Path })
}
if ($IntegracaoXcl) { $variables.VICTORY_SUBMISSION_LISTS = "$ListasPorSubmissao" }
if ($DiagnosticoGpu) { $variables.VICTORY_D3D12_DRED = '1' }
if ($ImagemXcl) {
    $variables.VICTORY_RECT_XCL = (Resolve-Path -LiteralPath $helper).Path
    $variables.XCL_DXC_DIR = $sdk
    $variables.XCL_DXIL_CACHE = Join-Path $PSScriptRoot 'rtx\cache\xcl-dxil'
}
$previous = @{}
try {
    foreach ($name in $variables.Keys) {
        $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
        [Environment]::SetEnvironmentVariable($name, $variables[$name], 'Process')
    }
    if ($PrepareOnly) {
        $archive = Join-Path $game 'shaders.rpf'
        if (!(Test-Path -LiteralPath $archive -PathType Leaf)) { throw "Arquivo ausente. $archive" }
        $inputs = @($archive, $exe) + @(Get-ChildItem -LiteralPath $game -Filter '*.dll' -File | ForEach-Object FullName)
        $aux = Join-Path $PSScriptRoot '..\leonida-test\startup-shaders\shaders'
        if (Test-Path -LiteralPath $aux -PathType Container) {
            $inputs += @(Get-ChildItem -LiteralPath $aux -Filter '*.dxbc' -Recurse -File | ForEach-Object FullName)
        }
        $log = Join-Path $PSScriptRoot 'warm-complete.log'
        & $bin warm-shaders @inputs --jobs $ShaderJobs 2>&1 | Tee-Object -FilePath $log
        $code = $LASTEXITCODE
    } else {
        & $bin run $exe --execute --console $Console
        $code = $LASTEXITCODE
    }
} finally {
    foreach ($name in $previous.Keys) {
        [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process')
    }
}
exit $code


