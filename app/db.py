"""
Módulo de persistência e orquestração do banco de dados.
Centraliza as conexões com o PostgreSQL adotando pool de conexões (Engine) via SQLAlchemy.
"""
from __future__ import annotations

from typing import Any, Iterable, Mapping

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine, Result
from flask import current_app

# Engine global em cache para reuso, otimizando o tempo de conexão subsequente
_engine: Engine | None = None


def get_engine() -> Engine:
    """
    Recupera (ou inicializa) o motor de banco de dados nativo, parametrizando time-outs.
    """
    global _engine
    if _engine is None:
        database_url = current_app.config["DATABASE_URL"]
        # timeout pequeno de 5s para não "congelar" a página caso o banco não esteja no ar
        _engine = create_engine(
            database_url,
            future=True,
            connect_args={"connect_timeout": 5},
        )
    return _engine


def query_all(sql: str, params: Mapping[str, Any] | None = None) -> list[Mapping[str, Any]]:
    """
    Executa uma string SQL bruta utilizando conexões seguras, formata os resultados
    em uma lista de dicionários nativos, facilitando a vida útil de serializers e templates.
    """
    engine = get_engine()
    with engine.connect() as conn:
        result: Result = conn.execute(text(sql), params or {})
        rows = [dict(row._mapping) for row in result]
    return rows
