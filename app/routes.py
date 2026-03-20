from flask import Blueprint, render_template, request
from app.services.bi_queries import (
    get_filiais,
    get_centros_distribuicao,
    get_familias,
    get_dados_estoques,
)

bp = Blueprint('main', __name__)


@bp.route('/')
def index():
    return render_template('index.html')


@bp.route('/estoques')
def estoques():
    # Lê os filtros enviados pela URL
    filters = {
        'filial':               request.args.get('filial', ''),
        'centro_distribuicao':  request.args.get('centro_distribuicao', ''),
        'familia':              request.args.get('familia', ''),
    }

    # Busca opções para popular os selects
    filiais              = get_filiais()
    centros_distribuicao = get_centros_distribuicao()
    familias             = get_familias()

    # Busca dados aplicando os filtros (alimentará os 4 gráficos)
    charts, kpis, error = get_dados_estoques(filters)

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
