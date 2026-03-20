from __future__ import annotations

from typing import Any, Iterable, Mapping

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine, Result
from flask import current_app


_engine: Engine | None = None


def get_engine() -> Engine:
    global _engine
    if _engine is None:
        database_url = current_app.config["DATABASE_URL"]
        # timeout pequeno para nao "congelar" a pagina caso o banco nao esteja de pe
        _engine = create_engine(
            database_url,
            future=True,
            connect_args={"connect_timeout": 5},
        )
    return _engine


def query_all(sql: str, params: Mapping[str, Any] | None = None) -> list[Mapping[str, Any]]:
    engine = get_engine()
    with engine.connect() as conn:
        result: Result = conn.execute(text(sql), params or {})
        rows = [dict(row._mapping) for row in result]
    return rows

