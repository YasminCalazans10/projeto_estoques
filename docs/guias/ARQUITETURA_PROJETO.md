 Arquitetura do Projeto - BI Web com Flask

## 1. Objetivo pedagógico
Este projeto simula a entrega de uma aplicacao de BI online para uma empresa que hoje depende de planilhas.
A turma deve evoluir uma base arquitetural pronta, sem reinventar estrutura.

Cada grupo entrega:
- pagina inicial da aplicacao (em comum para todos os grupos)
- pagina de relatorio da sua area de negocio

Areas (grupos):
- Grupo 1: Vendas
- Grupo 2: Produtos
- Grupo 3: Estoques

## 2. Visao geral da arquitetura
Camadas da solucao:
1. Dados (PostgreSQL em Docker): banco `bi_dw` com views materializadas por area.
2. Backend (Flask): carrega dados do banco, aplica filtros e prepara estruturas para os graficos.
3. Frontend (Jinja + Plotly): renderiza paginas, filtros e dashboards.
4. Documentacao: guias e entregas textuais.

Fluxo simplificado:
1. Usuario abre `/vendas`, `/produtos` ou `/estoques`.
2. Flask chama a camada de servicos (`app/services/bi_queries.py`).
3. Servico executa SQL base da MV (`app/sql/*_base.sql`).
4. Servico agrega/filtra em Python.
5. Template recebe dados e monta os graficos via Plotly.

## 3. Estrutura oficial de pastas
A estrutura abaixo deve ser mantida para o projeto rodar:

```text
projeto/
├─ app/
│  ├─ __init__.py
│  ├─ config.py
│  ├─ db.py
│  ├─ routes.py
│  ├─ services/
│  │  └─ bi_queries.py
│  ├─ sql/
│  │  ├─ vendas_base.sql
│  │  ├─ produtos_base.sql
│  │  └─ estoques_base.sql
│  ├─ templates/
│  │  ├─ base.html
│  │  ├─ index.html
│  │  ├─ vendas.html
│  │  ├─ produtos.html
│  │  └─ estoques.html
│  └─ static/
│     └─ css/
│        └─ style.css
├─ db/
│  └─ init/
│     └─ cria_fontes.sql
├─ infra/
│  └─ docker/
│     └─ criar_databases.txt
├─ docs/
│  ├─ README.md
│  ├─ entregas_textuais/
│  │  └─ TEMPLATE_ENTREGA.md
│  └─ guias/
│     ├─ RUBRICA_AVALIACAO.md
│     ├─ KPIS_E_INTERPRETACAO.md
│     └─ ARQUITETURA_PROJETO.md
├─ .env
├─ requirements.txt
├─ run.py
└─ README.md
```

## 4. Papel de cada arquivo (contrato minimo)

### 4.1 Inicializacao e execucao
- `run.py`
  - ponto de entrada da aplicacao
  - cria app via `create_app()`
  - le host/porta/debug do ambiente

- `app/__init__.py`
  - fabrica Flask (`create_app`)
  - carrega variaveis de ambiente
  - registra blueprint de rotas

### 4.2 Configuracao e conexao
- `app/config.py`
  - carrega `.env`
  - nao deve conter regra de negocio

- `app/db.py`
  - centraliza conexao PostgreSQL
  - executa SQL e retorna resultados

