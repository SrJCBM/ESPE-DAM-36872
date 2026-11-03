# Recargas ESPE

Aplicación educativa del informe 1.2 de Desarrollo de Aplicaciones Móviles. Tres pantallas: acceso, nueva recarga y comprobante. No realiza recargas ni pagos reales. Sesión y comprobante permanecen solo en memoria.

## Ejecutar

Verificado con Flutter 3.47.7 y Dart 3.13.5 en Android 17 API 37 (AVD Pixel_8_Pro). Requiere Flutter y, para Android, SDK Android y emulador o teléfono conectado.

```powershell
flutter pub get
flutter devices
flutter run
```

Credenciales locales de práctica: usuario `admin`, contraseña `Admin123*`.

En Android Studio abrir esta carpeta completa, no solamente `android`.

## Demostración

1. Iniciar sesión.
2. Ingresar `0991234567`, seleccionar Claro, valor `10` y Efectivo.
3. Revisar valor $10,00, comisión $0,30 y total $10,30.
4. Confirmar simulación abre el comprobante.
5. Nueva recarga abre un formulario limpio. Cerrar sesión elimina usuario y comprobante.

El teléfono solo es un dato de prueba: no se envían comunicaciones. Las credenciales incluidas no son autenticación para producción.

## Reglas

- Teléfono de diez dígitos con prefijo 09.
- Valor de USD 1,00 a USD 100,00, inclusive. Hasta dos decimales; acepta coma o punto.
- Comisiones ficticias: Claro 3 %, Movistar 2,5 %, CNT 2 %.
- Pago: Efectivo o Transferencia, sin pedir información bancaria.
- Dinero en centavos enteros y tasa en puntos base. Redondeo al centavo más próximo, mitad hacia arriba.
- Ejemplo: $1,00 con Movistar genera comisión $0,03 y total $1,03.
- Sin servidor, API externa, historial persistente ni base de datos.

## Arquitectura MVC y Atomic Design

Se tomó como referencia la actividad `20_10/pr04`, que combina MVC y Atomic Design. Las actividades de 27/10 y 29/10 usan MVVM/Provider; el Word de este informe pide MVC.

```text
lib/
  main.dart                    # Punto de entrada, rutas y composición
  modelo/recarga.dart           # Operadora, FormaPago, Dinero, Cotizacion, Comprobante
  controlador/
    sesion_controlador.dart    # Acceso local
    recarga_controlador.dart   # Validaciones y operaciones
  tema/tema_aplicacion.dart    # Colores, Roboto, campos y botones
  vista/
    atomos/                    # CampoTexto, BotonPrincipal, EtiquetaEstado
    moleculas/                 # EntradaCampo, ResumenMontos
    organismos/                # Formularios, detalle y disposición común
    pantallas/                 # Acceso, nueva recarga y comprobante
test/
  controllers_test.dart        # 30 pruebas de lógica
  widget_test.dart             # 7 pruebas de interacción
```

Los controladores no importan widgets. EntradaCampo compone el átomo CampoTexto. Las rutas `/`, `/recarga` y `/comprobante` comprueban sesión y disponibilidad del resultado.

## Verificación

```powershell
flutter analyze
flutter test --reporter expanded
flutter build apk --debug
```

Recorrido de integración Android y capturas PNG (requiere un emulador conectado):

```powershell
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/recorrido_test.dart -d emulator-5554
```

La prueba de integración recorre las tres pantallas, comprueba errores de acceso, el total de Claro y el cierre de sesión. Guarda las seis capturas reales en la carpeta `Evidencias` junto al proyecto; no utiliza servicios de operadoras.

Resultado registrado: análisis sin incidencias, 37 pruebas aprobadas y APK de depuración compilado. Se prueba una vista de 320×640 con texto al 150 %. No equivale a compatibilidad universal ni auditoría completa de accesibilidad o seguridad.

APK generado: `build/app/outputs/flutter-apk/app-debug.apk`. La entrega del código excluye cachés, archivos de SDK locales y directorios de compilación; `flutter pub get` y la primera compilación los regeneran y requieren conexión a los repositorios de dependencias.
