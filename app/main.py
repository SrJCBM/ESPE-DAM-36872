import os
from contextlib import asynccontextmanager
from pathlib import Path

from dotenv import dotenv_values
from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError

from .base_datos import inicializar
from .http import responder_negocio, responder_validacion
from .rutas import asignaturas, estudiantes, notas
from .servicios import ErrorNegocio

RAIZ = Path(__file__).resolve().parents[1]
ARCHIVO_LOCAL = RAIZ / "data" / "control_academico.sqlite3"


def urls_postgres() -> tuple[str | None, str | None]:
    # Las variables del proceso prevalecen, en especial en Render.
    if "DATABASE_URL" in os.environ or os.getenv("RENDER") == "true":
        return os.getenv("DATABASE_URL"), os.getenv("DATABASE_URL_UNPOOLED")
    archivo_env = RAIZ / ".env"
    if not archivo_env.is_file():
        archivo_env = RAIZ / ".env.local"
    valores = dotenv_values(archivo_env)
    return valores.get("DATABASE_URL"), valores.get("DATABASE_URL_UNPOOLED")


def crear_app(ruta_db: Path | None = None, *, database_url: str | None = None) -> FastAPI:
    if ruta_db is not None:
        origen = origen_inicial = ruta_db
    elif database_url is not None:
        origen = origen_inicial = database_url
    else:
        url, url_directa = urls_postgres()
        origen = url or Path(os.environ.get("CONTROL_ACADEMICO_DB", str(ARCHIVO_LOCAL)))
        origen_inicial = (url_directa or url) if url else origen

    @asynccontextmanager
    async def lifespan(api: FastAPI):
        if isinstance(origen, Path) and os.getenv("RENDER") == "true":
            raise RuntimeError("Configura DATABASE_URL con la URL de PostgreSQL de Neon en Render.")
        inicializar(origen_inicial)
        yield

    api = FastAPI(title="Control académico", version="1.0.0", lifespan=lifespan)
    api.state.origen_db = origen
    api.add_exception_handler(RequestValidationError, responder_validacion)
    api.add_exception_handler(ErrorNegocio, responder_negocio)

    for recurso in (estudiantes, asignaturas, notas):
        api.include_router(recurso.router, prefix="/api/v1")
    return api


app = crear_app()
