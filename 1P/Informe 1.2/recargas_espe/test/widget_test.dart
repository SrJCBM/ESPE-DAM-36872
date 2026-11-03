import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recargas_espe/main.dart';

void main() {
  Future<void> acceder(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'Admin123*');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
  }

  testWidgets('La aplicación inicia con acceso y controles obligatorios', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Limpiar'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byTooltip('Mostrar contraseña'), findsOneWidget);
  });

  testWidgets('Acceso valida vacíos y credenciales incorrectas', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa tu usuario.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'error');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
  });

  testWidgets('Mostrar contraseña y Limpiar restablecen el acceso', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.enterText(find.byType(TextFormField).at(1), 'secreto');
    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
      isFalse,
    );
    await tester.tap(find.text('Limpiar'));
    await tester.pump();
    expect(find.text('secreto'), findsNothing);
    expect(find.byTooltip('Mostrar contraseña'), findsOneWidget);
  });

  testWidgets('Ruta de comprobante exige sesión', (tester) async {
    await tester.pumpWidget(const MainApp());
    Navigator.of(tester.element(find.text('Iniciar sesión')))
        .pushNamed('/comprobante');
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Simulación completada.'), findsNothing);
  });

  testWidgets('Flujo completo calcula, emite comprobante y cierra sesión', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MainApp());
    await acceder(tester);
    expect(find.text('Conecta en segundos.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '0991234567');
    await tester.tap(find.byKey(const Key('operadora')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Claro · comisión 3 %').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '10');
    await tester.tap(find.byKey(const Key('formaPago')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Efectivo').last);
    await tester.pumpAndSettle();
    expect(find.text('\$10,30'), findsOneWidget);
    await tester.ensureVisible(find.text('Confirmar simulación'));
    await tester.tap(find.text('Confirmar simulación'));
    await tester.pumpAndSettle();
    expect(find.text('Simulación completada.'), findsOneWidget);
    expect(find.text('0991234567'), findsOneWidget);
    expect(find.text('\$10,30'), findsOneWidget);
    await tester.ensureVisible(find.text('Nueva recarga'));
    await tester.tap(find.text('Nueva recarga'));
    await tester.pumpAndSettle();
    expect(find.text('0991234567'), findsNothing);
    expect(find.text('\$0,00'), findsNWidgets(3));
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsNothing);
  });

  testWidgets('Recarga no confirma formulario vacío', (tester) async {
    await tester.pumpWidget(const MainApp());
    await acceder(tester);
    await tester.ensureVisible(find.text('Confirmar simulación'));
    await tester.tap(find.text('Confirmar simulación'));
    await tester.pumpAndSettle();
    expect(find.text('Selecciona una operadora.'), findsOneWidget);
    expect(find.text('Selecciona una forma de pago.'), findsOneWidget);
    expect(find.text('Simulación completada.'), findsNothing);
  });

  testWidgets('Vista estrecha y texto ampliado permiten desplazamiento', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MainApp());
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'Admin123*');
    await tester.ensureVisible(find.text('Iniciar sesión'));
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Confirmar simulación'));
    expect(tester.takeException(), isNull);
  });
}
