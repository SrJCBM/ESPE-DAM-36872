# Control académico · Caso 3

API REST para registrar estudiantes, asignaturas y una nota final por cada pareja de estudiante y asignatura. FastAPI sirve el contrato JSON que consumirá Flutter. El backend guarda las notas como centésimas enteras para calcular el promedio con precisión. Usa SQLite en local y PostgreSQL cuando se configura `DATABASE_URL`.

Para preparar el informe, consulta la [guía y el guion de demostración](docs/GUIA_INFORME.md), la [referencia de la API](docs/API_REST.md) y la [documentación de Flutter](docs/APP_FLUTTER.md).

## Ejecutar en Windows

Abre PowerShell en la carpeta de la tarea. Usa Python 3.12 y un entorno virtual para instalar los paquetes del proyecto. SQLite viene con Python.

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload
```

Abre [Swagger UI](http://127.0.0.1:8000/docs) para probar las rutas o [OpenAPI](http://127.0.0.1:8000/openapi.json) para ver el contrato. Cuando no se configura PostgreSQL, SQLite se crea al iniciar en `data/control_academico.sqlite3`. Puedes elegir otro archivo mediante `CONTROL_ACADEMICO_DB`.

Al ejecutar `neon deploy` desde esta carpeta, la CLI descarga las variables de la rama vinculada en `.env.local`, o en `.env` si ya existe. FastAPI lee ese archivo al iniciar localmente. `DATABASE_URL` se usa en las solicitudes y `DATABASE_URL_UNPOOLED` para inicializar las tablas. Las variables del proceso tienen prioridad. Los archivos con credenciales están excluidos de Git.

Si Node.js está instalado, `npm run build` comprueba que el código Python de la API compila. Ejecuta el comando con el entorno virtual activado.

## Probar el flujo desde Swagger

1. Crea un estudiante con `POST /api/v1/estudiantes`. Ejemplo de campos: `codigo` = `EST001`, `nombres` = `Ana`, `apellidos` = `Torres`, `correo` = `ana@example.com`.
2. Crea una asignatura con `POST /api/v1/asignaturas`. Ejemplo: `codigo` = `MAT01`, `nombre` = `Matemática`.
3. Registra la nota con `POST /api/v1/notas`, usando los identificadores devueltos. Si son 1 y 2, envía `{"estudiante_id": 1, "asignatura_id": 2, "valor": 15.5}`.
4. Consulta esa calificación con `GET /api/v1/estudiantes/1/asignaturas/2/nota`. Sustituye 1 y 2 por los identificadores obtenidos.
5. Consulta `GET /api/v1/estudiantes/1/resumen-academico` para ver todas sus notas y el promedio.

Las notas se pueden corregir con `PATCH /api/v1/notas/{id}`, enviando el nuevo `valor`. Los listados admiten `limit` y `offset` para paginación. Emplea datos ficticios para la demostración del proyecto.

## Alojar la API en Render con PostgreSQL en Neon

Render ejecuta FastAPI y proporciona la URL HTTPS pública. Neon guarda los registros en PostgreSQL para que sobrevivan a los reinicios y despliegues de Render.

### 1. Publicar la tarea en GitHub

Render tomará el código de la rama `main` del repositorio de GitHub. Antes de crear el servicio, verifica que `2P/Tarea 2.1` aparezca en esa rama.

### 2. Crear la base en Neon

1. Abre la [consola de Neon](https://console.neon.tech/) y crea un proyecto en el plan **Free**.
2. Usa las variables que descargó `neon deploy`. También puedes obtener las dos URL en **Connect** cambiando el selector **Connection pooling**. Conserva completos los parámetros TLS.
3. En Render, pega la URL con pooling en `DATABASE_URL` y la directa en `DATABASE_URL_UNPOOLED`. Ambas URL contienen contraseñas. [Conexión a Neon](https://neon.com/docs/connect/connect-from-any-app)

### 3. Crear el servicio de FastAPI en Render

En el [panel de Render](https://dashboard.render.com/), elige **New → Web Service**, conecta el repositorio de GitHub y configura el servicio.

| Campo de Render | Valor |
|---|---|
| Branch | `main` |
| Root Directory | `2P/Tarea 2.1` |
| Language | Python 3 |
| Instance Type | Free |
| Build Command | `pip install -r requirements.txt` |
| Start Command | `python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT` |
| Environment Variable | `PYTHON_VERSION` = `3.12.10` |
| Environment Variable | `DATABASE_URL` = URL con pooling de Neon |
| Environment Variable | `DATABASE_URL_UNPOOLED` = URL directa de Neon |

Pulsa **Deploy Web Service**. FastAPI crea las tablas que falten al arrancar. Render usará los registros de la rama de Neon seleccionada. [FastAPI en Render](https://render.com/docs/deploy-fastapi) · [Directorio de servicio](https://render.com/docs/monorepo-support)

### 4. Verificar el despliegue y conectar Flutter

Abre `/docs` en el dominio `.onrender.com` del servicio. Registra un estudiante ficticio, vuelve a desplegar y comprueba desde un teléfono con datos móviles que el registro sigue disponible. En Flutter usa `https://<tu-servicio>.onrender.com/api/v1` como URL base.

Render Free pausa el servicio tras 15 minutos sin tráfico. La primera solicitud después de la pausa puede tardar alrededor de un minuto. Como la API permite consultar y editar sin iniciar sesión, usa datos ficticios en la demostración. [Límites de Render Free](https://render.com/docs/free)

## Consultar la API desde un teléfono en la red local

Conecta el teléfono y la computadora a la misma red Wi-Fi. Inicia el servidor desde la carpeta de la tarea.

```powershell
.\.venv\Scripts\python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Ejecuta `ipconfig` en otra terminal para ver la dirección IPv4 de tu adaptador Wi-Fi. Si la dirección es `192.168.1.25`, abre `http://192.168.1.25:8000/docs` en el navegador del teléfono. Para Flutter, usa `http://192.168.1.25:8000/api/v1` como URL base y sustituye la IP por la de tu equipo.

Si el servidor local ya usa el puerto 8000, cambia el puerto del comando y de las URL por 8001.

Si el navegador no conecta, comprueba que Windows permita el puerto TCP 8000 en el perfil de red privada y que la red permita la comunicación entre dispositivos. SQLite sigue en el equipo que ejecuta FastAPI y ambos clientes consultan los mismos datos. Para el acceso desde otra red se necesita un alojamiento accesible desde internet.

## Ejecutar las pruebas

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\python.exe -m unittest discover -s tests -v
```

Las pruebas usan archivos SQLite temporales. El [diseño del contrato](../../docs/superpowers/specs/2026-11-17-control-academico-api-design.md) describe las reglas y los errores.

Para ejecutar también el contrato contra PostgreSQL, configura `TEST_DATABASE_URL` con un servidor de pruebas que permita crear esquemas. Cada prueba usa y elimina su propio esquema.
