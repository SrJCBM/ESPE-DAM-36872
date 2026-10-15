import '../modelo/uva_modelo.dart';

class UvaControlador {
  String calcular(
    String precioTexto,
    String kilosTexto,
    String tipoTexto,
    String tamanoTexto,
  ) {
    final precio = double.tryParse(precioTexto.trim());
    final kilos = double.tryParse(kilosTexto.trim());
    final tipo = tipoTexto.trim().toUpperCase();
    final tamano = int.tryParse(tamanoTexto.trim());

    if (precio == null ||
        kilos == null ||
        !precio.isFinite ||
        !kilos.isFinite ||
        precio <= 0 ||
        kilos <= 0) {
      return 'Ingrese un precio y una cantidad de kilos mayores a cero.';
    }
    if (tipo != 'A' && tipo != 'B') {
      return 'El tipo debe ser A o B.';
    }
    if (tamano != 1 && tamano != 2) {
      return 'El tamaño debe ser 1 o 2.';
    }

    final uva = UvaModelo();
    final precioFinal = uva.calcularPrecio(precio, tipo, tamano!);
    if (precioFinal < 0) {
      return 'El precio final no puede ser negativo.';
    }
    final total = uva.calcularTotal(precio, kilos, tipo, tamano);
    return 'Precio final por kilo: \$${precioFinal.toStringAsFixed(2)}\n'
        'Total a recibir: \$${total.toStringAsFixed(2)}';
  }
}
