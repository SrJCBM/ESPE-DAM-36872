import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leccion1p/main.dart' as app;

void main() {
  testWidgets('Navega, calcula y limpia los ejercicios', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ir a los ejercicios'));
    await tester.pumpAndSettle();
    final campo = find.byType(TextField);
    final casos = [
      ['0', 'No es primo', 'Factorial: 0! = 1', 'Es capicúa'],
      ['1', 'No es primo', 'Factorial: 1! = 1 = 1', 'Es capicúa'],
      ['2', 'Es primo', 'Factorial: 2! = 2 x 1 = 2', 'Es capicúa'],
      [
        '5',
        'Es primo',
        'Factorial: 5! = 5 x 4 x 3 x 2 x 1 = 120',
        'Es capicúa',
      ],
      ['12', 'No es primo', '479001600', 'No es capicúa'],
      ['121', 'No es primo', 'Factorial: 121!', 'Es capicúa'],
      ['21', 'No es primo', '51090942171709440000', 'No es capicúa'],
    ];
    for (final caso in casos) {
      await tester.enterText(campo, caso[0]);
      await tester.tap(find.text('Calcular'));
      await tester.pump();
      final salida = tester
          .widget<Text>(
            find.byWidgetPredicate(
              (w) => w is Text && (w.data ?? '').startsWith('Primo:'),
            ),
          )
          .data!;
      for (final esperado in caso.skip(1)) {
        expect(salida, contains(esperado));
      }
    }
    await tester.tap(find.text('Limpiar'));
    await tester.pump();
    expect(tester.widget<TextField>(campo).controller!.text, isEmpty);
    expect(find.textContaining('Factorial:'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido'), findsOneWidget);
  });

  testWidgets('Rechaza entradas vacias, negativas o no enteras', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ir a los ejercicios'));
    await tester.pumpAndSettle();
    for (final entrada in ['', '-1', 'abc', '2.5']) {
      await tester.enterText(find.byType(TextField), entrada);
      await tester.tap(find.text('Calcular'));
      await tester.pump();
      expect(
        find.text('Ingrese un número entero mayor o igual a cero.'),
        findsOneWidget,
      );
    }
  });
}
