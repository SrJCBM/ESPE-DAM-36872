import 'package:flutter_test/flutter_test.dart';
import 'package:pr01_apis/data/models/item_model.dart';

void main() {
  test('Convierte el nombre enviado por JSONPlaceholder', () {
    final item = ItemModel.fromJson({
      'id': 1,
      'name': 'Leanne Graham',
      'email': 'Sincere@april.biz',
    });

    expect(item.id, 1);
    expect(item.nombre, 'Leanne Graham');
    expect(item.email, 'Sincere@april.biz');
  });
}
