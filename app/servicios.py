from dataclasses import dataclass
from decimal import Decimal, ROUND_HALF_UP

from . import repositorio
from .base_datos import ErrorReferencia, ErrorUnicidad, Sesion
from .esquemas import Estado

class ErrorNegocio(Exception):
    def __init__(self, estado: int, codigo: str, mensaje: str):
        super().__init__(mensaje)
        self.estado = estado
        self.codigo = codigo
        self.mensaje = mensaje


@dataclass(frozen=True)
class Recurso:
    tabla: repositorio.Tabla
    nombre: str
    no_existe: str
    codigo_duplicado: str
    con_notas: str


ESTUDIANTES = Recurso("estudiantes", "estudiante", "ESTUDIANTE_NO_EXISTE",
                      "CODIGO_ESTUDIANTE_DUPLICADO", "ESTUDIANTE_CON_NOTAS")
ASIGNATURAS = Recurso("asignaturas", "asignatura", "ASIGNATURA_NO_EXISTE",
                      "CODIGO_ASIGNATURA_DUPLICADO", "ASIGNATURA_CON_NOTAS")


def obtener(db: Sesion, recurso: Recurso, id: int, *, bloquear: bool = False) -> dict:
    registro = repositorio.buscar(db, recurso.tabla, id=id, bloquear=bloquear)
    if registro is None:
        raise ErrorNegocio(404, recurso.no_existe, f"No se encontró {recurso.nombre} con ID {id}.")
    return registro


def crear(db: Sesion, recurso: Recurso, datos: dict) -> dict:
    try:
        return repositorio.insertar(db, recurso.tabla, datos)
    except ErrorUnicidad as error:
        raise ErrorNegocio(409, recurso.codigo_duplicado,
                           f"Ya existe un registro de {recurso.nombre} con ese código.") from error


def editar(db: Sesion, recurso: Recurso, id: int, datos: dict) -> dict:
    try:
        registro = repositorio.actualizar(db, recurso.tabla, id, datos)
    except ErrorUnicidad as error:
        raise ErrorNegocio(409, recurso.codigo_duplicado,
                           f"Ya existe un registro de {recurso.nombre} con ese código.") from error
    if registro is None:
        raise ErrorNegocio(404, recurso.no_existe, f"No se encontró {recurso.nombre} con ID {id}.")
    return registro


def eliminar(db: Sesion, recurso: Recurso, id: int) -> None:
    # La clave foránea RESTRICT aplica incluso si otra solicitud acaba de crear una nota.
    try:
        eliminado = repositorio.eliminar(db, recurso.tabla, id)
    except ErrorReferencia as error:
        raise ErrorNegocio(409, recurso.con_notas,
                           f"Elimina primero las notas asociadas a {recurso.nombre}.") from error
    if not eliminado:
        raise ErrorNegocio(404, recurso.no_existe, f"No se encontró {recurso.nombre} con ID {id}.")


def estado_nota(centesimas: int) -> Estado:
    if centesimas >= 1400:
        return "APROBADO"
    if centesimas >= 900:
        return "RECUPERACION"
    return "REPROBADO"


def nota_publica(registro: dict | None) -> dict:
    if registro is None:
        raise ErrorNegocio(404, "NOTA_NO_EXISTE", "No se encontró la nota.")
    return {
        "id": registro["id"],
        "estudiante_id": registro["estudiante_id"],
        "asignatura_id": registro["asignatura_id"],
        "valor": registro["valor_centesimas"] / 100,
        "estado": estado_nota(registro["valor_centesimas"]),
    }


def pagina(db: Sesion, tabla: repositorio.Tabla, limit: int, offset: int,
           filtros: repositorio.Condiciones | None = None) -> dict:
    items, total = repositorio.listar(db, tabla, limit, offset, filtros)
    if tabla == "notas":
        items = [nota_publica(nota) for nota in items]
    return {"items": items, "total": total, "limit": limit, "offset": offset}


def crear_nota(db: Sesion, estudiante_id: int, asignatura_id: int,
               valor: Decimal) -> dict:
    obtener(db, ESTUDIANTES, estudiante_id, bloquear=True)
    obtener(db, ASIGNATURAS, asignatura_id, bloquear=True)
    try:
        registro = repositorio.insertar(db, "notas", {
            "estudiante_id": estudiante_id,
            "asignatura_id": asignatura_id,
            "valor_centesimas": int(valor * 100),
        })
    except ErrorUnicidad as error:
        raise ErrorNegocio(409, "NOTA_DUPLICADA",
                           "El estudiante ya tiene una nota para esta asignatura.") from error
    return nota_publica(registro)


def editar_nota(db: Sesion, id: int, valor: Decimal) -> dict:
    registro = repositorio.actualizar(db, "notas", id, {"valor_centesimas": int(valor * 100)})
    return nota_publica(registro)


def eliminar_nota(db: Sesion, id: int) -> None:
    if not repositorio.eliminar(db, "notas", id):
        raise ErrorNegocio(404, "NOTA_NO_EXISTE", "No se encontró la nota.")


def nota_por_asignatura(db: Sesion, estudiante_id: int, asignatura_id: int) -> dict:
    obtener(db, ESTUDIANTES, estudiante_id)
    obtener(db, ASIGNATURAS, asignatura_id)
    return nota_publica(repositorio.buscar(db, "notas", estudiante_id=estudiante_id,
                                          asignatura_id=asignatura_id))


def resumen_academico(db: Sesion, estudiante_id: int) -> dict:
    estudiante = obtener(db, ESTUDIANTES, estudiante_id)
    filas = repositorio.notas_del_resumen(db, estudiante_id)
    promedio = None
    if filas:
        total_centesimas = sum(fila["valor_centesimas"] for fila in filas)
        media = Decimal(total_centesimas) / (100 * len(filas))
        promedio = float(media.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP))
    return {
        "estudiante": estudiante,
        "total_notas": len(filas),
        "promedio": promedio,
        "notas": [
            {
                "id": fila["id"],
                "asignatura": {"id": fila["asignatura_id"], "codigo": fila["codigo"],
                               "nombre": fila["nombre"]},
                "valor": fila["valor_centesimas"] / 100,
                "estado": estado_nota(fila["valor_centesimas"]),
            }
            for fila in filas
        ],
    }
