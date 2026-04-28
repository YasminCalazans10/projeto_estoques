"""
Módulo de controladores da aplicação (Rotas HTML e Endpoints).
Agrupa o mapeamento das páginas acessáveis e direciona o modelo e dados corretos para o Jinja (Motor de visualizações).
"""
from flask import Blueprint, render_template, request
from app.services.bi_queries import (
    get_filiais,
    get_centros_distribuicao,
    get_familias,
    get_dados_estoques,
)

# Inicializa o Blueprint central, agregando todas as rotas (view functions) associadas a ele.
bp = Blueprint('main', __name__)


@bp.route('/')
def index():
    """Rota raiz (Landing Page) que dá os direcionamentos iniciais e apresenta ao usuário a plataforma."""
    return render_template('index.html')


@bp.route('/estoques')
def estoques():
    """
    Controller do dashboard principal ("Estoques").
    Responsável por: 
    1. Interpretar variáveis vindas como filtros de URL.
    2. Pesquisar e repassar menus de filtros em tela.
    3. Recuperar todo o conjunto das estatísticas KPI e charts para popular no lado do cliente com Plotly.
    """
    # Lê os filtros enviados dinamicamente pela barra da URL (querystrings ?filial=X)
    filters = {
        'filial':               request.args.get('filial', ''),
        'centro_distribuicao':  request.args.get('centro_distribuicao', ''),
        'familia':              request.args.get('familia', ''),
    }

    # Busca no banco de dados e retorna os agrupamentos unificados para criar <option> do HTML.
    filiais              = get_filiais()
    centros_distribuicao = get_centros_distribuicao()
    familias             = get_familias()

    # Busca dados macro de toda a regra de negócio do arquivo bi_queries.py, enviando os filtros vigentes.
    charts, kpis, error = get_dados_estoques(filters)

    # Renderiza o "html principal", serializando e imbutindo dados ao longo do motor do template.
    return render_template(
        'estoques.html',
        filters=filters,
        filiais=filiais,
        centros_distribuicao=centros_distribuicao,
        familias=familias,
        charts=charts,
        kpis=kpis,
        error=error,
    )
