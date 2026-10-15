import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pry004_numeros_atomic/main.dart';
import 'package:pry004_numeros_atomic/modelo/uva_modelo.dart';
import 'package:pry004_numeros_atomic/controlador/uva_controlador.dart';

void main() {
  test('Aplica los cuatro ajustes al precio por kilo', () {
    final uva = UvaModelo();
    expect(uva.calcularPrecio(2, 'A', 1), closeTo(2.20, 0.001));
    expect(uva.calcularPrecio(2, 'A', 2), closeTo(2.30, 0.001));
    expect(uva.calcularPrecio(2, 'B', 1), closeTo(1.70, 0.001));
    expect(uva.calcularPrecio(2, 'B', 2), closeTo(1.50, 0.001));
    expect(uva.calcularTotal(2, 100, 'A', 1), closeTo(220, 0.001));
  });

  test('Valida datos y acepta letras minusculas', () {
    final controlador = UvaControlador();
    for (final precio in ['', 'abc', '-1', '0', 'NaN', 'Infinity']) {
      expect(
        controlador.calcular(precio, '100', 'A', '1'),
        contains('Ingrese'),
      );
    }
    expect(controlador.calcular('2', '0', 'A', '1'), contains('Ingrese'));
    expect(controlador.calcular('2', '100', 'C', '1'), contains('A o B'));
    expect(controlador.calcular('2', '100', 'A', '3'), contains('1 o 2'));
    expect(controlador.calcular('0.20', '100', 'B', '2'), contains('negativo'));
    expect(controlador.calcular('2', '100', ' a ', '1'), contains('\$220.00'));
  });

  testWidgets('Calcula la venta y limpia los campos', (tester) async {
    await tester.pumpWidget(const MyApp());
    final campos = find.byType(TextField);
    for (var i = 0; i < 4; i++) {
      await tester.enterText(campos.at(i), ['2', '100', 'B', '2'][i]);
    }
    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.textContaining('Total a recibir: \$150.00'), findsOneWidget);
    await tester.tap(find.text('Limpiar'));
    await tester.pump();
    expect(find.textContaining('Total a recibir:'), findsNothing);
    for (var i = 0; i < 4; i++) {
      expect(tester.widget<TextField>(campos.at(i)).controller!.text, isEmpty);
    }
  });
}
