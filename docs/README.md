# Projeto BI com Flask

Sistema web em Flask para visualizar dashboards de **Vendas**, **Produtos** e **Estoques** usando PostgreSQL.

## Como executar

1. Crie e ative um ambiente virtual
2. Instale as dependências:

```bash
pip install -r requirements.txt
```

3. Configure o arquivo `.env`
4. Execute seu script SQL de criação do DW no PostgreSQL
5. Rode a aplicação:

```bash
python run.py
```

6. Acesse:

```text
http://127.0.0.1:5000
```

## Estrutura

- `app/` aplicação Flask
- `app/services/bi_queries.py` consultas analíticas
- `app/sql/` consultas SQL por domínio
- `app/templates/` telas HTML
- `app/static/css/style.css` estilos
- `db/init/cria_fontes.sql` observações de inicialização
- `docs/` documentação complementar
