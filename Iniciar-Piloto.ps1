param(
    [string]$Java = 'java',
    [string]$Node = 'node'
)
$ErrorActionPreference = 'Stop'
$javaExe = (Get-Command $Java -CommandType Application | Select-Object -First 1).Source
$nodeExe = (Get-Command $Node -CommandType Application | Select-Object -First 1).Source
$versao = @(& $javaExe --version 2>&1)
if ($LASTEXITCODE -ne 0 -or ($versao -join " ") -notmatch '\b(?<major>\d+)\.') { throw 'Use Java 25 ou superior.' }
if ([int]$Matches.major -lt 25) { throw 'Use Java 25 ou superior. O motor 1.7.x da Receita exige Java 25.' }
$nodeVersao = & $nodeExe --version
if ($nodeVersao -notmatch '^v(?<major>\d+)\.' -or [int]$Matches.major -lt 22) { throw 'Use Node.js 22 ou superior.' }

$motorArgs = @(
    '-XX:-UseBASE64Intrinsics'
    '-Dspring.profiles.active=offline'
    '-Dserver.address=127.0.0.1'
    '-Dmanagement.server.address=127.0.0.1'
    '-Dmanagement.tracing.enabled=false'
    '-jar'
    'api-regime-geral.jar'
)
$motor = Start-Process -FilePath $javaExe -ArgumentList $motorArgs -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -PassThru
try {
    Push-Location -LiteralPath $PSScriptRoot
    try {
        & $nodeExe 'servidor-local.mjs'
    } finally {
        Pop-Location
    }
} finally {
    if (!$motor.HasExited) { Stop-Process -Id $motor.Id }
}
