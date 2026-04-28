"""
Módulo da Camada de Serviço (Service Layer) para as visualizações de Estoques.
Centraliza as funções de extração de dados analíticos, executando comandos SQL 
direto no Data Warehouse (em cima de Views Materializadas) do PostgreSQL.

O objetivo é separar de forma limpa a lógica do banco do controlador REST.
A função principal retorna os "eixos X/Y" estruturados pra facilitar o frontend via Plotly.
"""

from app.db import query_all

# ---------------------------------------------------------------------------
# Funções Isoladas: Populam os "Combobox" de Filtro na página web
# ---------------------------------------------------------------------------

def get_filiais() -> list[str]:
    """Retorna a lista de filiais disponíveis."""
    sql = "SELECT DISTINCT filial FROM estoques.dim_filial ORDER BY filial;"
    rows = query_all(sql)
    return [r["filial"] for r in rows]


def get_centros_distribuicao() -> list[str]:
    """Retorna a lista de centros de distribuição."""
    sql = "SELECT DISTINCT centro_distribuicao FROM estoques.dim_centro_distribuicao ORDER BY centro_distribuicao;"
    rows = query_all(sql)
    return [r["centro_distribuicao"] for r in rows]


def get_familias() -> list[str]:
    """Retorna a lista de famílias de produtos."""
    sql = "SELECT DISTINCT familia FROM estoques.dim_familia_produto ORDER BY familia;"
    rows = query_all(sql)
    return [r["familia"] for r in rows]


# ---------------------------------------------------------------------------
# Função principal — aplica filtros e prepara os dados dos 4 gráficos
# ---------------------------------------------------------------------------

def get_dados_estoques(filters: dict) -> tuple[dict, dict, str | None]:
    """
    Função agregadora para o Dashboard de Estoques.
    Recebe os filtros definidos pelo usuário da Web (Filial, CD, Família), formata e anexa essas
    restrições em `params` do SQLAlchemy contra a query agregada.
    
    Aplica os filtros recebidos e retorna:
      - charts : Dicionário pivotado onde cada chave representa um gráfico, preparado para 
                 facilitar a inserção (x, y) de forma direta nos cards do frontend Plotly.
      - kpis   : Dicionário contendo os 4 KPIs estruturados do topo do painel, 
                 já processados com cálculos contábeis (ex: x.MM / %).
      - error  : Uma string descrevendo falhas catastróficas que interrompem o acesso.
    """
    error = None
    
    # KPIs default view
    kpis = {
        'valor_estoque': '—',
        'ruptura':       '—',
        'giro_medio':    '—',
        'cobertura':     '—',
    }
    
    charts = {
        'valor_mensal':     {'labels': [], 'valores': []},
        'ruptura_mensal':   {'labels': [], 'percentuais': []},
        'giro_cd':          {'centros': [], 'giros': []},
        'cobertura_filial': {'filiais': [], 'coberturas': []},
    }

    try:
        # Base queries using the materialized view
        base_sql = "FROM estoques.vm_kpis_estoques_mensal WHERE 1=1"
        params = {}
        
        if filters.get('filial'):
            base_sql += " AND filial = :filial"
            params['filial'] = filters['filial']
            
        if filters.get('centro_distribuicao'):
            base_sql += " AND centro_distribuicao = :centro_distribuicao"
            params['centro_distribuicao'] = filters['centro_distribuicao']
            
        if filters.get('familia'):
            base_sql += " AND familia = :familia"
            params['familia'] = filters['familia']

        # --- KPIs -------------------------------------------------------
        kpi_sql = f"""
            SELECT 
                SUM(valor_estoque_total) AS total_valor,
                SUM(rupturas) AS total_rupturas,
                SUM(movimentacoes_saida) AS total_saida,
                SUM(estoque_medio_unidades) AS total_estoque,
                AVG(dias_cobertura_medio) AS media_cobertura
            {base_sql}
        """
        kpi_row = query_all(kpi_sql, params)[0]

        total_valor = kpi_row['total_valor'] or 0
        total_rupturas = kpi_row['total_rupturas'] or 0
        total_saida = kpi_row['total_saida'] or 0
        total_estoque = kpi_row['total_estoque'] or 0
        media_cobertura = kpi_row['media_cobertura'] or 0

        # Forma de cálculo de KPIs baseadas no dashboard:
        valor_estoque_fmt = f"R$ {total_valor / 1_000_000:.1f}M" if total_valor >= 1_000_000 else f"R$ {total_valor:,.2f}"
        ruptura_pct = (total_rupturas / (total_saida + total_rupturas) * 100) if (total_saida + total_rupturas) > 0 else 0
        giro = (total_saida / total_estoque) if total_estoque > 0 else 0

        kpis = {
            'valor_estoque': valor_estoque_fmt,
            'ruptura':       f"{ruptura_pct:.1f}%",
            'giro_medio':    f"{giro:.2f}x",
            'cobertura':     f"{media_cobertura:.0f} dias",
        }

        # --- Gráfico 1: valor_mensal ------------------------------------
        g1_sql = f"""
            SELECT TO_CHAR(data_mes, 'Mon-YY') as mes, SUM(valor_estoque_total) as valor, MIN(data_mes) as d
            {base_sql}
            GROUP BY TO_CHAR(data_mes, 'Mon-YY')
            ORDER BY d;
        """
        rows_g1 = query_all(g1_sql, params)
        charts['valor_mensal']['labels'] = [r['mes'] for r in rows_g1]
        charts['valor_mensal']['valores'] = [float(r['valor']) for r in rows_g1]

        # --- Gráfico 2: ruptura_mensal ----------------------------------
        g2_sql = f"""
            SELECT TO_CHAR(data_mes, 'Mon-YY') as mes, 
                   SUM(rupturas) as rup, SUM(movimentacoes_saida) as sai, MIN(data_mes) as d
            {base_sql}
            GROUP BY TO_CHAR(data_mes, 'Mon-YY')
            ORDER BY d;
        """
        rows_g2 = query_all(g2_sql, params)
        charts['ruptura_mensal']['labels'] = [r['mes'] for r in rows_g2]
        charts['ruptura_mensal']['percentuais'] = [
            round(r['rup'] / (r['sai'] + r['rup']) * 100, 2) if (r['sai'] + r['rup']) > 0 else 0
            for r in rows_g2
        ]

        # --- Gráfico 3: giro_cd -----------------------------------------
        g3_sql = f"""
            SELECT centro_distribuicao as cd, 
                   SUM(movimentacoes_saida) as sai, SUM(estoque_medio_unidades) as est
            {base_sql}
            GROUP BY centro_distribuicao
            ORDER BY cd;
        """
        rows_g3 = query_all(g3_sql, params)
        charts['giro_cd']['centros'] = [r['cd'] for r in rows_g3]
        charts['giro_cd']['giros'] = [
            round(r['sai'] / r['est'], 2) if r['est'] > 0 else 0
            for r in rows_g3
        ]

        # --- Gráfico 4: cobertura_filial --------------------------------
        g4_sql = f"""
            SELECT filial, AVG(dias_cobertura_medio) as media_cobertura
            {base_sql}
            GROUP BY filial
            ORDER BY filial;
        """
        rows_g4 = query_all(g4_sql, params)
        charts['cobertura_filial']['filiais'] = [r['filial'] for r in rows_g4]
        charts['cobertura_filial']['coberturas'] = [round(r['media_cobertura'], 0) for r in rows_g4]

    except Exception as exc:
        error = f"Erro ao carregar dados: {exc}"

    return charts, kpis, error
