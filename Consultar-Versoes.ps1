$ErrorActionPreference = 'Stop'
$versoes = @{
    'regime-regular' = 'def97056b799da8dd1306f4c9e47c669f4d44b4e'
    'simples-nacional' = 'c5b0f01c8351c3f0d0795cc617b29d233e9f98df'
}
foreach ($nome in $versoes.Keys | Sort-Object) {
    $origem = "https://github.com/ReceitaFederal/calculadora-rtc-$nome"
    $api = "https://api.github.com/repos/ReceitaFederal/calculadora-rtc-$nome/commits/main"
    $atual = (Invoke-RestMethod -Uri $api -TimeoutSec 30).sha
    if ($atual -cnotmatch '^[a-f0-9]{40}$') { throw "Revisão inválida para $nome." }
    $local = $versoes[$nome]
    [pscustomobject]@{
        Motor = $nome
        Copia = $local
        GitHub = $atual
        Comparar = if ($local -ne $atual) { "$origem/compare/$local...$atual" }
    }
}