- `.env`
  - configuracoes locais do app e banco
  - exemplos: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`

### 4.3 Camada de aplicacao
- `app/routes.py`
  - define rotas HTTP (`/`, `/vendas`, `/produtos`, `/estoques`)
  - recebe filtros da URL
  - chama servicos
  - envia contexto para templates

- `app/services/bi_queries.py`
  - camada de dados da aplicacao
  - executa SQL base das MVs
  - aplica filtros em Python
  - gera estruturas para KPIs e graficos

### 4.4 SQL da aplicacao (didatico)
- `app/sql/vendas_base.sql`
- `app/sql/produtos_base.sql`
- `app/sql/estoques_base.sql`

Regras desses arquivos:
- devem ser `SELECT` simples em cima de MVs
- devem ser executaveis no PgAdmin sem adaptacao
- nao devem conter SQL avancado desnecessario para a turma

### 4.5 Frontend
- `app/templates/base.html`
  - layout base (menu, scripts globais, formatacao de numeros)

- `app/templates/index.html`
  - pagina inicial comum do projeto
  - links para as 3 areas

- `app/templates/vendas.html`, `produtos.html`, `estoques.html`
  - cada pagina de relatorio
  - filtros da area
  - cards de KPI
  - 4 graficos Plotly

- `app/static/css/style.css`
  - estilo visual da aplicacao

### 4.6 Dados e infraestrutura
- `infra/docker/criar_databases.txt`
  - comando Docker para subir o banco PostgreSQL

- `db/init/cria_fontes.sql`
  - script do DW (esquemas, dados, MVs)
  - executado via PgAdmin

### 4.7 Documentacao da disciplina
- `docs/guias/KPIS_E_INTERPRETACAO.md`
  - descricao dos indicadores e interpretacao

- `docs/guias/RUBRICA_AVALIACAO.md`
  - criterios de avaliacao

- `docs/entregas_textuais/TEMPLATE_ENTREGA.md`
  - modelo das entregas nao-codigo

## 5. Requisitos obrigatorios para "rodar tudo"

### 5.1 Ambiente
- Python 3.11+ (recomendado)
- Docker Desktop ativo
- PostgreSQL no container
- dependencias instaladas com `pip install -r requirements.txt`

### 5.2 Banco
1. Subir banco com `infra/docker/criar_databases.txt`.
2. Conectar no PgAdmin.
3. Executar `db/init/cria_fontes.sql`.
4. Conferir se existem as MVs:
   - `vendas.vm_kpis_vendas_mensal`
   - `produtos.vm_kpis_produtos_mensal`
   - `estoques.vm_kpis_estoques_mensal`

### 5.3 Aplicacao
1. Revisar `.env`.
2. Rodar `python run.py`.
3. Acessar `http://localhost:5000`.

## 6. Divisao por grupos (forma de entrega)

## 6.1 Comum a todos os grupos
- manter a pagina inicial (`index.html`) com navegacao para os 3 relatorios
- manter padrao visual e estrutura de filtros
- manter formatacao de numeros no padrao brasileiro

## 6.2 Grupo 1 - Vendas
Arquivos que o grupo deve evoluir principalmente:
- `app/templates/vendas.html`
- `app/sql/vendas_base.sql`
- `app/services/bi_queries.py` (bloco de vendas)

Entregas tecnicas minimas:
- 4 graficos funcionais de vendas
- filtros aplicaveis
- coerencia dos KPIs de vendas

## 6.3 Grupo 2 - Produtos
Arquivos foco:
- `app/templates/produtos.html`
- `app/sql/produtos_base.sql`
- `app/services/bi_queries.py` (bloco de produtos)

Entregas tecnicas minimas:
- 4 graficos funcionais de produtos
- filtros aplicaveis
- coerencia dos KPIs de produtos

## 6.4 Grupo 3 - Estoques
Arquivos foco:
- `app/templates/estoques.html`
- `app/sql/estoques_base.sql`
- `app/services/bi_queries.py` (bloco de estoques)

Entregas tecnicas minimas:
- 4 graficos funcionais de estoques
- filtros aplicaveis
- coerencia dos KPIs de estoques

## 7. Padroes de qualidade exigidos
- nao quebrar rotas existentes
- nao remover arquivos-base da arquitetura
- consultas SQL legiveis e executaveis no PgAdmin
- nomes de variaveis claros
- commits pequenos e com mensagem objetiva
- documentar decisao quando mudar KPI ou logica de calculo

## 8. O que nao deve acontecer
- colocar logica de negocio pesada dentro do template
- duplicar conexao com banco fora de `app/db.py`
- criar paginas sem integracao com os filtros
- hardcode de dados de grafico no frontend
- alterar estrutura de pastas sem alinhamento

## 9. Checklist de aceitacao (professor)
- banco sobe e script DW executa
- app sobe sem erro
- menu navega entre inicio e 3 relatorios
- cada relatorio tem filtros + KPIs + 4 graficos
- dados sao carregados das MVs
- numeros estao em formato brasileiro
- grupo entregou documentacao textual no template oficial

## 10. Evolucao futura (opcional)
- exportacao CSV com filtros
- autenticacao de usuarios
- cache para consultas de alto volume
- deploy em servico cloud
