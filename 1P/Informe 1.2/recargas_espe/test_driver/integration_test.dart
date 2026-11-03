import 'dart:io';
import 'dart:async';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await runZoned(
    () => integrationDriver(
      onScreenshot: (nombre, bytes, [args]) async {
        final carpeta = Directory('../Evidencias')..createSync(recursive: true);
        await File('${carpeta.path}/$nombre.png').writeAsBytes(bytes);
        return true;
      },
    ),
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        parent.print(
          zone,
          line.startsWith('result {')
              ? 'Datos de capturas recibidos; se guardan como PNG.'
              : line,
        );
      },
    ),
  );
}
