param([string]$Java = 'java')
$ErrorActionPreference='Stop'
$b=Split-Path -Parent $PSScriptRoot
$r=[IO.Path]::GetTempPath()
$java=(Get-Command $Java -CommandType Application | Select-Object -First 1).Source
$motor=Start-Process -FilePath $java -ArgumentList '-Dspring.profiles.active=offline','-Dserver.address=127.0.0.1','-Dmanagement.server.address=127.0.0.1','-Dmanagement.tracing.enabled=false','-jar','api-regime-geral.jar' -WindowStyle Hidden -WorkingDirectory $b -RedirectStandardOutput (Join-Path $r 'motor-piloto.log') -RedirectStandardError (Join-Path $r 'motor-piloto-erro.log') -PassThru
try {
    $proxy=Start-Process -FilePath (Get-Command node).Source -ArgumentList 'servidor-local.mjs' -WorkingDirectory $b -WindowStyle Hidden -PassThru
    $params=@{Uri='http://127.0.0.1:8787/motor/regime-regular';Method='Post';Headers=@{Origin='http://127.0.0.1:8787'};ContentType='application/json';TimeoutSec=25}
    $entrada=Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'operacao-teste.json')
    $resp=$null
    for ($i=0; $i -lt 20; $i++) {
        if ($motor.HasExited -or $proxy.HasExited) { throw 'Um serviço encerrou durante a inicialização.' }
        try { $resp=Invoke-RestMethod @params -Body $entrada; break }
        catch { if ($i -eq 19) { throw }; Start-Sleep -Seconds 1 }
    }
    $obj=$resp.objetos[0]
    $g=$obj.tribCalc.IBSCBS.gIBSCBS
    if ($obj.estadoItem -ne 'CALCULO_SIMULADO' -or [decimal]$g.gCBS.vCBS -ne 42.24 -or [decimal]$g.vIBS -ne 0.48) {
        $resp | ConvertTo-Json -Depth 12
        throw 'Valores diferentes do exemplo oficial.'
    }
    "Cálculo simulado confirmado. CBS $($g.gCBS.vCBS), IBS $($g.vIBS)"
    $erro=Invoke-RestMethod @params -Body ($entrada.Replace('122011200','000000000'))
    if ($erro.objetos[0].estadoItem -ne 'INCONSISTENCIA_ENTRADA') { $erro|ConvertTo-Json -Depth 12; throw 'Não sinalizou código inválido.' }
    "Erro por item confirmado"
    $pagina=Invoke-WebRequest 'http://127.0.0.1:8787/' -TimeoutSec 5
    if ($pagina.StatusCode -ne 200 -or $pagina.Content -notmatch 'Impacto anual') { throw 'Página indisponível.' }
    "Página entregue com HTTP 200"
} finally {
    if ($proxy -and !$proxy.HasExited) { Stop-Process -Id $proxy.Id }
    if ($motor -and !$motor.HasExited) { Stop-Process -Id $motor.Id }
}
