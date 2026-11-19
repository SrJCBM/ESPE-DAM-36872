import 'dart:convert';

import 'package:control_academico/data/academico_api.dart';
import 'package:control_academico/domain/casos_de_uso.dart';
import 'package:control_academico/domain/entidades.dart';
import 'package:control_academico/domain/repositorios.dart';
import 'package:control_academico/main.dart';
import 'package:control_academico/presentation/view_models/view_models.dart';
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
const _fisica = {'id': 4, 'codigo': 'FIS01', 'nombre': 'Física'};
const _quimica = {'id': 5, 'codigo': 'QUI01', 'nombre': 'Química'};

Map<String, Object> _notaJson(
  int id,
  Map<String, Object> asignatura,
  double valor,
  String estado,
) => {'id': id, 'asignatura': asignatura, 'valor': valor, 'estado': estado};

/// Ficha de Ana con las notas indicadas. El promedio lo calcula el servidor,
/// por eso la prueba lo fija y comprueba que el filtro no lo recalcula.
http.Client _clienteConNotas(
  List<Map<String, Object>> notas, {
  double? promedio,
}) => MockClient((request) async {
  final ruta = request.url.path.replaceFirst('/api/v1', '');
  return switch (ruta) {
    '/estudiantes' => _json(_pagina([_ana])),
    '/asignaturas' => _json(_pagina([_materia, _fisica, _quimica])),
    '/notas' => _json(_pagina([])),
    '/estudiantes/1/resumen-academico' => _json({
      'estudiante': _ana,
      'promedio': promedio,
      'total_notas': notas.length,
      'notas': notas,
    }),
    _ => throw StateError('Ruta inesperada: $ruta'),
  };
});

Future<void> _abrirFicha(WidgetTester tester, http.Client cliente) async {
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
}

Future<void> _elegirFiltro(WidgetTester tester, String etiqueta) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('filtro_notas')),
      matching: find.text(etiqueta),
    ),
  );
  await tester.pumpAndSettle();
}

class _RepositorioDeResumen implements NotasRepository {
  _RepositorioDeResumen(this.resumenActual);
  ResumenAcademico resumenActual;

  @override
  Future<ResumenAcademico> resumen(int estudianteId) async => resumenActual;

  @override
  Future<List<Nota>> listar() => throw UnimplementedError();
  @override
  Future<Nota> registrar(int estudianteId, int asignaturaId, double valor) =>
      throw UnimplementedError();
  @override
  Future<Nota> editar(int id, double valor) => throw UnimplementedError();
  @override
  Future<void> eliminar(int id) => throw UnimplementedError();
}

ResumenAcademico _resumen(Map<String, double> valores, double? promedio) {
  var id = 0;
  return ResumenAcademico(
    estudiante: const Estudiante(
      1,
      DatosEstudiante('EST01', 'Ana', 'Torres', 'ana@example.com'),
    ),
    promedio: promedio,
    notas: [
      for (final MapEntry(key: nombre, value: valor) in valores.entries)
        NotaPorAsignatura(
          Nota(
            id: ++id,
            estudianteId: 1,
            asignaturaId: id,
            valor: valor,
            estado: EstadoNota.para(valor),
          ),
          Asignatura(id, DatosAsignatura('COD$id', nombre)),
        ),
    ],
  );
}

