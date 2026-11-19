import 'entidades.dart';

abstract interface class CatalogoRepository<T extends Registro, D> {
  Future<List<T>> listar();
  Future<T> crear(D datos);
  Future<T> editar(int id, D datos);
  Future<void> eliminar(int id);
}

abstract interface class NotasRepository {
  Future<List<Nota>> listar();
  Future<Nota> registrar(int estudianteId, int asignaturaId, double valor);
  Future<Nota> editar(int id, double valor);
  Future<void> eliminar(int id);
  Future<ResumenAcademico> resumen(int estudianteId);
}
