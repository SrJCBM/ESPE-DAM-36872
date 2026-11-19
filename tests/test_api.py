import os
import unittest
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from tempfile import TemporaryDirectory
from uuid import uuid4

import psycopg
from fastapi.testclient import TestClient
from psycopg import sql
from psycopg.conninfo import make_conninfo

from app.main import crear_app

API = "/api/v1"
ESTUDIANTE = {
    "codigo": " est001 ",
    "nombres": "Ana",
    "apellidos": "Torres",
    "correo": "ana@example.com",
}


class ControlAcademicoTest(unittest.TestCase):
    def setUp(self):
        self.cliente = self.enterContext(TestClient(self.aplicacion()))

    def aplicacion(self):
        if not hasattr(self, "ruta_db"):
            temporal = self.enterContext(TemporaryDirectory())
            self.ruta_db = Path(temporal) / "academico.sqlite3"
        return crear_app(self.ruta_db)

    def crear(self, recurso, datos):
        respuesta = self.cliente.post(f"{API}/{recurso}", json=datos)
        self.assertEqual(respuesta.status_code, 201, respuesta.text)
        return respuesta.json()

    def error(self, respuesta, estado, codigo):
        self.assertEqual(respuesta.status_code, estado, respuesta.text)
        self.assertEqual(respuesta.json()["detail"]["codigo"], codigo)

    def estudiante_y_asignatura(self):
        estudiante = self.crear("estudiantes", ESTUDIANTE)
        asignatura = self.crear("asignaturas", {"codigo": "MAT01", "nombre": "Matemática"})
        return estudiante["id"], asignatura["id"]

    def nota(self, estudiante_id, asignatura_id, valor):
        return {
            "estudiante_id": estudiante_id,
            "asignatura_id": asignatura_id,
            "valor": valor,
        }

    def test_crud_estudiante_y_asignatura(self):
        id_est, id_asig = self.estudiante_y_asignatura()
        est = f"{API}/estudiantes/{id_est}"
        asig = f"{API}/asignaturas/{id_asig}"
        self.assertEqual(self.cliente.get(est).json()["codigo"], "EST001")
        self.error(self.cliente.post(f"{API}/estudiantes", json=ESTUDIANTE),
                   409, "CODIGO_ESTUDIANTE_DUPLICADO")
        self.assertEqual(self.cliente.get(asig).json()["nombre"], "Matemática")
        self.assertEqual(self.cliente.patch(est, json={"nombres": "Ana María"}).json()["nombres"],
                         "Ana María")
        self.assertEqual(self.cliente.patch(asig, json={"nombre": "Álgebra"}).json()["nombre"],
                         "Álgebra")
        otra = self.crear("asignaturas", {"codigo": "FIS01", "nombre": "Física"})
        self.error(self.cliente.patch(f"{API}/asignaturas/{otra['id']}", json={"codigo": "mat01"}),
                   409, "CODIGO_ASIGNATURA_DUPLICADO")
        for ruta, codigo in ((est, "ESTUDIANTE_NO_EXISTE"), (asig, "ASIGNATURA_NO_EXISTE")):
            self.error(self.cliente.patch(ruta, json={}), 422, "DATOS_INVALIDOS")
            eliminado = self.cliente.delete(ruta)
            self.assertEqual((eliminado.status_code, eliminado.content), (204, b""))
            self.error(self.cliente.get(ruta), 404, codigo)

    def test_nota_unica_y_borrado_restringido(self):
        id_est, id_asig = self.estudiante_y_asignatura()
        est = f"{API}/estudiantes/{id_est}"
        asig = f"{API}/asignaturas/{id_asig}"
        datos = self.nota(id_est, id_asig, 13.99)
        nota = self.crear("notas", datos)
        ruta_nota = f"{API}/notas/{nota['id']}"
        ruta_anidada = f"{est}/asignaturas/{id_asig}/nota"
        self.assertEqual(nota["estado"], "RECUPERACION")
        self.assertEqual(self.cliente.get(ruta_nota).json(), nota)
        self.assertEqual(self.cliente.get(ruta_anidada).json(), nota)
        self.error(self.cliente.post(f"{API}/notas", json=datos), 409, "NOTA_DUPLICADA")
        self.error(self.cliente.delete(est), 409, "ESTUDIANTE_CON_NOTAS")
        self.error(self.cliente.delete(asig), 409, "ASIGNATURA_CON_NOTAS")
        self.error(self.cliente.patch(ruta_nota, json={"asignatura_id": id_asig, "valor": 14}),
                   422, "DATOS_INVALIDOS")
        self.assertEqual(self.cliente.patch(ruta_nota, json={"valor": 14}).json()["estado"],
                         "APROBADO")
        self.assertEqual(self.cliente.delete(ruta_nota).status_code, 204)
        self.error(self.cliente.get(ruta_anidada), 404, "NOTA_NO_EXISTE")
        self.assertEqual(self.cliente.delete(est).status_code, 204)
        self.assertEqual(self.cliente.delete(asig).status_code, 204)

    def test_limites_y_tipos_de_nota(self):
        id_est, id_asig = self.estudiante_y_asignatura()
        for valor in (-0.01, 20.01, 13.999, "14", True, None):
            with self.subTest(valor=valor):
                self.error(self.cliente.post(f"{API}/notas", json=self.nota(id_est, id_asig, valor)),
                           422, "DATOS_INVALIDOS")
        for literal in ("13.99999999999999999", "20.00000000000000001", "NaN", "Infinity"):
            with self.subTest(literal=literal):
                self.error(self.cliente.post(
                    f"{API}/notas",
                    content=f'{{"estudiante_id": {id_est}, "asignatura_id": {id_asig}, "valor": {literal}}}',
                    headers={"Content-Type": "application/json"},
                ), 422, "DATOS_INVALIDOS")
        nota = self.crear("notas", self.nota(id_est, id_asig, 0))
        ruta = f"{API}/notas/{nota['id']}"
        for valor, estado in ((0, "REPROBADO"), (8.99, "REPROBADO"), (9, "RECUPERACION"),
                              (13.99, "RECUPERACION"), (14, "APROBADO"), (20, "APROBADO")):
            with self.subTest(valor=valor):
                respuesta = self.cliente.patch(ruta, json={"valor": valor})
                self.assertEqual(respuesta.status_code, 200, respuesta.text)
                self.assertEqual((respuesta.json()["valor"], respuesta.json()["estado"]),
                                 (valor, estado))

    def test_promedio_cambia_al_editar_y_eliminar(self):
        id_est, id_asig = self.estudiante_y_asignatura()
        ruta = f"{API}/estudiantes/{id_est}/resumen-academico"
        inicial = self.cliente.get(ruta).json()
        self.assertEqual((inicial["promedio"], inicial["total_notas"], inicial["notas"]),
                         (None, 0, []))
        otra = self.crear("asignaturas", {"codigo": "FIS01", "nombre": "Física"})
        self.crear("notas", self.nota(id_est, id_asig, 15.5))
        nota = self.crear("notas", self.nota(id_est, otra["id"], 12))
        resumen = self.cliente.get(ruta).json()
        self.assertEqual((resumen["promedio"], resumen["total_notas"]), (13.75, 2))
        self.assertEqual(resumen["notas"][1]["asignatura"], otra)
        ruta_nota = f"{API}/notas/{nota['id']}"
        self.cliente.patch(ruta_nota, json={"valor": 12.01})
        self.assertEqual(self.cliente.get(ruta).json()["promedio"], 13.76)
        self.cliente.patch(ruta_nota, json={"valor": 0})
        self.assertEqual(self.cliente.get(ruta).json()["promedio"], 7.75)
        self.cliente.delete(ruta_nota)
        self.assertEqual(self.cliente.get(ruta).json()["promedio"], 15.5)

    def test_listados_y_referencias_inexistentes(self):
        id_est, id_asig = self.estudiante_y_asignatura()
        est = f"{API}/estudiantes/{id_est}/notas"
        asig = f"{API}/asignaturas/{id_asig}/notas"
        vacio = {"items": [], "total": 0, "limit": 20, "offset": 0}
        self.assertEqual(self.cliente.get(est).json(), vacio)
        self.error(self.cliente.get(f"{API}/asignaturas/999/notas"), 404, "ASIGNATURA_NO_EXISTE")
        self.error(self.cliente.get(f"{API}/estudiantes/999/notas"), 404, "ESTUDIANTE_NO_EXISTE")
        for estudiante, asignatura, error in (
            (999, 999, "ESTUDIANTE_NO_EXISTE"), (id_est, 999, "ASIGNATURA_NO_EXISTE"),
        ):
            self.error(self.cliente.post(f"{API}/notas", json=self.nota(estudiante, asignatura, 15)),
                       404, error)
        nota = self.crear("notas", self.nota(id_est, id_asig, 17))
        for ruta in (est, asig, f"{API}/notas"):
            self.assertEqual(self.cliente.get(ruta).json()["items"], [nota])
            self.assertEqual(self.cliente.get(f"{ruta}?limit=1&offset=1").json(),
                             {"items": [], "total": 1, "limit": 1, "offset": 1})
        self.error(self.cliente.get(f"{est}?limit=0"), 422, "DATOS_INVALIDOS")
        self.error(self.cliente.get(f"{API}/notas/0"), 422, "DATOS_INVALIDOS")

    def test_solicitudes_invalidas_no_devuelven_el_cuerpo(self):
        ruta = f"{API}/estudiantes"
        for contenido in ({"correo": "no es un correo"}, {"correo": None}, {"id": 3},
                          {"nombres": "  "}, {"codigo": "Á-123"}):
            with self.subTest(contenido=contenido):
                respuesta = self.cliente.post(ruta, json={**ESTUDIANTE, **contenido})
                self.error(respuesta, 422, "DATOS_INVALIDOS")
                detalle = respuesta.json()["detail"]["errores"][0]
                self.assertEqual(set(detalle), {"ubicacion", "mensaje"})
        invalido = self.cliente.post(ruta, content="{", headers={"Content-Type": "application/json"})
        self.error(invalido, 422, "DATOS_INVALIDOS")

    def test_persistencia_entre_instancias_y_documentacion(self):
        id_est, id_asig = self.estudiante_y_asignatura()
        nota = self.crear("notas", self.nota(id_est, id_asig, 16.25))
        with TestClient(self.aplicacion()) as nueva:
            self.assertEqual(nueva.get(f"{API}/notas/{nota['id']}").json(), nota)
            self.assertEqual(nueva.get("/docs").status_code, 200)
            rutas = nueva.get("/openapi.json").json()["paths"]
            operaciones = sum(len(operaciones) for ruta, operaciones in rutas.items()
                              if ruta.startswith(API))
            self.assertEqual(operaciones, 19)
            contrato = rutas[f"{API}/estudiantes/{{estudiante_id}}/asignaturas/{{asignatura_id}}/nota"]
            self.assertEqual([p["in"] for p in contrato["get"]["parameters"]], ["path", "path"])

    def test_solo_una_de_dos_notas_concurrentes_se_guarda(self):
        id_est, id_asig = self.estudiante_y_asignatura()
        datos = self.nota(id_est, id_asig, 15)
        with ThreadPoolExecutor(max_workers=2) as grupo:
            a = grupo.submit(self.cliente.post, f"{API}/notas", json=datos)
            b = grupo.submit(self.cliente.post, f"{API}/notas", json=datos)
            respuestas = sorted((a.result(), b.result()), key=lambda r: r.status_code)
        self.assertEqual(respuestas[0].status_code, 201)
        self.error(respuestas[1], 409, "NOTA_DUPLICADA")
        self.assertEqual(self.cliente.get(f"{API}/notas").json()["total"], 1)


@unittest.skipUnless(os.environ.get("TEST_DATABASE_URL"), "Sin PostgreSQL de pruebas.")
class ControlAcademicoPostgresTest(ControlAcademicoTest):
    def aplicacion(self):
        if not hasattr(self, "database_url"):
            dsn = os.environ["TEST_DATABASE_URL"]
            nombre = f"test_{uuid4().hex}"
            esquema = sql.Identifier(nombre)
            with psycopg.connect(dsn) as conexion:
                conexion.execute(sql.SQL("CREATE SCHEMA {}").format(esquema))

            def limpiar():
                with psycopg.connect(dsn) as conexion:
                    conexion.execute(sql.SQL("DROP SCHEMA {} CASCADE").format(esquema))

            self.addCleanup(limpiar)
            self.database_url = make_conninfo(dsn, options=f"-c search_path={nombre}")
        return crear_app(database_url=self.database_url)
