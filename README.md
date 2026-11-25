# Calculadora da Reforma Tributária

Piloto local do Souza Gonçalves Advocacia para avaliar o impacto da transição com empresas e contabilidades. A versão 0.1.0 preserva o código do piloto testado em 18/11/2026. O repositório reúne a camada desenvolvida pelo escritório. A licença do motor de terceiros está em LICENSE-RFB.txt.

## Usar e editar

Abra **Simulador de Transição Tributária.html** no navegador para o comparativo anual. O mesmo arquivo contém os formulários, estilos e funções de cálculo. O formulário trabalha em centavos. Soma os tributos remanescentes, CBS, IBS, IS e gastos de adaptação, depois deduz o valor de referência. A carga percentual considera só os tributos divididos pela receita. As premissas são preenchidas por quem faz a análise.

Para o modo por operação, use Windows, PowerShell, Node.js 22+ e JDK 21. Do pacote de execução da mesma versão, copie `api-regime-geral.jar` para a raiz deste repositório e `calculadora/db/calculadora-pro.db` para o caminho homônimo. O pacote de execução entregue com o piloto chama-se **Piloto local com motor oficial.zip**.

Na raiz, execute no PowerShell:

```powershell
.\Iniciar-Piloto.ps1
```

Abra http://127.0.0.1:8787. O processo Node em servidor-local.mjs encaminha um item para a API do Regime Regular na porta 8080. O motor também usa a porta de gestão 9101. Encerre com Ctrl+C. O inicializador aceita -Java e -Node para indicar os executáveis. A abertura direta do HTML atende ao comparativo anual.

## Reproduzir o motor a partir da origem

Com Git e JDK 21 no PATH, execute os comandos em uma pasta de desenvolvimento separada deste repositório. O Maven Wrapper requer internet na primeira execução.

```powershell
git clone https://github.com/ReceitaFederal/calculadora-rtc-regime-regular.git
cd calculadora-rtc-regime-regular
git checkout --detach 150cccbe414d4a5edea703e4f7a424af5aa222c7
New-Item -ItemType Directory -Force calculadora/db
.\mvnw.cmd flyway:migrate '-Dflyway.configFiles=./flyway/flyway-pro.conf'
.\mvnw.cmd package
```

Copie o JAR de `target` e o SQLite gerado para os dois destinos indicados acima.

## Verificar uma mudança

```powershell
node testes/testar-html.cjs
node --check servidor-local.mjs
.\testes\testar-motor.ps1
```

Execute o teste do motor com as três portas livres, o JAR e o banco preparados. Ele inicia e encerra os serviços e usa somente uma operação fictícia. O exemplo anual deve produzir R$ 21.000,00 de aumento por gastos de adaptação. A operação de educação do exemplo oficial deve produzir R$ 42,24 de CBS e R$ 0,48 de IBS. Um código inválido deve produzir erro de item. Confira também o formulário no navegador após alterações de interface.

## Versões e cobertura

| Componente | Revisão de referência | Situação do piloto |
| --- | --- | --- |
| Regime Regular | 150cccbe414d4a5edea703e4f7a424af5aa222c7 | Motor 1.6.1, banco V0059. Interface integrada para um item de IBS e CBS. |
| Simples Nacional | c5b0f01c8351c3f0d0795cc617b29d233e9f98df | Cópia oficial arquivada. Na revisão estudada faltava a pasta flyway indicada no README. |

Em 18/11/2026 o serviço da Receita informou versão online 1.7.0-753903df e banco V0073. Esses números registram o teste daquela data. Consulte as versões atuais, o enquadramento e a vigência antes de avaliar um caso concreto. O script Consultar-Versoes.ps1 compara as revisões do GitHub. A versão online do motor deve ser conferida separadamente.

[Motor regular e exemplos](https://github.com/ReceitaFederal/calculadora-rtc-regime-regular/tree/150cccbe414d4a5edea703e4f7a424af5aa222c7) · [Motor do Simples](https://github.com/ReceitaFederal/calculadora-rtc-simples-nacional/tree/c5b0f01c8351c3f0d0795cc617b29d233e9f98df)
