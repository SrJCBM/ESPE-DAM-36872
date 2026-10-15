import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil/main.dart';
import 'package:app_movil/logica/servicio_calculos.dart';

void main() {
  test('Operaciones, terreno y límites numéricos', () {
    final servicio = ServicioCalculos();
    expect(servicio.resolverOperacion(8, 2, '+'), 10);
    expect(servicio.resolverOperacion(8, 2, '−'), 6);
    expect(servicio.resolverOperacion(-8, 2, '×'), -16);
    expect(servicio.resolverOperacion(8, 2, '÷'), 4);
    expect(servicio.evaluarTerreno(10, 20), (
      area: 200.0,
      perimetro: 60.0,
      valor: 100000.0,
    ));
    expect(() => servicio.resolverOperacion(1, 0, '÷'), throwsArgumentError);
    expect(() => servicio.evaluarTerreno(-1, 2), throwsArgumentError);
    expect(() => servicio.evaluarTerreno(double.nan, 2), throwsArgumentError);
    expect(() => servicio.evaluarTerreno(1e308, 2), throwsArgumentError);
  });

  testWidgets('Valida medidas, calcula con coma decimal y limpia', (
    tester,
  ) async {
    await tester.pumpWidget(const HerramientasApp());
    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.text('Ingresa un número válido.'), findsNWidgets(2));
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), '-1');
    await tester.enterText(campos.at(1), '2');
    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.text('La medida debe ser mayor que cero.'), findsOneWidget);
    await tester.enterText(campos.at(0), '10,5');
    await tester.enterText(campos.at(1), '2');
    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.textContaining('Área: 21.00 m²'), findsOneWidget);
    expect(find.textContaining('Perímetro: 25.00 m\n'), findsOneWidget);
    expect(find.textContaining('Valor total: \$10500.00'), findsOneWidget);
    await tester.ensureVisible(find.text('Limpiar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Limpiar'));
    await tester.pump();
    expect(find.text('Los resultados aparecerán aquí.'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(campos.first).controller!.text,
      isEmpty,
    );
  });

  testWidgets('Navega, suma negativos y rechaza división por cero', (
    tester,
  ) async {
    await tester.pumpWidget(const HerramientasApp());
    await tester.tap(find.text('Calculadora'));
    await tester.pumpAndSettle();
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), '-4');
    await tester.enterText(campos.at(1), '2');
    await tester.tap(find.text('+'));
    await tester.pump();
    expect(find.text('Resultado: -2.00'), findsOneWidget);
    await tester.enterText(campos.at(1), '0');
    await tester.tap(find.text('÷'));
    await tester.pump();
    expect(find.text('No se puede dividir entre cero.'), findsOneWidget);
    expect(find.text('Resultado: -2.00'), findsNothing);
    await tester.tap(find.text('Terreno'));
    await tester.pumpAndSettle();
    expect(find.text('Área de un terreno'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(campos.first).controller!.text,
      isEmpty,
    );
  });

  testWidgets('Pantalla pequeña admite teclado sin desbordamientos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const HerramientasApp());
    await tester.enterText(find.byType(TextFormField).first, '12');
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Limpiar'),
      100,
      scrollable: find
          .descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Limpiar').hitTestable(), findsOneWidget);
  });
}
