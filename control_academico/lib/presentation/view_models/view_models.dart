import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/casos_de_uso.dart';
import '../../domain/entidades.dart';

String mensajeDe(Object error) => error is ErrorAcademico
    ? error.mensaje
    : 'No pudimos procesar la respuesta de la API. Intenta de nuevo.';

class ColeccionViewModel<T extends Registro> extends ChangeNotifier {
  ColeccionViewModel(this._listar);

  final Future<List<T>> Function() _listar;
  List<T> _items = const [];
  List<T> get items => _items;
  bool cargando = true;
  bool guardando = false;
  String? errorCarga;
  String? errorOperacion;

  bool _activo = true;
  int _cargaActual = 0;

  T? buscar(int id) {
    for (final registro in _items) {
      if (registro.id == id) return registro;
    }
    return null;
  }

  Future<void> cargar() async {
    final turno = ++_cargaActual;
    cargando = true;
    errorCarga = null;
    _avisar();
    try {
      final items = await _listar();
      if (turno == _cargaActual) _items = List.unmodifiable(items);
    } catch (error) {
      if (turno == _cargaActual) errorCarga = mensajeDe(error);
    } finally {
      if (turno == _cargaActual) {
        cargando = false;
        _avisar();
      }
    }
  }

  Future<bool> persistir(Future<T> Function() guardar) => _operar(() async {
    final registro = await guardar();
    _items = List.unmodifiable(
      [..._items.where((item) => item.id != registro.id), registro]
        ..sort((a, b) => a.id.compareTo(b.id)),
    );
  });

  Future<bool> quitar(int id, Future<void> Function() eliminar) =>
      _operar(() async {
        await eliminar();
        _items = List.unmodifiable(_items.where((item) => item.id != id));
      });

  Future<bool> _operar(Future<void> Function() accion) async {
    if (guardando) return false;
    guardando = true;
    errorOperacion = null;
    _avisar();
    try {
      await accion();
      if (_activo && (cargando || errorCarga != null)) unawaited(cargar());
      return true;
    } catch (error) {
      errorOperacion = mensajeDe(error);
      return false;
    } finally {
      guardando = false;
      _avisar();
    }
  }

  void _avisar() {
    if (_activo) notifyListeners();
  }

  @override
  void dispose() {
    _activo = false;
    super.dispose();
  }
}

class CatalogoViewModel<T extends Registro, D> extends ColeccionViewModel<T> {
  CatalogoViewModel(this._gestionar) : super(_gestionar.listar);
  final GestionarCatalogo<T, D> _gestionar;

  Future<bool> guardar(D datos, {int? id}) =>
      persistir(() => _gestionar.guardar(datos, id: id));

  Future<bool> eliminar(int id) => quitar(id, () => _gestionar.eliminar(id));
}

class EstudiantesViewModel
    extends CatalogoViewModel<Estudiante, DatosEstudiante> {
  EstudiantesViewModel(super.gestionar);
}

class AsignaturasViewModel
    extends CatalogoViewModel<Asignatura, DatosAsignatura> {
  AsignaturasViewModel(super.gestionar);
}

class NotasViewModel extends ColeccionViewModel<Nota> {
  NotasViewModel(this._gestionar) : super(_gestionar.listar);
  final GestionarNotas _gestionar;

  Future<bool> registrar(int estudianteId, int asignaturaId, double valor) =>
      persistir(() => _gestionar.registrar(estudianteId, asignaturaId, valor));

  Future<bool> editar(int id, double valor) =>
      persistir(() => _gestionar.editar(id, valor));

  Future<bool> eliminar(int id) => quitar(id, () => _gestionar.eliminar(id));
}

class ResumenViewModel extends ChangeNotifier {
  ResumenViewModel(this._gestionar, this.estudianteId);

  final GestionarNotas _gestionar;
  final int estudianteId;
  ResumenAcademico? resumen;
  String? error;
  bool cargando = true;
  bool _activo = true;
  int _cargaActual = 0;

  Future<void> cargar() async {
    final turno = ++_cargaActual;
    cargando = true;
    error = null;
    if (_activo) notifyListeners();
    try {
      final datos = await _gestionar.resumen(estudianteId);
      if (turno == _cargaActual) resumen = datos;
    } catch (fallo) {
      if (turno == _cargaActual) error = mensajeDe(fallo);
    } finally {
      if (turno == _cargaActual) {
        cargando = false;
        if (_activo) notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _activo = false;
    super.dispose();
  }
}
