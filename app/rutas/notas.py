from fastapi import APIRouter, Response

from .. import repositorio, servicios
from ..base_datos import Conexion
from ..esquemas import Nota, NotaActualizar, NotaCrear, Pagina
from ..http import CONFLICTO, NO_ENCONTRADO, VALIDACION, IdRuta, ParametrosPagina, RutaDecimal

router = APIRouter(prefix="/notas", tags=["Notas"], responses=VALIDACION, route_class=RutaDecimal)


@router.get("", response_model=Pagina[Nota])
def listar(db: Conexion, pag: ParametrosPagina):
    return servicios.pagina(db, "notas", pag.limit, pag.offset)


@router.post("", response_model=Nota, status_code=201, responses=NO_ENCONTRADO | CONFLICTO)
def crear(datos: NotaCrear, db: Conexion):
    return servicios.crear_nota(db, datos.estudiante_id, datos.asignatura_id, datos.valor)


@router.get("/{id}", response_model=Nota, responses=NO_ENCONTRADO)
def obtener(id: IdRuta, db: Conexion):
    return servicios.nota_publica(repositorio.buscar(db, "notas", id=id))


@router.patch("/{id}", response_model=Nota, responses=NO_ENCONTRADO)
def editar(id: IdRuta, datos: NotaActualizar, db: Conexion):
    return servicios.editar_nota(db, id, datos.valor)


@router.delete("/{id}", status_code=204, responses=NO_ENCONTRADO)
def eliminar(id: IdRuta, db: Conexion) -> Response:
    servicios.eliminar_nota(db, id)
    return Response(status_code=204)
