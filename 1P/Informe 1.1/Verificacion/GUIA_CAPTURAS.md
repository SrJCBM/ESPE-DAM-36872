# Capturas aportadas por Julio Blacio

Fecha de comprobación: 5 de octubre de 2026.

## Actualización: capturas directas de terminal

La carpeta `../Fotos_Overleaf` ahora contiene ocho capturas directas de Windows Terminal, obtenidas después de ejecutar las consultas en vivo: figuras 01, 02, 03, 04, 07, 09, 10 y 11. Las figuras 08 y 13 conservan sus capturas directas de Android Studio y de la aplicación Android. Los archivos JPG de esta carpeta y el ZIP `Capturas_Julio_Blacio.zip` corresponden a la primera recopilación descrita abajo.

Para Overleaf se debe utilizar `Fotos_Overleaf` o el nuevo ZIP `Fotos_Overleaf.zip`. Ambos conservan los nombres PNG del documento. La figura 10 muestra el resumen de `flutter doctor`; el diagnóstico detallado permanece en `flutter_doctor.txt`. La figura 02 muestra los directorios existentes del SDK, como verificación posterior a la instalación.

Los scripts `capturar_terminal.ps1`, `guardar_ventana_terminal.ps1` y `generar_capturas_terminal.ps1` ejecutan las consultas, esperan su finalización y guardan píxeles de la ventana visible de Windows Terminal. No recrean su aspecto mediante HTML. El inventario del SDK presenta las columnas de paquete y versión para que la salida quepa en pantalla.

## Primera recopilación

Se reunieron 13 imágenes sobre el estado actual de la instalación. `plugins_flutter.png` es una captura directa del diálogo de Android Studio; `aplicacion_prueba.png` procede directamente del emulador mediante adb. Las otras 11 imágenes JPG son capturas de páginas locales que muestran consultas reales, con el archivo y comando de origen identificados. No son capturas de una terminal ni de los asistentes originales de instalación.

Los archivos TXT conservan las salidas recogidas. Los HTML permiten revisar esas mismas salidas antes de utilizarlas en el informe. `sdk_android.jpg` presenta las columnas de paquete, versión y descripción de la salida de sdkmanager en una tabla.

| Archivo | Qué acredita | Apartado del informe |
| --- | --- | --- |
| equipo.jpg | Sistema, arquitectura, procesador, RAM, espacio disponible y Git | Revisión del equipo (figura 1) |
| sdk_flutter.jpg | Carpeta existente del SDK y subcarpeta bin | Ubicación del SDK (figura 2); acredita la ubicación actual |
| path.jpg | Entrada de Flutter en Path del usuario y resolución del comando | Configuración de Path (figura 3) |
| versiones.jpg | Versiones de Flutter, Dart y Git y ubicación del ejecutable | Comprobación de versiones (figura 4) |
| studio.jpg | Información del Android Studio instalado | Evidencia complementaria del IDE instalado |
| sdk_android.jpg | Plataformas, Build-Tools, Command-line Tools, NDK, CMake y emulador instalados | Configuración del SDK de Android (figura 7) |
| plugins_flutter.png | Flutter instalado, marcado en el diálogo Plugins, versión 94.0.0 | Complementos (figura 8) |
| plugins.jpg | Metadatos de los complementos Flutter 94.0.0 y Dart 507.0.0 instalados | Complementos (figura 8), como evidencia adicional |
| licencias.jpg | Salida All SDK package licenses accepted | Licencias (figura 9) |
| doctor.jpg | Diagnóstico completo guardado, incluida la advertencia Windows | Diagnóstico del entorno (figura 10) |
| dispositivos.jpg | AVD Pixel_8_Pro, aceleración WHPX y Android detectado | Dispositivo de prueba (figura 11) |
| compilacion.jpg | APK debug compilado, instalación Success, inicio Status: ok y contador en 1 | Ejecución del proyecto (figura 13) |
| aplicacion_prueba.png | Interfaz real de la aplicación Android con contador en 1 | Ejecución del proyecto (figura 13), junto a la compilación |

## Etapas pendientes de capturas de los compañeros

- Descarga original del paquete Flutter y extracción en el equipo utilizado para esa etapa.
- Asistente del instalador de Android Studio (figura 5).
- Setup Wizard y descarga inicial de componentes (figura 6).
- Creación o apertura del proyecto Flutter en Android Studio (figura 12).

La carpeta actual del SDK y los metadatos del IDE son comprobaciones posteriores a la instalación. Los pies de figura deberán reflejarlo si estas capturas sustituyen un espacio reservado para un asistente.

## Selección recomendada

Como aporte principal se recomienda utilizar versiones, Path, SDK Android, complementos, licencias, diagnóstico, dispositivo, compilación y pantalla de la aplicación. Los recursos del equipo y la carpeta del SDK completan la descripción del entorno.

La imagen `doctor.jpg` es larga. Para mantenerla legible en el informe, conviene reservarle una página o dividir la exposición en diagnóstico Android y advertencia Windows, sin ocultar esta última.

El diagnóstico advierte sobre Visual Studio para desarrollo de escritorio Windows. La compilación y la ejecución Android concluyeron correctamente. No se reinstaló ni se actualizó Flutter para obtener estas evidencias.

## Archivos y reproducción

Los scripts `generar_evidencias.mjs` y `servidor_evidencias.mjs` presentan los registros conservados en páginas locales. No reemplazan las consultas originales. Las capturas se guardaron automáticamente desde el navegador.

Para revisar las páginas:

```powershell
node generar_evidencias.mjs
node servidor_evidencias.mjs
```

Después se puede abrir http://127.0.0.1:8766. También se puede abrir cada HTML directamente como archivo local.

El documento `main.tex` conserva las modificaciones del grupo. Las imágenes se entregan en esta carpeta para que se integren con los pies de figura correspondientes.
