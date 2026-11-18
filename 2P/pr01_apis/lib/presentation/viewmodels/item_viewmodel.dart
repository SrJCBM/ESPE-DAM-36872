import 'package:flutter/material.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/obtener_items.dart';

class ItemViewModel extends ChangeNotifier{
  final ObtenerItems obtenerItems;

  ItemViewModel(this.obtenerItems);

  List<Item> items = [];
  bool cargando = false;
  String error = '';

  Future<void> cargarItems() async {
    cargando = true;
    error = '';
    notifyListeners();

    try {
      items = await obtenerItems.ejecutar();
    } catch (e) {
      error = 'No se puede cargar los datos';
    }

    cargando = false;
    notifyListeners();
  }
}