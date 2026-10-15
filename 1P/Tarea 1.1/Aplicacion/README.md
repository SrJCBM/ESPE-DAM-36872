# Ejercicios del NRC 36872

Aplicación sencilla para los ejercicios 1 al 5 de Tarea/Res de Problemas 1.1. Creación y ejecución de una Activity.

## Abrir y ejecutar

Abre la carpeta Aplicacion en Android Studio. En su terminal:

```powershell
flutter pub get
flutter run
```

Selecciona un emulador Android o un teléfono conectado. Para probar en Chrome: `flutter run -d chrome`.

## Estructura

- `lib/main.dart`: aplicación y seis rutas.
- `lib/pantallas/menu_pantalla.dart`: menú principal.
- Cinco archivos `*_pantalla.dart`: una clase y una ruta por ejercicio.
- `lib/pantallas/formulario_ejercicio.dart`: campos, botones y resultado compartidos para no repetir código.
- `lib/logica/ejercicios_logica.dart`: ciclos y cálculos.

No se utilizaron paquetes adicionales para las funciones. Las pantallas se construyeron con los widgets de Flutter, controladores de texto y `setState`.

## Datos de ejemplo

1. Ventas: escribe 500, 1000 y 1001, cada valor en una línea. Resultado: total 2501 y una venta en cada categoría. N se obtiene de la cantidad de líneas.
2. Pagos: pulsa Calcular. Se muestran los 20 pagos y el total 10485750.
3. Tiendas: escribe C=2, T=2, N=2 y las ventas 10, 20, 30, 40, 50, 60, 70 y 80 en líneas separadas. El orden es ciudad, tienda, empleado. Resultado: cadena 360.
4. Sueldos: escribe `Ana;10;15` en una línea. Resultado neto 142.50. Para varios trabajadores utiliza una línea por persona.
5. Inversión: escribe 1963. Resultado: 1983.75. Para el valor actual escribe el año actual.

Los importes permiten punto o coma decimal; no se aceptan negativos ni valores vacíos. En los ejercicios 1 y 4, las líneas vacías intermedias se omiten.

## Criterio del ejercicio 4

El enunciado no define qué sucede exactamente en 300, en 450 ni por encima de 450. Se adoptó 9% para 300 y 0% desde 450. El criterio se muestra en la app y se explica en el informe; debe confirmarse con la docente. Los tramos completos son: hasta 150, 5%; mayor que 150 y menor que 300, 7%; de 300 a menos de 450, 9%; desde 450, 0%.

## Comprobaciones

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

El análisis no encontró observaciones y las 8 pruebas aprobaron. El APK compiló, se instaló en el emulador Pixel 8 Pro y se abrió MainActivity. El cálculo de ventas y el retorno al menú también se verificaron en navegador.

La entrega contiene el código fuente. Se excluyen `build`, `.dart_tool` y las cachés locales. Flutter vuelve a generarlos al ejecutar. El APK de compilación no se incluye para mantener la entrega pequeña.
