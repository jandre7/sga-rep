import http from 'node:http';
import {readFile} from 'node:fs/promises';

const html = await readFile(new URL('./Simulador de Transição Tributária.html', import.meta.url));
const base = 'http://127.0.0.1:8787';
const motor = 'http://127.0.0.1:8080/api/calculadora/observabilidade/regime-geral';

function json(res, status, mensagem) {
  res.writeHead(status, {'Content-Type':'application/json; charset=utf-8'});
  res.end(JSON.stringify({mensagem}));
}

const server = http.createServer(async (req, res) => {
  res.setHeader('Cache-Control','no-store');
  res.setHeader('X-Content-Type-Options','nosniff');
  if (req.headers.host !== '127.0.0.1:8787') return json(res,403,'Endereço local inválido.');
  if (req.method === 'GET' && req.url === '/') {
    res.writeHead(200,{'Content-Type':'text/html; charset=utf-8'});
    return res.end(html);
  }
  if (req.method !== 'POST' || req.url !== '/motor/regime-regular') return json(res,404,'Rota não encontrada.');
  if (req.headers.origin !== base || req.headers['content-type'] !== 'application/json') {
    return json(res,403,'Origem ou formato de solicitação inválido.');
  }
  try {
    const partes = [];
    let tamanho = 0;
    for await (const parte of req) {
      tamanho += parte.length;
      if (tamanho > 16384) return json(res,413,'Solicitação acima do limite.');
      partes.push(parte);
    }
    let dados;
    try {
      dados = JSON.parse(Buffer.concat(partes));
    } catch {
      return json(res,400,'Informe uma operação em JSON.');
    }
    if (dados?.itens?.length !== 1 || !Array.isArray(dados.itens)) {
      return json(res,400,'Informe exatamente um item.');
    }
    const resposta = await fetch(motor,{
      method:'POST',
      headers:{'Content-Type':'application/json','Accept':'application/json'},
      body:JSON.stringify(dados),
      redirect:'error',
      signal:AbortSignal.timeout(24000)
    });
    const resultado = await resposta.json();
    res.writeHead(resposta.status, {'Content-Type':'application/json; charset=utf-8'});
    res.end(JSON.stringify(resultado));
  } catch {
    json(res,502,'Motor indisponível. Confirme se a API oficial está em execução na porta 8080.');
  }
});
server.requestTimeout = 30000;
server.listen(8787, '127.0.0.1', () => process.stdout.write('Simulador em '+base+'\n'));
