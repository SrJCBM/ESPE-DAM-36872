from typing import Literal

from .base_datos import Sesion
from .esquemas import MAX_ENTERO_SQLITE

Tabla = Literal["estudiantes", "asignaturas", "notas"]
Condiciones = dict[str, int]


def buscar(db: Sesion, tabla: Tabla, *, bloquear: bool = False, **condiciones: int) -> dict | None:
    # Los nombres SQL proceden de las rutas y los esquemas, no de datos del cliente.
    clausula = " AND ".join(f"{campo} = ?" for campo in condiciones)
    bloqueo = " FOR KEY SHARE" if bloquear and db.es_postgres else ""
    fila = db.execute(f"SELECT * FROM {tabla} WHERE {clausula}{bloqueo}",
                      tuple(condiciones.values())).fetchone()
    return dict(fila) if fila is not None else None


def listar(db: Sesion, tabla: Tabla, limit: int, offset: int,
           condiciones: Condiciones | None = None) -> tuple[list[dict], int]:
    filtros = condiciones or {}
    where = " AND ".join(f"{campo} = ?" for campo in filtros)
    origen = f"FROM {tabla} WHERE {where}" if where else f"FROM {tabla}"
    valores = tuple(filtros.values())
    total = db.execute(f"SELECT COUNT(*) AS total {origen}", valores).fetchone()["total"]
    filas = db.execute(
        f"SELECT * {origen} ORDER BY id LIMIT ? OFFSET ?",
        (*valores, limit, min(offset, MAX_ENTERO_SQLITE)),
    )
    return [dict(fila) for fila in filas], total


def insertar(db: Sesion, tabla: Tabla, datos: dict) -> dict:
    campos = ", ".join(datos)
    parametros = ", ".join("?" for _ in datos)
    fila = db.execute(
        f"INSERT INTO {tabla} ({campos}) VALUES ({parametros}) RETURNING *",
        tuple(datos.values()),
    ).fetchone()
    return dict(fila)


def actualizar(db: Sesion, tabla: Tabla, id: int, datos: dict) -> dict | None:
    campos = ", ".join(f"{campo} = ?" for campo in datos)
    fila = db.execute(
        f"UPDATE {tabla} SET {campos} WHERE id = ? RETURNING *", (*datos.values(), id)
    ).fetchone()
    return dict(fila) if fila is not None else None


def eliminar(db: Sesion, tabla: Tabla, id: int) -> bool:
    return db.execute(f"DELETE FROM {tabla} WHERE id = ?", (id,)).rowcount > 0


def notas_del_resumen(db: Sesion, estudiante_id: int) -> list[dict]:
    filas = db.execute(
        """
        SELECT notas.id, notas.valor_centesimas, asignaturas.id AS asignatura_id,
               asignaturas.codigo, asignaturas.nombre
        FROM notas JOIN asignaturas ON asignaturas.id = notas.asignatura_id
        WHERE notas.estudiante_id = ? ORDER BY asignaturas.id
        """,
        (estudiante_id,),
    )
    return [dict(fila) for fila in filas]
