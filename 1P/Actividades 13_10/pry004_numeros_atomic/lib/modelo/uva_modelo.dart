class UvaModelo {
  double calcularPrecio(double precio, String tipo, int tamano) {
    if (tipo == 'A') {
      if (tamano == 1) {
        return precio + 0.20;
      } else {
        return precio + 0.30;
      }
    } else {
      if (tamano == 1) {
        return precio - 0.30;
      } else {
        return precio - 0.50;
      }
    }
  }

  double calcularTotal(double precio, double kilos, String tipo, int tamano) {
    return calcularPrecio(precio, tipo, tamano) * kilos;
  }
}
