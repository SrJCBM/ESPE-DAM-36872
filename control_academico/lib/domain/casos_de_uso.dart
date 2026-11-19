import 'entidades.dart';
import 'repositorios.dart';

/// Operaciones compartidas por los catálogos de estudiantes y asignaturas.
class GestionarCatalogo<T extends Registro, D> {
  const GestionarCatalogo(this._repositorio);
  final CatalogoRepository<T, D> _repositorio;

  Future<List<T>> listar() => _repositorio.listar();
  Future<T> guardar(D datos, {int? id}) =>
      id == null ? _repositorio.crear(datos) : _repositorio.editar(id, datos);
  Future<void> eliminar(int id) => _repositorio.eliminar(id);
}

class GestionarNotas {
  const GestionarNotas(this._repositorio);
  final NotasRepository _repositorio;

  Future<List<Nota>> listar() => _repositorio.listar();
  Future<ResumenAcademico> resumen(int estudianteId) =>
      _repositorio.resumen(estudianteId);

  Future<Nota> registrar(int estudianteId, int asignaturaId, double valor) {
    if (estudianteId <= 0 || asignaturaId <= 0) {
      throw const ErrorAcademico('Selecciona un estudiante y una asignatura.');
    }
    _validar(valor);
    return _repositorio.registrar(estudianteId, asignaturaId, valor);
  }

  Future<Nota> editar(int id, double valor) {
    _validar(valor);
    return _repositorio.editar(id, valor);
  }

  Future<void> eliminar(int id) => _repositorio.eliminar(id);

  void _validar(double valor) {
    if (interpretarNota(valor.toString()) == null) {
      throw const ErrorAcademico(
        'Ingresa una nota de 0 a 20 con hasta dos decimales.',
      );
    }
  }
}
