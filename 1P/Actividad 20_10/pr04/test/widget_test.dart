import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pr04/main.dart';

void main() {
  testWidgets('Abre el formulario, calcula desde la barra y limpia', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Operaciones'), findsOneWidget);
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), '3');
    await tester.enterText(campos.at(1), '6');
    await tester.enterText(campos.at(2), '9');
    await tester.tap(find.byTooltip('Calcular'));
    await tester.pump();
    expect(find.text('Suma: 18'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    for (final campo in tester.widgetList<TextFormField>(campos)) {
      expect(campo.controller!.text, isEmpty);
    }
    expect(find.text('Suma: 18'), findsNothing);
    expect(find.text('Ingrese números válidos para calcular.'), findsOneWidget);
  });
}
