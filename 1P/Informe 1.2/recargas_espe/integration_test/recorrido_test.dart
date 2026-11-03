import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recargas_espe/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Recorrido Android con capturas reales de seis estados', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    Future<void> ocultarTeclado() async {
      // WidgetTester conserva focusedEditable al desenfocar manualmente.
      // Liberarlo permite que enterText reabra la conexión del mismo campo.
      binding.focusedEditable = null;
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
    }

    Future<void> iniciarSesion() async {
      await ocultarTeclado();
      await tester.ensureVisible(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    }

    Future<void> captura(String nombre) async {
      await ocultarTeclado();
      await binding.takeScreenshot(nombre);
    }

    await captura('01_acceso');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa tu usuario.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    await captura('02_validacion_acceso');

    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrecta');
    await iniciarSesion();
    expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
    await captura('03_credenciales_incorrectas');

    await tester.enterText(find.byType(TextFormField).at(1), 'Admin123*');
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      'admin',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      'Admin123*',
    );
    await iniciarSesion();
    expect(find.text('Conecta en segundos.'), findsOneWidget);
    await captura('04_nueva_recarga');

    await tester.enterText(find.byType(TextFormField).at(0), '0991234567');
    await ocultarTeclado();
    await tester.tap(find.byKey(const Key('operadora')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Claro · comisión 3 %').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '10');
    await ocultarTeclado();
    await tester.tap(find.byKey(const Key('formaPago')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Efectivo').last);
    await tester.pumpAndSettle();
    expect(find.text('\$10,30'), findsOneWidget);
    await captura('05_recarga_claro');

    await tester.ensureVisible(find.text('Confirmar simulación'));
    await tester.tap(find.text('Confirmar simulación'));
    await tester.pumpAndSettle();
    expect(find.text('Simulación completada.'), findsOneWidget);
    expect(find.text('0991234567'), findsOneWidget);
    expect(find.text('\$10,30'), findsOneWidget);
    await captura('06_comprobante');

    await tester.ensureVisible(find.text('Nueva recarga'));
    await tester.tap(find.text('Nueva recarga'));
    await tester.pumpAndSettle();
    expect(find.text('0991234567'), findsNothing);
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
