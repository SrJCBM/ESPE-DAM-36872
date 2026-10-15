import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pry003_costo_viaje/main.dart';
import 'package:pry003_costo_viaje/logica/viaje_estudiantil_logica.dart';

void main() {
  test('Tarifas y totales en los limites de cada rango', () {
    final viaje = Viaje();
    final casos = [
      [1, 4000, 4000],
      [29, 4000 / 29, 4000],
      [30, 95, 2850],
      [49, 95, 4655],
      [50, 70, 3500],
      [99, 70, 6930],
      [100, 65, 6500],
      [101, 65, 6565],
    ];
    for (final caso in casos) {
      expect(viaje.calcularCostoAlumno(caso[0].toInt()), caso[1]);
      expect(viaje.calcularPagoTotal(caso[0].toInt()), caso[2]);
    }
  });

  testWidgets('Valida, calcula y limpia', (tester) async {
    await tester.pumpWidget(const MyApp());
    final campo = find.byType(TextField);
    final calcular = find.text('Calcular Costo Total');
    for (final entrada in ['', '0', '-1', 'abc', '2.5']) {
      await tester.enterText(campo, entrada);
      await tester.tap(calcular);
      await tester.pump();
      expect(
        find.text('Por favor, ingrese un número válido de alumnos.'),
        findsOneWidget,
      );
    }
    await tester.enterText(campo, '100');
    await tester.tap(calcular);
    await tester.pump();
    expect(find.text('Costo por Alumno: \$65.00'), findsOneWidget);
    expect(find.text('Costo Total: \$6500.00'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.text('Costo Total: \$0.00'), findsOneWidget);
    expect(tester.widget<TextField>(campo).controller!.text, isEmpty);
  });
}
