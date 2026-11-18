import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';

class ItemApi {
  final String url = 'https://jsonplaceholder.typicode.com/users';

  Future<List<ItemModel>> obtenerItems() async {
    final respuesta = await http.get(Uri.parse(url));

    if (respuesta.statusCode == 200) {
      final List<dynamic> datos = jsonDecode(respuesta.body);

      return datos.map((item) => ItemModel.fromJson(item)).toList();
    }

    throw Exception('Error al consumir la API');
  }
}
