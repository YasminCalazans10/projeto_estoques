# Guia de KPIs para Analise no BI

Este arquivo explica os KPIs publicados nas VMs do DW simulado.

## 1) Filtros disponiveis para os relatorios

As VMs foram preparadas para permitir filtros por:
- `data_mes` (tempo mensal)
- `filial`, `cidade`, `uf`, `regiao`
- Filtros de negocio por area:
  - Vendas: `canal`, `segmento`
  - Produtos: `categoria`, `fornecedor`
  - Estoques: `centro_distribuicao`, `familia`

### Filiais cadastradas
- Sao Paulo (SP)
- Campinas (SP)
- Rio de Janeiro (RJ)
- Belo Horizonte (MG)
- Curitiba (PR)
- Porto Alegre (RS)
- Florianopolis (SC)
- Salvador (BA)
- Recife (PE)
- Fortaleza (CE)
- Goiania (GO)
- Brasilia (DF)

## 2) KPIs de Vendas
Fonte: `vendas.vm_kpis_vendas_mensal`

### `receita_liquida`
- O que mede: faturamento efetivo apos descontos.
- Formula: `receita_bruta - desconto_total`.
- Como interpretar:
  - alta e crescente: aumento de faturamento real;
  - queda recorrente: perda de performance comercial.

### `margem_bruta_pct`
- O que mede: percentual de sobra da receita liquida apos custos diretos.
- Formula: `(receita_liquida - custo_total) / receita_liquida * 100`.
- Como interpretar:
  - margem subindo: venda mais rentavel;
  - margem caindo: custo alto, desconto excessivo ou mix inadequado.

### `ticket_medio`
- O que mede: valor medio por pedido.
- Formula: `receita_liquida / pedidos`.
- Como interpretar:
  - aumento: pedidos maiores ou produtos de maior valor;
  - queda: compras menores ou foco em itens baratos.

### `itens_por_pedido`
- O que mede: quantidade media de itens por venda.
- Formula: `itens_vendidos / pedidos`.
- Como interpretar:
  - aumento: melhor venda combinada (cross-sell);
  - queda: carrinho mais enxuto.

### `crescimento_receita_pct`
- O que mede: variacao percentual da receita liquida vs mes anterior.
- Formula: `(mes_atual - mes_anterior) / mes_anterior * 100`.
- Como interpretar:
  - positivo: expansao;
  - negativo: retracao; avaliar sazonalidade e acoes comerciais.

## 3) KPIs de Produtos
Fonte: `produtos.vm_kpis_produtos_mensal`

### `taxa_lancamento_pct`
- O que mede: nivel de renovacao do portfolio.
- Formula: `novos_produtos / produtos_ativos * 100`.
- Como interpretar:
  - alta: portfolio renovando rapido;
  - baixa: possivel estagnacao da oferta.

### `taxa_descontinuacao_pct`
- O que mede: retirada de itens do portfolio.
- Formula: `descontinuados / produtos_ativos * 100`.
- Como interpretar:
  - alta: limpeza forte de portfolio (pode ser positiva ou sinal de problemas);
  - baixa: portfolio mais estavel.

### `markup_medio_pct`
- O que mede: diferenca percentual entre preco medio e custo medio.
- Formula: `(preco_medio - custo_medio) / custo_medio * 100`.
- Como interpretar:
  - alto: maior espaco de margem;
  - baixo: pressao de custo/preco.

### `demanda_media_por_produto`
- O que mede: unidades vendidas por produto ativo.
- Formula: `unidades_vendidas / produtos_ativos`.
- Como interpretar:
  - alta: portfolio eficiente em giro;
  - baixa: excesso de itens para demanda existente.

### `crescimento_unidades_pct`
- O que mede: variacao mensal do volume vendido em unidades.
- Formula: `(unidades_mes_atual - unidades_mes_anterior) / unidades_mes_anterior * 100`.
- Como interpretar:
  - positivo: tracao de vendas;
  - negativo: perda de volume.

## 4) KPIs de Estoques
Fonte: `estoques.vm_kpis_estoques_mensal`

### `taxa_ruptura_pct`
- O que mede: percentual de ocorrencias de falta de estoque.
- Formula: `rupturas / (movimentacoes_saida + rupturas) * 100`.
- Como interpretar:
  - alta: risco de perda de venda e baixa disponibilidade;
  - baixa: operacao abastecida.

### `giro_estoque`
- O que mede: velocidade de renovacao do estoque.
- Formula: `movimentacoes_saida / estoque_medio_unidades`.
- Como interpretar:
  - alto: estoque gira rapido;
  - baixo: capital parado em estoque.

### `dias_cobertura_medio`
- O que mede: quantos dias o estoque tende a cobrir a demanda.
- Como interpretar:
  - muito baixo: risco de ruptura;
  - muito alto: risco de excesso e custo de armazenagem.

### `valor_estoque_total`
- O que mede: capital financeiro total alocado em estoque no mes.
- Como interpretar:
  - alto: maior capital empatado;
  - baixo: menor exposicao financeira em inventario.

### `variacao_valor_estoque_pct`
- O que mede: variacao percentual mensal do valor em estoque.
- Formula: `(valor_mes_atual - valor_mes_anterior) / valor_mes_anterior * 100`.
- Como interpretar:
  - positivo: acumulacao de estoque;
  - negativo: reducao de estoque.

## 5) Perguntas de analise sugeridas para os estudantes

- Quais filiais tiveram maior crescimento de receita no ultimo ano?
- Em quais cidades a margem de vendas piorou?
- Qual categoria tem maior demanda media por produto por regiao?
- Onde a taxa de ruptura esta alta mesmo com dias de cobertura elevados?
- Quais fornecedores concentram queda de volume em produtos?
