# Verificación de la instalación

Fecha: 5 de octubre de 2026.

Resultado: el entorno pudo crear, compilar, instalar y ejecutar una aplicación Flutter para Android. Se comprobó una interacción: el botón incrementó el contador de 0 a 1.

| Componente | Resultado observado |
| --- | --- |
| Flutter | 3.44.5, canal stable |
| Ruta de Flutter | `C:\Users\jcbla\flutter\flutter` |
| Dart | 3.12.2 |
| Git | 2.51.1.windows.1 |
| Android Studio | Instalado en `C:\Program Files\Android\Android Studio`; build AI-261.23567.138.2611.15646644 |
| Complementos del IDE | Carpetas Dart y flutter-intellij presentes en AndroidStudio2026.1.1 |
| SDK de Android | `C:\Users\jcbla\AppData\Local\Android\sdk` |
| Plataforma y Build-Tools detectados por Flutter | 36.1 / 36.1.0 |
| Java utilizado por Flutter | JBR de Android Studio, OpenJDK 21.0.10 |
| Licencias Android | Todas aceptadas según flutter doctor |
| Emulador | Pixel_8_Pro, Android 17 / API 37, x86_64 |
| Aceleración | WHPX instalado y utilizable |
| Compilación de APK debug | Correcta; 243,7 segundos |
| Instalación del APK | adb devolvió Success |
| Inicio de MainActivity | Status: ok; actividad en primer plano |
| Interacción | Contador de 0 a 1, verificado mediante jerarquía de interfaz y captura |

La advertencia de Visual Studio corresponde a los componentes necesarios para compilar aplicaciones de escritorio Windows. La prueba Android pasó con la configuración actual. Flutter anunció una actualización disponible; no se actualizó el SDK durante la revisión.

El diagnóstico por terminal no incluye una categoría independiente de Android Studio en esta versión de Flutter. Se verificaron por separado los archivos del IDE, sus complementos y el JBR utilizado durante la compilación. No se comprobó la ejecución desde los botones del IDE ni un teléfono físico.

## Evidencias conservadas

- `flutter_doctor.txt`: diagnóstico real con el emulador conectado.
- `dispositivos.txt`: dispositivos detectados durante la prueba.
- `aplicacion_prueba.png`: captura real de la aplicación con contador en 1.

La aplicación de prueba se creó en una carpeta temporal:

`C:\Users\jcbla\AppData\Local\Temp\codex_flutter_check_2ad3e9fd0c04449299811d1157a6bde3\verificacion_flutter`

Comandos principales ejecutados:

```powershell
flutter doctor -v
flutter devices
flutter emulators
flutter create --platforms=android --org ec.edu.espe --project-name verificacion_flutter RUTA_TEMPORAL
flutter build apk --debug
adb -s emulator-5580 install -r RUTA_APK
adb -s emulator-5580 shell am start -W -n ec.edu.espe.verificacion_flutter/.MainActivity
```

El emulador se inició sin ventana, en modo de lectura y sin guardar cambios de la sesión. Se cerró al finalizar la comprobación.

Referencia de los criterios de revisión: https://docs.flutter.dev/platform-integration/android/setup
