import '../domain/entidades.dart';
import '../domain/repositorios.dart';
import 'academico_api.dart';

class CatalogoApiRepository<T extends Registro, D>
    implements CatalogoRepository<T, D> {
  const CatalogoApiRepository(
    this._api,
    this._ruta,
    this._leer,
    this._escribir,
  );

  final AcademicoApi _api;
  final String _ruta;
  final T Function(Json) _leer;
  final Json Function(D) _escribir;

  @override
  Future<List<T>> listar() => _api.listar(_ruta, _leer);

  @override
  Future<T> crear(D datos) async =>
      _leer(await _api.objeto('POST', _ruta, datos: _escribir(datos)));

  @override
  Future<T> editar(int id, D datos) async =>
      _leer(await _api.objeto('PATCH', '$_ruta/$id', datos: _escribir(datos)));

  @override
  Future<void> eliminar(int id) => _api.eliminar('$_ruta/$id');
}

CatalogoRepository<Estudiante, DatosEstudiante> estudiantesApi(
  AcademicoApi api,
) => CatalogoApiRepository(api, '/estudiantes', _estudiante, _datosEstudiante);

CatalogoRepository<Asignatura, DatosAsignatura> asignaturasApi(
  AcademicoApi api,
) => CatalogoApiRepository(api, '/asignaturas', _asignatura, _datosAsignatura);

class NotasApiRepository implements NotasRepository {
  const NotasApiRepository(this._api);
  final AcademicoApi _api;

  @override
  Future<List<Nota>> listar() => _api.listar('/notas', _nota);

  @override
  Future<Nota> registrar(
    int estudianteId,
    int asignaturaId,
    double valor,
  ) async => _nota(
    await _api.objeto(
      'POST',
      '/notas',
      datos: {
        'estudiante_id': estudianteId,
        'asignatura_id': asignaturaId,
        'valor': valor,
      },
    ),
  );

  @override
  Future<Nota> editar(int id, double valor) async =>
      _nota(await _api.objeto('PATCH', '/notas/$id', datos: {'valor': valor}));

  @override
  Future<void> eliminar(int id) => _api.eliminar('/notas/$id');

  @override
  Future<ResumenAcademico> resumen(int estudianteId) async {
    final json = await _api.objeto(
      'GET',
      '/estudiantes/$estudianteId/resumen-academico',
    );
    final notas = (json['notas'] as List).map((item) {
      final detalle = item as Json;
      final asignatura = _asignatura(detalle['asignatura'] as Json);
      return NotaPorAsignatura(
        _nota({
          ...detalle,
          'estudiante_id': estudianteId,
          'asignatura_id': asignatura.id,
        }),
        asignatura,
      );
    });
    return ResumenAcademico(
      estudiante: _estudiante(json['estudiante'] as Json),
      promedio: (json['promedio'] as num?)?.toDouble(),
      notas: List.unmodifiable(notas),
    );
  }
}

Estudiante _estudiante(Json json) => Estudiante(
  json['id'] as int,
  DatosEstudiante(
    json['codigo'] as String,
    json['nombres'] as String,
    json['apellidos'] as String,
    json['correo'] as String,
  ),
);

Json _datosEstudiante(DatosEstudiante datos) => {
  'codigo': datos.codigo,
  'nombres': datos.nombres,
  'apellidos': datos.apellidos,
  'correo': datos.correo,
};

Asignatura _asignatura(Json json) => Asignatura(
  json['id'] as int,
  DatosAsignatura(json['codigo'] as String, json['nombre'] as String),
);

Json _datosAsignatura(DatosAsignatura datos) => {
  'codigo': datos.codigo,
  'nombre': datos.nombre,
};

Nota _nota(Json json) => Nota(
  id: json['id'] as int,
  estudianteId: json['estudiante_id'] as int,
  asignaturaId: json['asignatura_id'] as int,
  valor: (json['valor'] as num).toDouble(),
  estado: switch (json['estado']) {
    'APROBADO' => EstadoNota.aprobado,
    'RECUPERACION' => EstadoNota.recuperacion,
    'REPROBADO' => EstadoNota.reprobado,
    _ => throw const ErrorAcademico(
      'La API devolvió un estado de nota desconocido.',
    ),
  },
);
