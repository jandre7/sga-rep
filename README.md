# Calculadora da Reforma Tributária

Piloto local do Souza Gonçalves Advocacia para avaliar o impacto da transição com empresas e contabilidades. A versão 0.2.0 atualiza o motor do Regime Regular para a 1.7.2 da Receita, validada em 25/11/2026. O repositório reúne a camada desenvolvida pelo escritório. A licença do motor de terceiros está em LICENSE-RFB.txt.

## Usar e editar

Abra **Simulador de Transição Tributária.html** no navegador para o comparativo anual. O mesmo arquivo contém os formulários, estilos e funções de cálculo. O formulário trabalha em centavos. Soma os tributos remanescentes, CBS, IBS, IS e gastos de adaptação, depois deduz o valor de referência. A carga percentual considera só os tributos divididos pela receita. As premissas são preenchidas por quem faz a análise.

Para o modo por operação, use Windows, PowerShell, Node.js 22+ e **JDK 25** (exigido pelo motor desde a 1.7.0). Copie `api-regime-geral.jar` para a raiz deste repositório e `calculadora/db/calculadora-pro.db` para o caminho homônimo, ambos gerados da mesma revisão oficial (ver abaixo).

Na raiz, execute no PowerShell:

```powershell
.\Iniciar-Piloto.ps1
```

Abra http://127.0.0.1:8787. O processo Node em servidor-local.mjs encaminha um item para a API do Regime Regular na porta 8080. O motor também usa a porta de gestão 9101. Encerre com Ctrl+C. O inicializador aceita -Java e -Node para indicar os executáveis. A abertura direta do HTML atende ao comparativo anual.

O inicializador passa `-XX:-UseBASE64Intrinsics` à JVM, mitigação da vulnerabilidade do OpenJDK indicada pela Receita no CHANGELOG da 1.7.1. Mantenha a opção enquanto o JDK usado não tiver a correção.

## Reproduzir o motor a partir da origem

Com Git e JDK 25 no PATH (ou `JAVA_HOME` apontando para o JDK 25), execute os comandos em uma pasta de desenvolvimento separada deste repositório. O Maven Wrapper requer internet na primeira execução.

```powershell
git clone https://github.com/ReceitaFederal/calculadora-rtc-regime-regular.git
cd calculadora-rtc-regime-regular
git checkout --detach def97056b799da8dd1306f4c9e47c669f4d44b4e
New-Item -ItemType Directory -Force calculadora/db
.\mvnw.cmd flyway:migrate '-Dflyway.configFiles=flyway\flyway-pro.conf' --batch-mode --errors
.\mvnw.cmd clean package --batch-mode --errors
```

Copie o JAR de `target` e o SQLite gerado para os dois destinos indicados acima.

## Verificar uma mudança

```powershell
node testes/testar-html.cjs
node --check servidor-local.mjs
.\testes\testar-motor.ps1
```

Execute o teste do motor com as três portas livres, o JAR e o banco preparados. Ele aceita -Java e -Node, inicia e encerra os serviços e usa somente uma operação fictícia. O exemplo anual deve produzir R$ 21.000,00 de aumento por gastos de adaptação. A operação de educação do exemplo oficial deve produzir R$ 42,24 de CBS e R$ 0,48 de IBS. Um código inválido deve produzir erro de item. Confira também o formulário no navegador após alterações de interface.

## Versões e cobertura

| Componente | Revisão de referência | Situação do piloto |
| --- | --- | --- |
| Regime Regular | def97056b799da8dd1306f4c9e47c669f4d44b4e | Motor 1.7.2, banco V0073, Java 25. Interface integrada para um item de IBS e CBS. |
| Simples Nacional | c5b0f01c8351c3f0d0795cc617b29d233e9f98df | Cópia oficial arquivada. A revisão atual (1.0.2, a926d5a) ainda não traz a pasta flyway; as migrações V0068 e V0071 do Regime Regular tratam de tabelas do Simples. |

Mudanças da 1.6.1 para a 1.7.2 que afetam o piloto: Java 25 e Spring Boot 4; memória de cálculo movida para `tribCalc.IBSCBS.memoriaCalculo`; arredondamento único por campo publicado (diferenças de centavos em alguns casos, sem efeito no exemplo de teste); novas tabelas de cClassTrib (IT 2025.002 v.1.70 e v.1.71), municípios, NCM e NBS. Consulte o CHANGELOG oficial para o detalhe.

Os números acima registram o teste de 25/11/2026. Consulte as versões atuais, o enquadramento e a vigência antes de avaliar um caso concreto. O script Consultar-Versoes.ps1 compara as revisões do GitHub. A versão online do motor deve ser conferida separadamente.

[Motor regular e exemplos](https://github.com/ReceitaFederal/calculadora-rtc-regime-regular/tree/def97056b799da8dd1306f4c9e47c669f4d44b4e) · [Motor do Simples](https://github.com/ReceitaFederal/calculadora-rtc-simples-nacional/tree/c5b0f01c8351c3f0d0795cc617b29d233e9f98df)
