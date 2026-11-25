
const fs=require('node:fs');
const vm=require('node:vm');
const assert=require('node:assert/strict');
const html=fs.readFileSync(require('node:path').join(__dirname, '../Simulador de Transição Tributária.html'),'utf8');
assert(!html.includes('${Array.from'));
assert((html.match(/<option/g)||[]).length>=35);
const elementos=new Map();
function elemento(){return {firstElementChild:{textContent:''},elements:{data:{value:'2026-01-01'},tipo:{value:'ncm'},codigo:{},aliqCbs:{},aliqUf:{},aliqMun:{}},addEventListener(){}};}
const document={querySelectorAll:()=>[],getElementById:(id)=>{if(!elementos.has(id))elementos.set(id,elemento());return elementos.get(id);}};
const ctx=vm.createContext({document,location:{origin:'null'},crypto:require('node:crypto').webcrypto});
vm.runInContext(html.match(/<script>([\s\S]+)<\/script>/)[1],ctx);
const caso={ano:2027,receita:1200000,referencia:100000,remanescentes:20000,cbs:75000,ibs:5000,is:0,unico:15000,recorrente:6000};
const z=ctx.calcularImpacto(new Map(Object.entries(caso)));
assert.equal(z.diferenca,2100000);
assert.equal(z.tributos,10000000);
assert.equal(ctx.calcularImpacto(new Map(Object.entries({...caso,cbs:100,unico:0,recorrente:0}))).diferenca,-7490000);
assert.equal(ctx.calcularImpacto(new Map(Object.entries({...caso,cbs:75000.01,ibs:4999.99}))).novos,8000000);
const op={tipo:'nbs',codigo:'122011200',cst:'200',classificacao:'200028',base:1200,data:'2027-03-10',municipio:'4314902',uf:'RS',aliqCbs:8.8,aliqUf:0.05,aliqMun:0.05};
const pedido=ctx.operacao(new Map(Object.entries(op)));
assert.equal(pedido.itens[0].cClassTrib,'200028');
assert.equal(pedido.itens[0].aliquotasNominais.cbs,8.8);
assert.equal(ctx.operacao(new Map(Object.entries({...op,data:'2026-01-01'}))).itens[0].aliquotasNominais,undefined);
console.log('Lógica do comparativo e montagem do pedido conferidas');
