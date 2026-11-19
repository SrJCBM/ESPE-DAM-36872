# Guía para el informe de Control académico

El proyecto resuelve el **caso 3** del documento de casos prácticos. El objetivo es registrar estudiantes y asignaturas, gestionar sus calificaciones finales y consultar el promedio de cada estudiante desde Flutter. La tarea exige Provider, con la indicación de usar **MultiProvider**, MVVM, Clean Architecture, rutas y consumo de una API REST.

- [Documentación de la API REST](API_REST.md) con el modelo de datos, las 19 operaciones y cuerpos JSON.
- [Documentación de la app Flutter](APP_FLUTTER.md) con las pantallas, rutas y organización del código.

## Estructura sugerida

| Parte del informe | Contenido que pueden explicar |
|---|---|
| Introducción y objetivo | Qué problema resuelve Control académico y qué tres entidades maneja. |
| Arquitectura | Qué hace cada capa de Flutter y dónde se configura `MultiProvider`. Incluyan el recorrido entre Flutter, FastAPI en Render y PostgreSQL en Neon. |
| Diseño de datos y API | Relación de estudiante y asignatura con nota, unicidad de la pareja, rutas anidadas, códigos HTTP y cálculo del promedio. |
| Implementación | Flujo para registrar una nota y volver a consultar el resumen. Una captura del formulario y otra de la ficha bastan para ilustrarlo. |
| Pruebas y resultados | Pasos, valores ingresados, resultado esperado, resultado observado y evidencia. Distingan las pruebas automatizadas de la demostración manual. |
| Conclusiones | Qué reglas se cumplieron, qué se verificó y alcance de la demo. El promedio representa solo las notas registradas. |

## Guion de demostración

1. Abre la app y registra a **Ana Torres**, con el código `EST-DEMO-01` y el correo `ana@example.com`.
2. Crea **Matemática** y **Física** con códigos distintos. Abre la ficha de Ana y registra **15,50** en Matemática y **12,00** en Física.
3. Comprueba que la ficha muestra **Aprobado**, **Recuperación** y un promedio de **13,75**. Guarda una captura.
4. Edita la nota de Física a **8,99**. Comprueba que ahora dice **Reprobado** y que el promedio se redondea a **12,25**.
5. Intenta registrar **20,01**. Flutter debe mostrar el mensaje de validación sin guardar la nota.
6. En [Swagger](https://control-academico-api.onrender.com/docs), intenta duplicar la nota de Matemática o borrar a Ana mientras tiene calificaciones. Confirma el `409` con `NOTA_DUPLICADA` o `ESTUDIANTE_CON_NOTAS`. Usa el ID real de la ficha o el que devuelva la API.
7. Vuelve a consultar el resumen. Si necesitan limpiar el entorno al terminar, eliminen primero las notas y después las asignaturas y el estudiante de la demostración.

Si el código de ejemplo ya existe, usa un sufijo diferente. Registra únicamente datos ficticios. Las notas válidas alrededor de los límites se pueden comprobar en consultas separadas o editando la misma calificación.

## Evidencias que pueden adjuntar

| Evidencia | Cómo obtenerla | Qué demuestra |
|---|---|---|
| Captura de la ficha | Ejecutar los pasos 1 a 4 en Android. | Asociación por asignatura, estados y promedio actualizado. |
| Captura de Swagger | Ejecutar `GET /api/v1/estudiantes/{id}/resumen-academico` y el caso `409`. | Contrato REST y validación en el servidor. |
| Consulta en Neon | Seleccionar la rama `production` y la base `neondb`. Ejecutar la consulta de abajo. | Que un registro guardado en la app llegó a PostgreSQL. |
| Salidas de pruebas | Desde la app, ejecutar `flutter analyze` y `flutter test`. Desde el backend, usar los pasos de su [README](../README.md#ejecutar-las-pruebas). | Resultados observados de los casos automatizados. |

En el SQL Editor de Neon puedes mostrar las calificaciones de la estudiante de prueba.

```sql
SELECT e.codigo, a.nombre AS asignatura, n.valor_centesimas / 100.0 AS nota
FROM public.notas AS n
JOIN public.estudiantes AS e ON e.id = n.estudiante_id
JOIN public.asignaturas AS a ON a.id = n.asignatura_id
WHERE e.codigo = 'EST-DEMO-01'
ORDER BY a.nombre;
```

La consulta es de lectura. Si cambiaste el código de la estudiante, modifica también el filtro. Toma la captura antes de eliminar los datos de prueba. Los resultados indicados en este guion son los esperados. Registra lo que realmente observaste y evita capturar credenciales o información personal.

## Cómo demostrar cada regla

| Regla del DOCX | Evidencia propuesta |
|---|---|
| Nota entre 0 y 20. | Rechazar `20,01` y comprobar los límites `0` y `20` en pruebas. |
| Varias notas por estudiante con asignaturas existentes. | Mostrar dos notas para Ana en materias diferentes. Un ID inexistente en Swagger debe devolver `404`. |
| Estados de aprobación, recuperación y reprobación. | Comparar las notas `15,50`, `12,00` y `8,99`. |
| Promedio por estudiante. | Comparar la ficha antes y después de editar una nota. |
| Restricción al borrar estudiantes con notas. | Mostrar la respuesta `409` o su mensaje en Flutter. Después de quitar las notas, el borrado debe funcionar. |
