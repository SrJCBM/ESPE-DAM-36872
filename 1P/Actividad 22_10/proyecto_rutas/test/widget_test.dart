import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_rutas/main.dart';

void main() {
  testWidgets('Calcula la edad y la recibe en la ruta de resultado', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.widgetWithText(TextField, 'Nombre (opcional)'), findsOneWidget);
    final campos = find.byType(TextField);
    final hoy = DateTime.now();
    await tester.enterText(campos.at(0), 'Juan');
    await tester.enterText(campos.at(1), hoy.day.toString());
    await tester.enterText(campos.at(2), hoy.month.toString());
    await tester.enterText(campos.at(3), hoy.year.toString());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Calcular edad'));
    await tester.pumpAndSettle();

    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('Juan tiene 0 años, 0 meses y 0 días'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Calcular edad'), findsNWidgets(2));
  });
}
