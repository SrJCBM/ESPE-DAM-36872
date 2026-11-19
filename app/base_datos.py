import sqlite3
from collections.abc import Iterator
from contextlib import closing
from pathlib import Path
from typing import Annotated

import psycopg
from fastapi import Depends, Request
from psycopg.errors import ForeignKeyViolation, RestrictViolation, UniqueViolation
from psycopg.rows import dict_row

ESQUEMA = """
CREATE TABLE IF NOT EXISTS estudiantes (
    id {clave},
    codigo TEXT NOT NULL UNIQUE,
    nombres TEXT NOT NULL,
    apellidos TEXT NOT NULL,
    correo TEXT NOT NULL
){modo};

CREATE TABLE IF NOT EXISTS asignaturas (
    id {clave},
    codigo TEXT NOT NULL UNIQUE,
    nombre TEXT NOT NULL
){modo};

CREATE TABLE IF NOT EXISTS notas (
    id {clave},
    estudiante_id {referencia} NOT NULL REFERENCES estudiantes (id) ON DELETE RESTRICT,
    asignatura_id {referencia} NOT NULL REFERENCES asignaturas (id) ON DELETE RESTRICT,
    valor_centesimas INTEGER NOT NULL CHECK (valor_centesimas BETWEEN 0 AND 2000),
    UNIQUE (estudiante_id, asignatura_id)
){modo};

CREATE INDEX IF NOT EXISTS notas_asignatura_idx ON notas (asignatura_id);
"""
ESQUEMA_SQLITE = ESQUEMA.format(clave="INTEGER PRIMARY KEY AUTOINCREMENT",
                               referencia="INTEGER", modo=" STRICT")
ESQUEMA_POSTGRES = ESQUEMA.format(clave="BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY",
                                 referencia="BIGINT", modo="")


class ErrorUnicidad(Exception):
    """El valor ya existe en una columna o combinación única."""


class ErrorReferencia(Exception):
    """La operación infringe una clave foránea."""


class Sesion:
    def __init__(self, conexion: sqlite3.Connection | psycopg.Connection):
        self.conexion = conexion
        self.es_postgres = isinstance(conexion, psycopg.Connection)

    def execute(self, consulta: str, parametros: tuple = ()):
        # Las consultas del repositorio usan ? solo como marcador de parámetros.
        if self.es_postgres:
            consulta = consulta.replace("?", "%s")
        try:
            return self.conexion.execute(consulta, parametros)
        except UniqueViolation as error:
            raise ErrorUnicidad from error
        except (ForeignKeyViolation, RestrictViolation) as error:
            raise ErrorReferencia from error
        except sqlite3.IntegrityError as error:
            if error.sqlite_errorcode == sqlite3.SQLITE_CONSTRAINT_UNIQUE:
                raise ErrorUnicidad from error
            if error.sqlite_errorcode in (sqlite3.SQLITE_CONSTRAINT_TRIGGER,
                                          sqlite3.SQLITE_CONSTRAINT_FOREIGNKEY):
                raise ErrorReferencia from error
            raise


def conectar_sqlite(ruta: Path) -> sqlite3.Connection:
    conexion = sqlite3.connect(ruta, timeout=10, check_same_thread=False)
    conexion.row_factory = sqlite3.Row
    conexion.execute("PRAGMA foreign_keys = ON")
    return conexion


def conectar_postgres(database_url: str):
    return psycopg.connect(database_url, row_factory=dict_row, connect_timeout=10)


def inicializar(origen: Path | str) -> None:
    if isinstance(origen, str):
        with conectar_postgres(origen) as conexion:
            # Serializa la creación del esquema si dos procesos arrancan a la vez.
            conexion.execute("SELECT pg_advisory_xact_lock(784202601)")
            for sentencia in ESQUEMA_POSTGRES.split(";"):
                if sentencia.strip():
                    conexion.execute(sentencia)
        return

    origen.parent.mkdir(parents=True, exist_ok=True)
    with closing(conectar_sqlite(origen)) as conexion:
        conexion.execute("PRAGMA journal_mode = WAL")
        conexion.executescript(ESQUEMA_SQLITE)


def abrir_transaccion(request: Request) -> Iterator[Sesion]:
    origen = request.app.state.origen_db
    escritura = request.method in {"POST", "PATCH", "DELETE"}
    if isinstance(origen, str):
        with conectar_postgres(origen) as conexion:
            if not escritura:
                # Mantiene listados y resúmenes en la misma versión de los datos.
                conexion.execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY")
            yield Sesion(conexion)
        return

    with closing(conectar_sqlite(origen)) as conexion, conexion:
        conexion.execute("BEGIN IMMEDIATE" if escritura else "BEGIN")
        yield Sesion(conexion)


Conexion = Annotated[Sesion, Depends(abrir_transaccion, scope="function")]
