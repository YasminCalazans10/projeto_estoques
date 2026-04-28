"""
Módulo de inicialização do pacote principal da aplicação Flask.
Implementa o padrão Application Factory, permitindo instanciar e configurar
o app dinamicamente (ótimo para testes e escalabilidade).
"""
from flask import Flask

from .config import load_config
from .routes import bp as main_bp


def create_app() -> Flask:
    """
    Fábrica da aplicação: cria e configura a instância pura do Flask.
    """
    app = Flask(__name__)

    # Carrega variáveis de ambiente do .env e injeta as configurações (ex: URL DB)
    load_config(app)

    # Registra o Blueprint (componente modular) responsável pelo mapeamento das rotas Web (/estoques)
    app.register_blueprint(main_bp)

    return app
