import '../modelo/recarga.dart';

class RecargaControlador {
  RecargaControlador({DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now;
  final DateTime Function() _reloj;
  int _secuencia = 0;
  Comprobante? _ultimo;
  Comprobante? get ultimo => _ultimo;

  String? validarTelefono(String? valor) =>
      RegExp(r'^09\d{8}$').hasMatch(valor?.trim() ?? '')
      ? null
      : 'Ingresa 10 dígitos que comiencen con 09.';

  String? validarValor(String? valor) {
    final centavos = Dinero.parsear(valor ?? '');
    if (centavos == null) return 'Usa un número con hasta 2 decimales.';
    if (centavos < 100 || centavos > 10000) {
      return 'El valor permitido es de \$1,00 a \$100,00.';
    }
    return null;
  }

  Cotizacion? cotizar(String valor, Operadora? operadora) {
    if (operadora == null || validarValor(valor) != null) return null;
    return Cotizacion(
      valorCentavos: Dinero.parsear(valor)!,
      operadora: operadora,
    );
  }

  Comprobante confirmar({
    required String usuario,
    required String telefono,
    required String valor,
    required Operadora? operadora,
    required FormaPago? formaPago,
  }) {
    final cotizacion = cotizar(valor, operadora);
    if (usuario.trim().isEmpty ||
        validarTelefono(telefono) != null ||
        cotizacion == null ||
        formaPago == null) {
      throw ArgumentError('Completa los datos válidos antes de confirmar.');
    }
    final fecha = _reloj();
    _secuencia++;
    _ultimo = Comprobante(
      codigo: 'SIM-${fecha.millisecondsSinceEpoch}-$_secuencia',
      fecha: fecha,
      usuario: usuario,
      telefono: telefono.trim(),
      formaPago: formaPago,
      cotizacion: cotizacion,
    );
    return _ultimo!;
  }

  void limpiar() => _ultimo = null;
}
