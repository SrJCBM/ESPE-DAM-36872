class ServicioCalculos {
  static const tarifaMetroCuadrado = 500.0;

  double resolverOperacion(double a, double b, String operacion) {
    final resultado = switch (operacion) {
      '+' => a + b,
      '−' => a - b,
      '×' => a * b,
      '÷' =>
        b == 0 ? throw ArgumentError('No se puede dividir entre cero.') : a / b,
      _ => throw ArgumentError('Operación desconocida.'),
    };
    if (!resultado.isFinite) {
      throw ArgumentError('El resultado es demasiado grande.');
    }
    return resultado;
  }

  ({double area, double perimetro, double valor}) evaluarTerreno(
    double base,
    double altura,
  ) {
    if (!base.isFinite || !altura.isFinite || base <= 0 || altura <= 0) {
      throw ArgumentError('Las medidas deben ser positivas y finitas.');
    }
    final area = base * altura;
    final perimetro = 2 * (base + altura);
    final valor = area * tarifaMetroCuadrado;
    if (!area.isFinite || !perimetro.isFinite || !valor.isFinite) {
      throw ArgumentError('Las medidas son demasiado grandes.');
    }
    return (area: area, perimetro: perimetro, valor: valor);
  }
}
