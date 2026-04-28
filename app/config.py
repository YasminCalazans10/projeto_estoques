"""
Módulo de configuração de ambiente.
Responsável por carregar credenciais e chaves do arquivo oculto '.env'
para uso seguro dentro da aplicação (para que o repositório GIT fique ileso de falhas com senhas expostas).
"""
import os
from flask import Flask
from dotenv import load_dotenv


def load_config(app: Flask) -> None:
    """
    Lê o ambiente, formata e insere parâmetros cruciais no escopo de acesso do Flask.
    """
    # Carrega variáveis do arquivo local .env caso ele exista no projeto
    load_dotenv()

    # Define e registra uma chave secreta usada para criptografia nativa no Flask
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "dev-secret-key")

    # Coleta de propriedades individuais do banco de dados relacional
    db_host = os.getenv("DB_HOST", "localhost")
    db_port = os.getenv("DB_PORT", "5432")
    db_name = os.getenv("DB_NAME", "bi_dw")
    db_user = os.getenv("DB_USER", "postgres")
    db_password = os.getenv("DB_PASSWORD", "postgres")

    # Cria string de conexão padronizada compatível com SQLAlchemy adaptada pra PostgreSQL (via driver Psycopg)
    app.config["DATABASE_URL"] = (
        f"postgresql+psycopg://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    )
