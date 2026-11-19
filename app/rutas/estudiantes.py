from fastapi import APIRouter, Response

from .. import servicios
from ..base_datos import Conexion
from ..esquemas import Estudiante, EstudianteActualizar, EstudianteCrear, Nota, Pagina, ResumenAcademico
from ..http import CONFLICTO, NO_ENCONTRADO, VALIDACION, IdRuta, ParametrosPagina

router = APIRouter(prefix="/estudiantes", tags=["Estudiantes"], responses=VALIDACION)


@router.get("", response_model=Pagina[Estudiante])
def listar(db: Conexion, pag: ParametrosPagina):
    return servicios.pagina(db, "estudiantes", pag.limit, pag.offset)


@router.post("", response_model=Estudiante, status_code=201, responses=CONFLICTO)
def crear(datos: EstudianteCrear, db: Conexion):
    return servicios.crear(db, servicios.ESTUDIANTES, datos.model_dump())


@router.get("/{id}", response_model=Estudiante, responses=NO_ENCONTRADO)
def obtener(id: IdRuta, db: Conexion):
    return servicios.obtener(db, servicios.ESTUDIANTES, id)


@router.patch("/{id}", response_model=Estudiante, responses=NO_ENCONTRADO | CONFLICTO)
def editar(id: IdRuta, datos: EstudianteActualizar, db: Conexion):
    return servicios.editar(db, servicios.ESTUDIANTES, id, datos)


@router.delete("/{id}", status_code=204, responses=NO_ENCONTRADO | CONFLICTO)
def eliminar(id: IdRuta, db: Conexion) -> Response:
    servicios.eliminar(db, servicios.ESTUDIANTES, id)
    return Response(status_code=204)


@router.get("/{estudiante_id}/notas", response_model=Pagina[Nota], responses=NO_ENCONTRADO)
def listar_notas(estudiante_id: IdRuta, db: Conexion, pag: ParametrosPagina):
    servicios.obtener(db, servicios.ESTUDIANTES, estudiante_id)
    return servicios.pagina(db, "notas", pag.limit, pag.offset, {"estudiante_id": estudiante_id})


@router.get("/{estudiante_id}/asignaturas/{asignatura_id}/nota", response_model=Nota,
            responses=NO_ENCONTRADO)
def obtener_nota(estudiante_id: IdRuta, asignatura_id: IdRuta, db: Conexion):
    return servicios.nota_por_asignatura(db, estudiante_id, asignatura_id)


@router.get("/{id}/resumen-academico", response_model=ResumenAcademico, responses=NO_ENCONTRADO)
def resumen(id: IdRuta, db: Conexion):
    return servicios.resumen_academico(db, id)
