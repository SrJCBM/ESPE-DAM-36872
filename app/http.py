import json
from collections.abc import Callable
from decimal import Decimal
from typing import Annotated

from fastapi import Depends, Path, Query, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi.routing import APIRoute

from .esquemas import ErrorRespuesta, ErrorValidacionRespuesta, MAX_ENTERO_SQLITE
from .servicios import ErrorNegocio

IdRuta = Annotated[int, Path(ge=1, le=MAX_ENTERO_SQLITE)]


class Paginacion:
    def __init__(self, limit: Annotated[int, Query(ge=1, le=100)] = 20,
                 offset: Annotated[int, Query(ge=0)] = 0):
        self.limit = limit
        self.offset = offset


ParametrosPagina = Annotated[Paginacion, Depends(Paginacion)]

NO_ENCONTRADO = {404: {"model": ErrorRespuesta, "description": "Recurso inexistente"}}
CONFLICTO = {409: {"model": ErrorRespuesta, "description": "Conflicto con datos existentes"}}
VALIDACION = {422: {"model": ErrorValidacionRespuesta, "description": "Datos inválidos"}}


class SolicitudDecimal(Request):
    async def json(self):
        # Conserva el valor original antes de validar las centésimas.
        return json.loads(await self.body(), parse_float=Decimal, parse_constant=Decimal)


class RutaDecimal(APIRoute):
    def get_route_handler(self) -> Callable:
        manejar_ruta = super().get_route_handler()

        async def manejar_solicitud(request: Request):
            return await manejar_ruta(SolicitudDecimal(request.scope, request.receive))

        return manejar_solicitud


def mensaje_validacion(tipo: str, ubicacion: tuple) -> str:
    mensajes = {
        "missing": "Este campo es obligatorio.",
        "extra_forbidden": "Este campo no está permitido.",
        "string_type": "Ingresa un texto válido.",
        "string_too_short": "El texto no puede quedar vacío.",
        "string_too_long": "El texto supera la longitud permitida.",
        "string_pattern_mismatch": "Usa letras sin tildes, números, punto, guion o guion bajo.",
        "int_parsing": "Ingresa un número entero.",
        "int_type": "Ingresa un número entero.",
        "greater_than_equal": "El número es menor que el mínimo permitido.",
        "less_than_equal": "El número supera el máximo permitido.",
        "json_invalid": "El cuerpo no contiene JSON válido.",
    }
    if tipo == "value_error":
        campo = ubicacion[-1] if ubicacion else None
        return {
            "valor": "La nota debe ser un número de 0 a 20 con un máximo de dos decimales.",
            "correo": "Ingresa una dirección de correo válida.",
            "body": "Envía al menos un campo para actualizar.",
        }.get(campo, "El valor enviado no es válido.")
    return mensajes.get(tipo, "El valor enviado no es válido.")


async def responder_validacion(request: Request, error: RequestValidationError) -> JSONResponse:
    errores = [
        {"ubicacion": list(item["loc"]), "mensaje": mensaje_validacion(item["type"], item["loc"])}
        for item in error.errors()
    ]
    return JSONResponse(status_code=422, content={
        "detail": {
            "codigo": "DATOS_INVALIDOS",
            "mensaje": "Revisa los datos enviados.",
            "errores": errores,
        }
    })


async def responder_negocio(request: Request, error: ErrorNegocio) -> JSONResponse:
    return JSONResponse(status_code=error.estado, content={
        "detail": {"codigo": error.codigo, "mensaje": error.mensaje}
    })
