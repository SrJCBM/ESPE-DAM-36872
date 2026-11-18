import 'package:flutter_test/flutter_test.dart';

import 'package:pr01_apis/main.dart';

void main() {
  testWidgets('Muestra la pantalla para consultar la API', (tester) async {
    await tester.pumpWidget(const MiApp());
    expect(find.text('Consumo de API'), findsOneWidget);
    expect(find.text('Consultar API'), findsOneWidget);
  });
}
