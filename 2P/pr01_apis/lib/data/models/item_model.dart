import '../../domain/entities/item.dart';

class ItemModel extends Item {
  ItemModel({required super.id,
    required super.nombre,
    required super.email});

  //metodo factory
factory ItemModel.fromJson(Map<String,dynamic> json){
  return ItemModel(
      id: json['id'],
      nombre: json['name'],
      email: json['email'] ?? 'Sin email',);
}

}
