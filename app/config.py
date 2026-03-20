import os
from flask import Flask
from dotenv import load_dotenv


def load_config(app: Flask) -> None:
    """Load configuration from .env into the Flask app."""
    # Load variables from .env file if present
    load_dotenv()

    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "dev-secret-key")

    db_host = os.getenv("DB_HOST", "localhost")
    db_port = os.getenv("DB_PORT", "5432")
    db_name = os.getenv("DB_NAME", "bi_dw")
    db_user = os.getenv("DB_USER", "postgres")
    db_password = os.getenv("DB_PASSWORD", "postgres")

    app.config["DATABASE_URL"] = (
        f"postgresql+psycopg://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    )

