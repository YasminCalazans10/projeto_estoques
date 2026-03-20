from flask import Flask

from .config import load_config
from .routes import bp as main_bp


def create_app() -> Flask:
    app = Flask(__name__)

    # Load configuration (env vars, DB URL etc.)
    load_config(app)

    # Register main blueprint with routes (including /estoques)
    app.register_blueprint(main_bp)

    return app

