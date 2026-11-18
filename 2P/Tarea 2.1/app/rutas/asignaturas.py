from fastapi import APIRouter, Response

from .. import servicios
from ..base_datos import Conexion
from ..esquemas import Asignatura, AsignaturaActualizar, AsignaturaCrear, Nota, Pagina
from ..http import CONFLICTO, NO_ENCONTRADO, VALIDACION, IdRuta, ParametrosPagina

router = APIRouter(prefix="/asignaturas", tags=["Asignaturas"], responses=VALIDACION)


@router.get("", response_model=Pagina[Asignatura])
def listar(db: Conexion, pag: ParametrosPagina):
    return servicios.pagina(db, "asignaturas", pag.limit, pag.offset)


@router.post("", response_model=Asignatura, status_code=201, responses=CONFLICTO)
def crear(datos: AsignaturaCrear, db: Conexion):
    return servicios.crear(db, servicios.ASIGNATURAS, datos.model_dump())


@router.get("/{id}", response_model=Asignatura, responses=NO_ENCONTRADO)
def obtener(id: IdRuta, db: Conexion):
    return servicios.obtener(db, servicios.ASIGNATURAS, id)


@router.patch("/{id}", response_model=Asignatura, responses=NO_ENCONTRADO | CONFLICTO)
def editar(id: IdRuta, datos: AsignaturaActualizar, db: Conexion):
    return servicios.editar(db, servicios.ASIGNATURAS, id, datos)


@router.delete("/{id}", status_code=204, responses=NO_ENCONTRADO | CONFLICTO)
def eliminar(id: IdRuta, db: Conexion) -> Response:
    servicios.eliminar(db, servicios.ASIGNATURAS, id)
    return Response(status_code=204)


@router.get("/{asignatura_id}/notas", response_model=Pagina[Nota], responses=NO_ENCONTRADO)
def listar_notas(asignatura_id: IdRuta, db: Conexion, pag: ParametrosPagina):
    servicios.obtener(db, servicios.ASIGNATURAS, asignatura_id)
    return servicios.pagina(db, "notas", pag.limit, pag.offset, {"asignatura_id": asignatura_id})
