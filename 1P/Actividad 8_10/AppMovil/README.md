# App móvil: Calculadoras

Réplica mejorada de `../Referencia`, creada con Flutter para la actividad del 8 de octubre. La referencia original se conservó.

## Funciones

- Terreno rectangular: área en m², perímetro en m y valor a $500 por m², igual que en el ejemplo.
- Calculadora básica: suma, resta, multiplicación y división.
- Navegación inferior para acceder a ambos ejercicios.
- Validación de campos vacíos, números inválidos, medidas no positivas y división entre cero.
- Decimales con punto o coma, botón Limpiar y desplazamiento cuando aparece el teclado.

## Ejecutar

Abrir esta carpeta en Android Studio o VS Code. En su terminal:

```powershell
flutter pub get
flutter run
```

Seleccionar un teléfono Android conectado o un emulador. Para comprobar la interfaz en Chrome:

```powershell
flutter run -d chrome
```

Para generar un APK de prueba:

```powershell
flutter build apk --debug
```

El archivo se genera en `build/app/outputs/flutter-apk/app-debug.apk`.

## Código

Solo tres archivos propios en `lib/`, sin paquetes adicionales para las funciones:

- `main.dart`: inicio y tema de la aplicación.
- `pantallas/panel_herramientas.dart`: formulario compartido y navegación.
- `logica/servicio_calculos.dart`: operaciones y fórmulas del terreno.

La interfaz reutiliza los dos campos para evitar duplicar las pantallas. Al cambiar de calculadora se limpian los datos. Al editar una entrada se oculta el resultado anterior. Se muestran dos decimales; los cálculos usan los valores completos.

## Comprobar

```powershell
flutter analyze
flutter test
```

Las pruebas cubren operaciones, fórmulas del terreno, coma decimal, validación, limpieza, navegación, división entre cero y una pantalla de 320 × 568 con teclado visible.

## Verificación realizada

- `flutter analyze`: sin observaciones.
- `flutter test`: 4 pruebas aprobadas.
- `flutter build apk --debug`: compilación comprobada; los archivos generados se eliminaron para entregar el proyecto limpio.
- Interfaz revisada en navegador con vista de 390 × 844: terreno de 10,5 × 2 = 21 m², perímetro de 25 m y valor de $10500; división de 8 entre 2 = 4.
- Capturas guardadas en `capturas/`.
- Código propio de la app: 252 líneas en 3 archivos, frente a 268 líneas en 4 archivos de la referencia (incluye espacios y formato).

La entrega contiene el código fuente. Para instalar la app, genera el APK con el comando indicado. No se ejecutó en un teléfono o emulador Android durante esta verificación.



## Nombres del código

- `HerramientasApp`: aplicación principal.
- `PanelHerramientas` y `_PanelHerramientasState`: interfaz y estado.
- `ServicioCalculos`: lógica matemática.
- Métodos principales: `resolverOperacion`, `evaluarTerreno`, `procesarDatos` y `reiniciarCampos`.
- Controladores: `primerDatoCtrl` y `segundoDatoCtrl`.

Tras cambiar los nombres se repitieron el análisis, las 4 pruebas y la compilación del APK; todos finalizaron correctamente.

La carpeta build y la caché de Flutter se eliminaron de la entrega. Flutter vuelve a generarlas al ejecutar o compilar el proyecto.

