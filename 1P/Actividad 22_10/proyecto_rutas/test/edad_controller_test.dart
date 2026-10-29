import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_rutas/controllers/edad_controller.dart';

void main() {
  final controller = EdadController();
  final actual = DateTime.now();
  final hoy = DateTime.utc(actual.year, actual.month, actual.day);

  test('Usa la fecha actual y el nombre sin espacios sobrantes', () {
    expect(
      controller.calcularEdad(
        '${hoy.day}',
        '${hoy.month}',
        '${hoy.year}',
        nombre: ' Juan ',
      ),
      'Juan tiene 0 años, 0 meses y 0 días',
    );
  });

  test('Calcula los años completos de quien cumple hoy', () {
    expect(
      controller.calcularEdad('${hoy.day}', '${hoy.month}', '2000'),
      'La edad es: ${hoy.year - 2000} años, 0 meses y 0 días',
    );
  });

  test('Calcula los días desde el inicio del mes', () {
    expect(
      controller.calcularEdad('1', '${hoy.month}', '${hoy.year}'),
      'La edad es: 0 años, 0 meses y ${hoy.day - 1} días',
    );
  });

  for (final fecha in [
    ['', '02', '1992'],
    ['12.5', '02', '1992'],
    ['31', '02', '1992'],
    ['29', '02', '2023'],
    ['00', '02', '1992'],
    ['12', '13', '1992'],
    ['12', '02', '0'],
  ]) {
    test('Rechaza la fecha inválida ${fecha.join('/')}', () {
      expect(
        controller.calcularEdad(fecha[0], fecha[1], fecha[2]),
        'Ingresa una fecha válida',
      );
    });
  }

  test('Rechaza un nacimiento futuro', () {
    final manana = hoy.add(const Duration(days: 1));
    expect(
      controller.calcularEdad(
        '${manana.day}',
        '${manana.month}',
        '${manana.year}',
      ),
      'Ingresa una fecha válida',
    );
  });
}
