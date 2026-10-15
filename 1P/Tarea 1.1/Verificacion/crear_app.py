from pathlib import Path
root = Path(__file__).resolve().parents[1] / 'Aplicacion'
files = {
'lib/main.dart': r'''import 'package:flutter/material.dart';
import 'pantallas/menu_pantalla.dart';
import 'pantallas/ventas_pantalla.dart';
import 'pantallas/pagos_pantalla.dart';
import 'pantallas/tiendas_pantalla.dart';
import 'pantallas/sueldos_pantalla.dart';
import 'pantallas/inversion_pantalla.dart';

void main() => runApp(const EjerciciosApp());

class EjerciciosApp extends StatelessWidget {
  const EjerciciosApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Ejercicios NRC 36872',
    theme: ThemeData(colorSchemeSeed: Colors.teal),
    initialRoute: '/',
    routes: {
      '/': (_) => const MenuPantalla(),
      '/ventas': (_) => const VentasPantalla(),
      '/pagos': (_) => const PagosPantalla(),
      '/tiendas': (_) => const TiendasPantalla(),
      '/sueldos': (_) => const SueldosPantalla(),
      '/inversion': (_) => const InversionPantalla(),
    },
  );
}
''',
'lib/pantallas/menu_pantalla.dart': r'''import 'package:flutter/material.dart';

class MenuPantalla extends StatelessWidget {
  const MenuPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    const opciones = {
      '/ventas': '1. Ventas de Tiki Taka',
      '/pagos': '2. Pagos durante 20 meses',
      '/tiendas': '3. Ventas de El mandilón',
      '/sueldos': '4. Sueldos semanales',
      '/inversion': '5. Inversión desde 1961',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Menú de ejercicios')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('NRC 36872', style: TextStyle(fontSize: 22)),
          const Text('Selecciona un ejercicio.'),
          const SizedBox(height: 20),
          for (final opcion in opciones.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, opcion.key),
                child: Text(opcion.value),
              ),
            ),
        ],
      ),
    );
  }
}
''',
'lib/pantallas/formulario_ejercicio.dart': r'''import 'package:flutter/material.dart';

// Comparte únicamente los campos y botones; cada ejercicio tiene su ruta.
class FormularioEjercicio extends StatefulWidget {
  final String titulo, instrucciones;
  final List<String> etiquetas;
  final String Function(List<String>) calcular;
  final bool multilinea;

  const FormularioEjercicio({
    super.key,
    required this.titulo,
    required this.instrucciones,
    required this.etiquetas,
    required this.calcular,
    this.multilinea = true,
  });

  @override
  State<FormularioEjercicio> createState() => _FormularioEjercicioState();
}

class _FormularioEjercicioState extends State<FormularioEjercicio> {
  late final controles = [
    for (final _ in widget.etiquetas) TextEditingController(),
  ];
  String resultado = '';

  void calcular() {
    FocusScope.of(context).unfocus();
    try {
      final respuesta = widget.calcular([for (final c in controles) c.text]);
      setState(() => resultado = respuesta);
    } on FormatException catch (error) {
      setState(() => resultado = error.message);
    }
  }

  @override
  void dispose() {
    for (final control in controles) {
      control.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.titulo)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.instrucciones),
          const SizedBox(height: 16),
          for (int i = 0; i < controles.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                controller: controles[i],
                minLines: widget.multilinea && i == controles.length - 1 ? 3 : 1,
                maxLines: widget.multilinea && i == controles.length - 1 ? 6 : 1,
                decoration: InputDecoration(
                  labelText: widget.etiquetas[i],
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => resultado = ''),
              ),
            ),
          ElevatedButton(onPressed: calcular, child: const Text('Calcular')),
          TextButton(
            onPressed: () {
              for (final control in controles) {
                control.clear();
              }
              setState(() => resultado = '');
            },
            child: const Text('Limpiar'),
          ),
          const SizedBox(height: 10),
          Text(resultado, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver al menú'),
          ),
        ],
      ),
    ),
  );
}
''',
'lib/logica/ejercicios_logica.dart': r'''class EjerciciosLogica {
  double numero(String texto) {
    final valor = double.tryParse(texto.trim().replaceAll(',', '.'));
    if (valor == null || !valor.isFinite || valor < 0) {
      throw const FormatException('Ingresa números válidos, no negativos.');
    }
    return valor;
  }

  List<String> filas(String texto) {
    final lista = texto.trim().split('\n').where((f) => f.trim().isNotEmpty).toList();
    if (lista.isEmpty) throw const FormatException('Ingresa al menos un registro.');
    return lista;
  }

  String dinero(double valor) {
    if (!valor.isFinite) throw const FormatException('El resultado es demasiado grande.');
    return '\$${valor.toStringAsFixed(2)}';
  }

  String ventas(String texto) {
    final cantidades = [0, 0, 0];
    final montos = [0.0, 0.0, 0.0];
    for (final fila in filas(texto)) {
      final venta = numero(fila);
      final grupo = venta > 1000 ? 0 : (venta > 500 ? 1 : 2);
      cantidades[grupo]++;
      montos[grupo] += venta;
    }
    const grupos = ['Mayores a 1000', 'Mayores a 500 y hasta 1000', 'Hasta 500'];
    return [
      for (int i = 0; i < 3; i++)
        '${grupos[i]}: ${cantidades[i]} ventas; ${dinero(montos[i])}',
      'Número de ventas: ${cantidades.reduce((a, b) => a + b)}',
      'Total vendido: ${dinero(montos.reduce((a, b) => a + b))}',
    ].join('\n');
  }

  String pagos() {
    double pago = 10, total = 0;
    final detalle = <String>[];
    for (int mes = 1; mes <= 20; mes++) {
      detalle.add('Mes $mes: ${dinero(pago)}');
      total += pago;
      pago *= 2;
    }
    return [...detalle, 'Total pagado: ${dinero(total)}'].join('\n');
  }

  String tiendas(List<String> datos) {
    final dimensiones = datos.take(3).map((d) => int.tryParse(d.trim())).toList();
    if (dimensiones.any((n) => n == null || n <= 0)) {
      throw const FormatException('Ciudades, tiendas y empleados deben ser enteros positivos.');
    }
    final c = dimensiones[0]!, t = dimensiones[1]!, n = dimensiones[2]!;
    final ventas = filas(datos[3]).map(numero).toList();
    if (ventas.length != c * t * n) {
      throw FormatException('Se requieren ${c * t * n} ventas, una por empleado.');
    }
    int posicion = 0;
    double totalCadena = 0;
    final detalle = <String>[];
    for (int ciudad = 1; ciudad <= c; ciudad++) {
      double totalCiudad = 0;
      for (int tienda = 1; tienda <= t; tienda++) {
        double totalTienda = 0;
        for (int empleado = 1; empleado <= n; empleado++) {
          final venta = ventas[posicion++];
          detalle.add('Ciudad $ciudad · Tienda $tienda · Empleado $empleado: ${dinero(venta)}');
          totalTienda += venta;
        }
        detalle.add('Total tienda $tienda de ciudad $ciudad: ${dinero(totalTienda)}');
        totalCiudad += totalTienda;
      }
      detalle.add('Total ciudad $ciudad: ${dinero(totalCiudad)}');
      totalCadena += totalCiudad;
    }
    return [...detalle, 'Total cadena: ${dinero(totalCadena)}'].join('\n');
  }

  String sueldos(String texto) {
    final detalle = <String>[];
    for (final fila in filas(texto)) {
      final datos = fila.split(';');
      if (datos.length != 3 || datos[0].trim().isEmpty) {
        throw const FormatException('Formato por línea: nombre; horas; sueldo por hora.');
      }
      final bruto = numero(datos[1]) * numero(datos[2]);
      // Criterio del ejercicio: 300 inicia el tramo del 9%; desde 450, 0%.
      final tasa = bruto <= 150 ? 0.05 : (bruto < 300 ? 0.07 : (bruto < 450 ? 0.09 : 0.0));
      final descuento = bruto * tasa;
      detalle.add('${datos[0].trim()}: bruto ${dinero(bruto)}, descuento ${(tasa * 100).toInt()}% (${dinero(descuento)}), neto ${dinero(bruto - descuento)}');
    }
    return ['Trabajadores: ${detalle.length}', ...detalle].join('\n');
  }

  String inversion(String texto) {
    final anio = int.tryParse(texto.trim());
    if (anio == null || anio < 1961 || anio > DateTime.now().year) {
      throw FormatException('Ingresa un año entre 1961 y ${DateTime.now().year}.');
    }
    double capital = 1500;
    for (int actual = 1961; actual < anio; actual++) {
      capital *= 1.15;
    }
    return 'Años transcurridos: ${anio - 1961}\nInversión acumulada: ${dinero(capital)}';
  }
}
''',
'pubspec.yaml': '''name: ejercicios_36872
description: Cinco ejercicios sencillos con menú y rutas de Flutter.
publish_to: 'none'
version: 1.0.0+1
environment:
  sdk: ^3.12.2
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
flutter:
  uses-material-design: true
''',
}
screens = [
('ventas', 'Ventas', '1. Ventas de Tiki Taka', 'Ingresa una venta por línea. N es la cantidad de ventas ingresadas.', ['Ventas del día'], 'ventas(datos[0])', True),
('pagos', 'Pagos', '2. Pagos mensuales', 'El primer pago es $10 y se duplica cada mes durante 20 meses.', [], 'pagos()', False),
('tiendas', 'Tiendas', '3. Ventas de El mandilón', 'Ingresa C ciudades, T tiendas por ciudad y N empleados por tienda. Luego una venta por línea, en orden: ciudad, tienda y empleado.', ['Ciudades (C)', 'Tiendas por ciudad (T)', 'Empleados por tienda (N)', 'Ventas por empleado'], 'tiendas(datos)', True),
('sueldos', 'Sueldos', '4. Sueldos semanales', 'Un trabajador por línea: nombre; horas; sueldo por hora. Ejemplo: Ana; 10; 15. Descuentos: hasta 150, 5%; más de 150 y menos de 300, 7%; de 300 a menos de 450, 9%. Desde 450: 0% (no definido en el enunciado).', ['Trabajadores'], 'sueldos(datos[0])', True),
('inversion', 'Inversion', '5. Inversión desde 1961', 'Capital inicial: $1500. Interés compuesto: 15% anual. Ingresa el año final (hasta el año actual).', ['Año final'], 'inversion(datos[0])', False),
]
for filename, cls, title, instructions, labels, method, multiline in screens:
    files[f'lib/pantallas/{filename}_pantalla.dart'] = f'''import 'package:flutter/material.dart';
import '../logica/ejercicios_logica.dart';
import 'formulario_ejercicio.dart';

class {cls}Pantalla extends StatelessWidget {{
  const {cls}Pantalla({{super.key}});

  @override
  Widget build(BuildContext context) => FormularioEjercicio(
    titulo: '{title}',
    instrucciones: r'{instructions}',
    etiquetas: {labels!r},
    multilinea: {str(multiline).lower()},
    calcular: (datos) => EjerciciosLogica().{method},
  );
}}
'''
for name, content in files.items():
    path = root / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding='utf-8')
manifest = root / 'android/app/src/main/AndroidManifest.xml'
manifest.write_text(manifest.read_text().replace('android:label="ejercicios_36872"', 'android:label="Ejercicios 36872"'))
index = root / 'web/index.html'
index.write_text(index.read_text().replace('<html>', '<html lang="es">').replace('A new Flutter project.', 'Ejercicios del NRC 36872.').replace('<title>ejercicios_36872</title>', '<title>Ejercicios 36872</title>'))