List<String> _nombres(ResumenViewModel vm) => [
  for (final item in vm.notasVisibles) item.asignatura.datos.nombre,
];

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

  // Trazabilidad con la especificación de requisitos (IS.2): RF-01 y RF-02 en
  // el selector y la lista, RF-03 en el aviso sin resultados y RF-04 en el
  // promedio general.
  group('filtro Todas / Reprobadas de la ficha', () {
    Finder promedio(String texto) => find.descendant(
      of: find.byKey(const ValueKey('promedio_general')),
      matching: find.text(texto),
    );

    test('RF-02: solo acepta notas reprobadas y respeta el límite de 9', () {
      Nota nota(double valor) => Nota(
        id: 1,
        estudianteId: 1,
        asignaturaId: 1,
        valor: valor,
        estado: EstadoNota.para(valor),
      );
      for (final valor in [0.0, 8.99]) {
        expect(FiltroNotas.reprobadas.acepta(nota(valor)), isTrue);
      }
      for (final valor in [9.0, 13.99, 14.0, 20.0]) {
        expect(FiltroNotas.reprobadas.acepta(nota(valor)), isFalse);
      }
      for (final valor in [0.0, 9.0, 14.0, 20.0]) {
        expect(FiltroNotas.todas.acepta(nota(valor)), isTrue);
      }
    });

    test('RF-01, RF-02 y RF-04: el ViewModel inicia en Todas, filtra y '
        'conserva el promedio', () async {
      final repositorio = _RepositorioDeResumen(
        _resumen({'Matemática': 16, 'Física': 12, 'Química': 8}, 12),
      );
      final vm = ResumenViewModel(GestionarNotas(repositorio), 1);
      await vm.cargar();
      var avisos = 0;
      vm.addListener(() => avisos++);

      expect(vm.filtro, FiltroNotas.todas);
      expect(_nombres(vm), ['Matemática', 'Física', 'Química']);

      vm.filtrar(FiltroNotas.reprobadas);
      expect(_nombres(vm), ['Química']);
      expect(vm.resumen!.promedio, 12);
      expect(vm.resumen!.notas, hasLength(3));

      vm.filtrar(FiltroNotas.todas);
      expect(_nombres(vm), ['Matemática', 'Física', 'Química']);
      expect(vm.resumen!.promedio, 12);

      vm.filtrar(FiltroNotas.todas);
      expect(avisos, 2, reason: 'repetir el mismo filtro no notifica');
    });

    test(
      'RF-03: devuelve una lista vacía si no hay notas reprobadas',
      () async {
        final repositorio = _RepositorioDeResumen(
          _resumen({'Matemática': 16, 'Física': 12}, 14),
        );
        final vm = ResumenViewModel(GestionarNotas(repositorio), 1);
        await vm.cargar();

        vm.filtrar(FiltroNotas.reprobadas);
        expect(vm.notasVisibles, isEmpty);
        expect(vm.resumen!.notas, hasLength(2));
        expect(vm.resumen!.promedio, 14);
      },
    );

    test('conserva el filtro elegido al recargar la ficha', () async {
      final repositorio = _RepositorioDeResumen(
        _resumen({'Matemática': 16, 'Química': 8}, 12),
      );
      final vm = ResumenViewModel(GestionarNotas(repositorio), 1);
      await vm.cargar();
      vm.filtrar(FiltroNotas.reprobadas);

      repositorio.resumenActual = _resumen({
        'Matemática': 16,
        'Química': 8,
        'Física': 3,
      }, 9);
      await vm.cargar();

      expect(vm.filtro, FiltroNotas.reprobadas);
      expect(_nombres(vm), ['Química', 'Física']);
    });

    testWidgets('RF-01, RF-02 y RF-04: Reprobadas deja solo 8,00 y el promedio '
        'sigue en 12,00', (tester) async {
      await _abrirFicha(
        tester,
        _clienteConNotas([
          _notaJson(1, _materia, 16, 'APROBADO'),
          _notaJson(2, _fisica, 12, 'RECUPERACION'),
          _notaJson(3, _quimica, 8, 'REPROBADO'),
        ], promedio: 12),
      );
      final selector = find.byKey(const ValueKey('filtro_notas'));
      expect(tester.widget<SegmentedButton<FiltroNotas>>(selector).selected, {
        FiltroNotas.todas,
      });
      expect(find.text('Matemática'), findsOneWidget);
      expect(find.text('Física'), findsOneWidget);
      expect(find.text('Química'), findsOneWidget);
      expect(find.text('16,00 / 20'), findsOneWidget);
      expect(find.text('8,00 / 20'), findsOneWidget);
      expect(promedio('12,00 / 20'), findsOneWidget);

      await _elegirFiltro(tester, 'Reprobadas');
      expect(find.text('Química'), findsOneWidget);
      expect(find.text('8,00 / 20'), findsOneWidget);
      expect(find.text('Reprobado'), findsOneWidget);
      expect(find.text('Matemática'), findsNothing);
      expect(find.text('Física'), findsNothing);
      expect(find.text('16,00 / 20'), findsNothing);
      expect(promedio('12,00 / 20'), findsOneWidget);
      expect(find.text('3 notas registradas'), findsOneWidget);

      await _elegirFiltro(tester, 'Todas');
      expect(find.text('Matemática'), findsOneWidget);
      expect(find.text('Física'), findsOneWidget);
      expect(find.text('Química'), findsOneWidget);
      expect(promedio('12,00 / 20'), findsOneWidget);
    });

    testWidgets('RF-02: una nota de 9,00 queda fuera de Reprobadas', (
      tester,
    ) async {
      await _abrirFicha(
        tester,
        _clienteConNotas([
          _notaJson(1, _materia, 9, 'RECUPERACION'),
          _notaJson(2, _fisica, 8.99, 'REPROBADO'),
        ], promedio: 9),
      );
      expect(find.text('Matemática'), findsOneWidget);

      await _elegirFiltro(tester, 'Reprobadas');
      expect(find.text('Física'), findsOneWidget);
      expect(find.text('8,99 / 20'), findsOneWidget);
      expect(find.text('Matemática'), findsNothing);
      expect(find.text('Recuperación'), findsNothing);
    });

    testWidgets('RF-03: avisa cuando ninguna nota está reprobada y permite '
        'volver a Todas', (tester) async {
      await _abrirFicha(
        tester,
        _clienteConNotas([
          _notaJson(1, _materia, 16, 'APROBADO'),
          _notaJson(2, _fisica, 12, 'RECUPERACION'),
        ], promedio: 14),
      );

      await _elegirFiltro(tester, 'Reprobadas');
      expect(find.text('No hay calificaciones reprobadas'), findsOneWidget);
      expect(find.text('Matemática'), findsNothing);
      expect(find.text('Física'), findsNothing);
      expect(find.text('Sin calificaciones'), findsNothing);
      expect(promedio('14,00 / 20'), findsOneWidget);

      await tester.ensureVisible(find.text('Ver todas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver todas'));
      await tester.pumpAndSettle();
      expect(find.text('No hay calificaciones reprobadas'), findsNothing);
      expect(find.text('Matemática'), findsOneWidget);
      expect(find.text('Física'), findsOneWidget);
    });

    testWidgets('sin notas registradas no ofrece filtro', (tester) async {
      await _abrirFicha(tester, _clienteConNotas([]));
      expect(find.text('Sin calificaciones'), findsOneWidget);
      expect(find.byKey(const ValueKey('filtro_notas')), findsNothing);
    });
  });
}
