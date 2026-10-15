import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ejercicios_36872/main.dart';
import 'package:ejercicios_36872/logica/ejercicios_logica.dart';

void main() {
  final logica = EjerciciosLogica();
  test('Ventas: límites 500 y 1000 y suma global', () {
    final salida = logica.ventas('500\n1000\n1001\n0');
    expect(salida, contains('Mayores a 1000: 1 ventas; \$1001.00'));
    expect(salida, contains('Mayores a 500 y hasta 1000: 1 ventas; \$1000.00'));
    expect(salida, contains('Hasta 500: 2 ventas; \$500.00'));
    expect(salida, contains('Total vendido: \$2501.00'));
    expect(logica.ventas('10,5\n20'), contains('\$30.50'));
  });
  test('Pagos: mes 20 y total de la progresión', () {
    final salida = logica.pagos();
    expect(salida, contains('Mes 20: \$5242880.00'));
    expect(salida, contains('Total pagado: \$10485750.00'));
    expect(salida.split('\n').length, 21);
  });
  test('Tiendas: suma por empleado, tienda, ciudad y cadena', () {
    final salida = logica.tiendas([
      '2',
      '2',
      '2',
      '10\n20\n30\n40\n50\n60\n70\n80',
    ]);
    expect(salida, contains('Total tienda 1 de ciudad 1: \$30.00'));
    expect(salida, contains('Total tienda 2 de ciudad 1: \$70.00'));
    expect(salida, contains('Total ciudad 1: \$100.00'));
    expect(salida, contains('Total ciudad 2: \$260.00'));
    expect(salida, contains('Total cadena: \$360.00'));
    expect(() => logica.tiendas(['2', '2', '2', '10']), throwsFormatException);
  });
  test('Sueldos: descuentos y criterio para límites omitidos', () {
    final salida = logica.sueldos(
      'Ana;10;15\nLuis;10;20\nEva;10;30\nPaz;10;45',
    );
    expect(salida, contains('neto \$142.50'));
    expect(salida, contains('neto \$186.00'));
    expect(salida, contains('neto \$273.00'));
    expect(salida, contains('neto \$450.00'));
    expect(() => logica.sueldos('Ana;10'), throwsFormatException);
  });
  test('Inversión: capital inicial y dos años de interés compuesto', () {
    expect(logica.inversion('1961'), contains('\$1500.00'));
    expect(logica.inversion('1963'), contains('\$1983.75'));
    expect(() => logica.inversion('1960'), throwsFormatException);
    expect(
      () => logica.inversion('${DateTime.now().year + 1}'),
      throwsFormatException,
    );
  });
  test('Entradas inválidas no se convierten en cero', () {
    for (final entrada in ['', 'abc', '-1', 'NaN', 'Infinity']) {
      expect(() => logica.ventas(entrada), throwsFormatException);
    }
  });
  testWidgets('Menú abre las cinco pantallas y permite regresar', (
    tester,
  ) async {
    await tester.pumpWidget(const EjerciciosApp());
    const nombres = [
      '1. Ventas de Tiki Taka',
      '2. Pagos durante 20 meses',
      '3. Ventas de El mandilón',
      '4. Sueldos semanales',
      '5. Inversión desde 1961',
    ];
    for (final nombre in nombres) {
      await tester.tap(find.text(nombre));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Volver al menú'));
      await tester.tap(find.text('Volver al menú'));
      await tester.pumpAndSettle();
      expect(find.text('Menú de ejercicios'), findsOneWidget);
    }
  });
  testWidgets('Pantalla de ventas calcula y muestra errores', (tester) async {
    await tester.pumpWidget(const EjerciciosApp());
    await tester.tap(find.text('1. Ventas de Tiki Taka'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '500\n1000\n1001');
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Total vendido: \$2501.00'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa números válidos, no negativos.'), findsOneWidget);
  });
}
