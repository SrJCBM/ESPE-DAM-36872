import os
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError

from .base_datos import inicializar
from .http import responder_negocio, responder_validacion
from .rutas import asignaturas, estudiantes, notas
from .servicios import ErrorNegocio

ARCHIVO_LOCAL = Path(__file__).resolve().parents[1] / "data" / "control_academico.sqlite3"


def crear_app(ruta_db: Path | None = None, *, database_url: str | None = None) -> FastAPI:
    if ruta_db is not None:
        origen = ruta_db
    else:
        url = database_url if database_url is not None else os.getenv("DATABASE_URL")
        origen = url or Path(os.environ.get("CONTROL_ACADEMICO_DB", str(ARCHIVO_LOCAL)))

    @asynccontextmanager
    async def lifespan(api: FastAPI):
        if isinstance(origen, Path) and os.getenv("RENDER") == "true":
            raise RuntimeError("Configura DATABASE_URL con la URL de PostgreSQL de Neon en Render.")
        inicializar(origen)
        yield

    api = FastAPI(title="Control académico", version="1.0.0", lifespan=lifespan)
    api.state.origen_db = origen
    api.add_exception_handler(RequestValidationError, responder_validacion)
    api.add_exception_handler(ErrorNegocio, responder_negocio)

    for recurso in (estudiantes, asignaturas, notas):
        api.include_router(recurso.router, prefix="/api/v1")
    return api


app = crear_app()
