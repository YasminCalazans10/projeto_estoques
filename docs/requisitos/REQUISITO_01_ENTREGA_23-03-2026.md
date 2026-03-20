# Requisito 01 - Estrutura da Pagina BI com Filtros

## Entrega


- Nesta fase, cada grupo deve entregar apenas a pagina do seu tema:
  - `projeto_estoques` -> pagina de estoques
- Deve ser entregue um modelo visual da aplicacao pronta apenas como referencia de estrutura e organizacao da interface.

## Objetivo desta primeira entrega

O objetivo desta entrega nao e construir os graficos finais.

O objetivo e deixar a aplicacao com a estrutura da pagina pronta, contendo:

- rota funcionando;
- template da pagina funcionando;
- filtros visiveis e operacionais;
- consulta de dados preparada para os filtros;
- espaco reservado para 4 graficos;
- execucao via `python run.py`.

Ao corrigir, deve ser possivel executar o projeto e verificar que a pagina abre corretamente, sem erro, com os filtros criados e com a estrutura pronta para os 4 graficos que serao implementados depois.

## Escopo desta entrega


- Implementar apenas a pagina `/estoques`;

Nao e necessario manter as tres paginas juntas no mesmo projeto do grupo.

## O que deve existir obrigatoriamente

### 1. Aplicacao executando

O projeto deve iniciar com:

```bash
python run.py
```

Ao abrir no navegador, a pagina do tema do grupo deve carregar sem erro.

### 2. Rota da pagina

O arquivo `app/routes.py` deve conter a rota da pagina.

Exemplos esperados:

- `/estoques`

Essa rota deve:

- ler os filtros enviados pela URL (`request.args`);
- montar um dicionario `filters`;
- buscar as opcoes dos filtros;
- chamar a camada de consulta de dados;
- enviar os dados para o template com `render_template(...)`.

### 3. Filtros criados na interface

A pagina deve exibir 3 filtros, seguindo o tema do projeto.

Filtros esperados por pagina:

- Estoques:
  - `filial`
  - `centro_distribuicao`
  - `familia`

Os filtros devem aparecer em um formulario com:

- botao `Aplicar`;
- opcao de limpar filtros;
- valores carregados dinamicamente a partir dos dados.

### 4. Filtros funcionando de verdade

Esta e a principal exigencia desta entrega.

Nao basta desenhar o formulario. Os filtros devem alterar os dados enviados para a pagina.

Mesmo sem os graficos finais prontos, a estrutura do projeto deve estar preparada para que, ao aplicar um filtro, os dados usados na pagina mudem.

Em termos praticos, isso significa que:

- a rota recebe os filtros;
- a camada de servico aplica os filtros sobre os dados;
- os dados retornados para os 4 graficos dependem dos filtros selecionados.

Regra obrigatoria:

- os mesmos filtros da pagina devem impactar todos os 4 graficos daquela pagina.

## Como a estrutura da pagina deve ficar

A pagina deve seguir o modelo estrutural apresentado em aula, mas sem exigir os graficos prontos nesta etapa.

Estrutura minima esperada:

1. titulo da pagina;
2. mensagem de erro de banco, se houver;
3. area de filtros;
4. area de KPIs ou placeholders equivalentes;
5. grade com 4 espacos reservados para graficos.

Exemplo de expectativa visual:

- cabecalho da aplicacao;
- formulario de filtros;
- 4 cards superiores ou placeholders de indicadores;
- 4 espacos de grafico na pagina.

## Arquivos que deve priorizar

Para esta entrega, a ordem recomendada de desenvolvimento e:

1. `run.py`
   - garantir que a aplicacao inicia;
2. `app/__init__.py`
   - registrar a aplicacao Flask;
3. `app/routes.py`
   - criar a rota e montar o contexto da pagina;
4. `app/services/bi_queries.py`
   - criar funcoes para:
     - listar opcoes de filtro;
     - aplicar filtros;
     - retornar os dados que abastecerao os 4 graficos;
5. `app/templates/base.html`
   - definir a base da interface;
6. `app/templates/<pagina>.html`
   - montar a estrutura da pagina do grupo;
7. `app/static/css/style.css`
   - ajustar organizacao visual minima.

## Estrutura tecnica esperada na camada de servico

Mesmo sem os graficos finais, a camada de servico deve estar pronta para devolver um dicionario `charts` com 4 entradas.

Exemplos:

- Estoques:
  - `valor_mensal`
  - `ruptura_mensal`
  - `giro_cd`
  - `cobertura_filial`

Nesta entrega, esses nomes podem ser usados como identificadores tecnicos internos, mesmo que o grafico ainda nao esteja desenhado.

## Regras importantes

- Cada projeto entrega somente uma pagina.
- Nao copiar as tres paginas para dentro de um unico projeto do grupo.
- O foco agora e estrutura + filtros.
- Os filtros devem ser implementados de modo que futuramente alterem todos os 4 graficos da pagina.
- A proxima etapa detalhara como construir cada grafico.