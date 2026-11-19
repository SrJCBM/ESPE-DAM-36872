from decimal import Decimal, DecimalException
from typing import Annotated, Literal

from pydantic import (
    BaseModel, BeforeValidator, ConfigDict, EmailStr, Field, with_config,
)
from typing_extensions import TypedDict

MAX_ENTERO_SQLITE = 2**63 - 1


def normalizar_codigo(valor: object) -> object:
    if not isinstance(valor, str):
        return valor
    codigo = valor.strip()
    return codigo.upper() if codigo.isascii() else codigo


def validar_valor(valor: object) -> Decimal:
    mensaje = "La nota debe ser un número de 0 a 20 con un máximo de dos decimales."
    if type(valor) not in (int, float, Decimal):
        raise ValueError(mensaje)
    try:
        decimal = Decimal(str(valor))
        if not decimal.is_finite() or not 0 <= decimal <= 20:
            raise ValueError(mensaje)
        centesimas = decimal.quantize(Decimal("0.01"))
        if decimal != centesimas:
            raise ValueError(mensaje)
    except DecimalException as error:
        raise ValueError(mensaje) from error
    return centesimas


def exigir_cambios(datos: object) -> object:
    if isinstance(datos, dict) and not datos:
        raise ValueError("Envía al menos un campo para actualizar.")
    return datos


Codigo = Annotated[
    str, Field(min_length=1, max_length=32, pattern=r"^[A-Z0-9._-]+$"),
    BeforeValidator(normalizar_codigo),
]
NombrePersona = Annotated[str, Field(min_length=1, max_length=100)]
NombreAsignatura = Annotated[str, Field(min_length=1, max_length=150)]
Correo = Annotated[EmailStr, Field(max_length=254)]
IdCuerpo = Annotated[int, Field(strict=True, ge=1, le=MAX_ENTERO_SQLITE)]
NotaJson = Annotated[float, Field(ge=0, le=20, multiple_of=0.01)]
ValorNota = Annotated[Decimal, BeforeValidator(validar_valor, json_schema_input_type=NotaJson)]
Estado = Literal["APROBADO", "RECUPERACION", "REPROBADO"]

config_entrada = ConfigDict(extra="forbid", str_strip_whitespace=True)


class Entrada(BaseModel):
    model_config = config_entrada


class EstudianteCrear(Entrada):
    codigo: Codigo
    nombres: NombrePersona
    apellidos: NombrePersona
    correo: Correo


class AsignaturaCrear(Entrada):
    codigo: Codigo
    nombre: NombreAsignatura


@with_config(config_entrada)
class EstudianteCambios(TypedDict, total=False):
    codigo: Codigo
    nombres: NombrePersona
    apellidos: NombrePersona
    correo: Correo


@with_config(config_entrada)
class AsignaturaCambios(TypedDict, total=False):
    codigo: Codigo
    nombre: NombreAsignatura


EstudianteActualizar = Annotated[EstudianteCambios, BeforeValidator(exigir_cambios)]
AsignaturaActualizar = Annotated[AsignaturaCambios, BeforeValidator(exigir_cambios)]


class NotaActualizar(Entrada):
    valor: ValorNota


class NotaCrear(NotaActualizar):
    estudiante_id: IdCuerpo
    asignatura_id: IdCuerpo


class Estudiante(EstudianteCrear):
    id: int


class Asignatura(AsignaturaCrear):
    id: int


class Nota(BaseModel):
    id: int
    estudiante_id: int
    asignatura_id: int
    valor: float
    estado: Estado


class NotaResumen(BaseModel):
    id: int
    asignatura: Asignatura
    valor: float
    estado: Estado


class ResumenAcademico(BaseModel):
    estudiante: Estudiante
    total_notas: int
    promedio: float | None
    notas: list[NotaResumen]


class Pagina[T](BaseModel):
    items: list[T]
    total: int
    limit: int
    offset: int


class DetalleError(BaseModel):
    codigo: str
    mensaje: str


class CampoInvalido(BaseModel):
    ubicacion: list[str | int]
    mensaje: str


class DetalleValidacion(DetalleError):
    errores: list[CampoInvalido]


class ErrorRespuesta(BaseModel):
    detail: DetalleError


class ErrorValidacionRespuesta(BaseModel):
    detail: DetalleValidacion
