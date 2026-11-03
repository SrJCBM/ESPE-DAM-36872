/// Tarifas ficticias para la práctica; no representan precios comerciales.
enum Operadora {
  claro('Claro', 300, '3 %'),
  movistar('Movistar', 250, '2,5 %'),
  cnt('CNT', 200, '2 %');

  const Operadora(this.nombre, this.puntosBase, this.porcentaje);
  final String nombre;
  final int puntosBase;
  final String porcentaje;
}

enum FormaPago {
  efectivo('Efectivo'),
  transferencia('Transferencia');

  const FormaPago(this.nombre);
  final String nombre;
}

class Dinero {
  /// Convierte la entrada decimal a centavos sin usar aritmética de coma flotante.
  static int? parsear(String texto) {
    final limpio = texto.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d{1,3}(\.\d{1,2})?$').hasMatch(limpio)) return null;
    final partes = limpio.split('.');
    return int.parse(partes[0]) * 100 +
        (partes.length == 2 ? int.parse(partes[1].padRight(2, '0')) : 0);
  }

  static String formato(int centavos) =>
      '\$${centavos ~/ 100},${(centavos % 100).toString().padLeft(2, '0')}';
}

class Cotizacion {
  const Cotizacion({required this.valorCentavos, required this.operadora});
  final int valorCentavos;
  final Operadora operadora;

  // Redondeo al centavo más próximo; medio centavo se redondea hacia arriba.
  int get comisionCentavos =>
      (valorCentavos * operadora.puntosBase + 5000) ~/ 10000;
  int get totalCentavos => valorCentavos + comisionCentavos;
}

class Comprobante {
  const Comprobante({
    required this.codigo,
    required this.fecha,
    required this.usuario,
    required this.telefono,
    required this.formaPago,
    required this.cotizacion,
  });
  final String codigo;
  final DateTime fecha;
  final String usuario;
  final String telefono;
  final FormaPago formaPago;
  final Cotizacion cotizacion;
}
