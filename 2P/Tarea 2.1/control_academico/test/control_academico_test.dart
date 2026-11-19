import 'dart:convert';

import 'package:control_academico/data/academico_api.dart';
import 'package:control_academico/domain/entidades.dart';
import 'package:control_academico/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object datos, [int codigo = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(datos)),
  codigo,
  headers: {'Content-Type': 'application/json; charset=utf-8'},
);

Map<String, Object> _pagina(List<Object> items) => {
  'items': items,
  'total': items.length,
  'limit': 100,
  'offset': 0,
};

const _ana = {
  'id': 1,
  'codigo': 'EST01',
  'nombres': 'Ana',
  'apellidos': 'Torres',
  'correo': 'ana@example.com',
};
const _materia = {'id': 2, 'codigo': 'MAT01', 'nombre': 'Matemática'};

void main() {
  test('acepta centésimas y clasifica los límites académicos', () {
    const casos = {
      '0': EstadoNota.reprobado,
      '8,99': EstadoNota.reprobado,
      '9': EstadoNota.recuperacion,
      '13.99': EstadoNota.recuperacion,
      '14': EstadoNota.aprobado,
      '20,00': EstadoNota.aprobado,
    };
    for (final caso in casos.entries) {
      expect(EstadoNota.para(interpretarNota(caso.key)!), caso.value);
    }
    for (final invalido in ['-1', '20,01', '13.999', 'NaN', '', '1e1']) {
      expect(interpretarNota(invalido), isNull, reason: invalido);
    }
  });

  test(
    'consulta todas las páginas sin perder los registros posteriores',
    () async {
      final offsets = <String?>[];
      final api = AcademicoApi(
        MockClient((request) async {
          offsets.add(request.url.queryParameters['offset']);
          return offsets.length == 1
              ? _json({
                  'items': [
                    {'id': 1},
                    {'id': 2},
                  ],
                  'total': 3,
                })
              : _json({
                  'items': [
                    {'id': 3},
                  ],
                  'total': 3,
                });
        }),
      );
      expect(
        await api.listar<int>('/estudiantes', (json) => json['id'] as int),
        [1, 2, 3],
      );
      expect(offsets, ['0', '2']);
    },
  );

  testWidgets('registra una nota desde la ficha y recarga el promedio', (
    tester,
  ) async {
    Map<String, Object>? nota;
    final cliente = MockClient((request) async {
      final ruta = request.url.path.replaceFirst('/api/v1', '');
      if (request.method == 'POST' && ruta == '/notas') {
        expect(jsonDecode(request.body), {
          'estudiante_id': 1,
          'asignatura_id': 2,
          'valor': 13.99,
        });
        nota = {
          'id': 3,
          'estudiante_id': 1,
          'asignatura_id': 2,
          'valor': 13.99,
          'estado': 'RECUPERACION',
        };
        return _json(nota!, 201);
      }
      return switch (ruta) {
        '/estudiantes' => _json(_pagina([_ana])),
        '/asignaturas' => _json(_pagina([_materia])),
        '/notas' => _json(_pagina([if (nota != null) nota!])),
        '/estudiantes/1/resumen-academico' => _json({
          'estudiante': _ana,
          'promedio': nota?['valor'],
          'total_notas': nota == null ? 0 : 1,
          'notas': [
            if (nota != null)
              {
                'id': 3,
                'asignatura': _materia,
                'valor': 13.99,
                'estado': 'RECUPERACION',
              },
          ],
        }),
        _ => throw StateError('Ruta inesperada: $ruta'),
      };
    });
    await tester.pumpWidget(ControlAcademicoApp(cliente: cliente));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Estudiantes'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana Torres'));
    await tester.pumpAndSettle();
    expect(find.text('Sin promedio'), findsOneWidget);
    await tester.tap(find.text('Registrar nota'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Torres'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('campo_asignatura')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Matemática').last);
    await tester.pumpAndSettle();

    final campo = find.byKey(const ValueKey('campo_nota'));
    await tester.enterText(campo, '20.01');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(
      find.text('Ingresa una nota de 0 a 20 con hasta dos decimales.'),
      findsOneWidget,
    );
    expect(nota, isNull);
    await tester.enterText(campo, '13,99');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('13,99 / 20'), findsNWidgets(2));
    expect(find.textContaining('Recuperación'), findsOneWidget);
  });

  testWidgets('muestra el error de negocio al borrar un estudiante con notas', (
    tester,
  ) async {
    final cliente = MockClient((request) async {
      final ruta = request.url.path.replaceFirst('/api/v1', '');
      if (request.method == 'DELETE' && ruta == '/estudiantes/1') {
        return _json({
          'detail': {
            'codigo': 'ESTUDIANTE_CON_NOTAS',
            'mensaje': 'Elimina primero las notas asociadas a estudiante.',
          },
        }, 409);
      }
      return switch (ruta) {
        '/estudiantes' => _json(_pagina([_ana])),
        '/asignaturas' => _json(_pagina([_materia])),
        '/notas' => _json(_pagina([])),
        '/estudiantes/1/resumen-academico' => _json({
          'estudiante': _ana,
          'promedio': 15.5,
          'total_notas': 1,
          'notas': [
            {
              'id': 3,
              'asignatura': _materia,
              'valor': 15.5,
              'estado': 'APROBADO',
            },
          ],
        }),
        _ => throw StateError('Ruta inesperada: $ruta'),
      };
    });
    await tester.pumpWidget(ControlAcademicoApp(cliente: cliente));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Estudiantes'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana Torres'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Opciones del estudiante'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar estudiante'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(
      find.text('Elimina primero las notas asociadas a estudiante.'),
      findsOneWidget,
    );
    expect(find.text('15,50 / 20'), findsNWidgets(2));
  });
}
