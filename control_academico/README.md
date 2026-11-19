# Control académico

Aplicación Flutter para el caso 3 del documento de casos prácticos. Permite registrar, editar y eliminar estudiantes y asignaturas, además de gestionar una nota final de 0 a 20 por estudiante y asignatura. La ficha del estudiante muestra su promedio y el estado de cada nota.

El equipo del informe puede consultar la [guía y el guion de demostración](../docs/GUIA_INFORME.md), la [arquitectura de Flutter](../docs/APP_FLUTTER.md) y el [contrato de la API REST](../docs/API_REST.md).

## Ejecutar en Android

Desde esta carpeta, con un dispositivo o emulador Android conectado, ejecuta:

```powershell
flutter pub get
flutter run
```

La aplicación usa la [API REST de Render](https://control-academico-api.onrender.com/docs). La API guarda los datos en Neon. Para usar otro entorno, especifica la base HTTPS con `--dart-define=API_BASE_URL=https://servidor.example/api/v1`. Tras un período sin tráfico, el plan gratuito de Render puede tardar en reactivar el servicio. Si la app muestra un error de carga, usa **Reintentar**.

## Arquitectura

- `lib/main.dart` registra el cliente HTTP, los casos de uso y tres `ChangeNotifierProvider` dentro de `MultiProvider`. Cada catálogo tiene su propio ViewModel.
- `lib/domain` contiene las entidades, los contratos de repositorio y los casos de uso. No depende de Flutter ni de HTTP.
- `lib/data` implementa los repositorios REST, convierte las respuestas JSON y procesa errores y paginación.
- `lib/presentation` contiene los ViewModels y las vistas de estudiantes, asignaturas, notas y resumen académico.
- `lib/routes` define las rutas de los formularios y la ficha. La ficha consulta `/estudiantes/{id}/resumen-academico`.

La nota puede escribirse con coma o punto decimal y admite hasta dos decimales. Los límites son 14 para aprobar, 9 para poder rendir recuperación y menos de 9 para reprobar. El backend valida que la pareja estudiante y asignatura sea única y bloquea el borrado de un estudiante con notas. El promedio se calcula en la API y se actualiza al registrar, editar o eliminar una calificación.

## Comprobar

```powershell
flutter analyze
flutter test
flutter build apk --release
```
