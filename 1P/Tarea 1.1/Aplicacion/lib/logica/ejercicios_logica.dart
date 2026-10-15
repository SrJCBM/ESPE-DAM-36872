class EjerciciosLogica {
  double numero(String texto) {
    final valor = double.tryParse(texto.trim().replaceAll(',', '.'));
    if (valor == null || !valor.isFinite || valor < 0) {
      throw const FormatException('Ingresa números válidos, no negativos.');
    }
    return valor;
  }

  List<String> filas(String texto) {
    final lista = texto
        .trim()
        .split('\n')
        .where((f) => f.trim().isNotEmpty)
        .toList();
    if (lista.isEmpty) {
      throw const FormatException('Ingresa al menos un registro.');
    }
    return lista;
  }

  String dinero(double valor) {
    if (!valor.isFinite) {
      throw const FormatException('El resultado es demasiado grande.');
    }
    return '\$${valor.toStringAsFixed(2)}';
  }

  String ventas(String texto) {
    final cantidades = [0, 0, 0];
    final montos = [0.0, 0.0, 0.0];
    for (final fila in filas(texto)) {
      final venta = numero(fila);
      final grupo = venta > 1000 ? 0 : (venta > 500 ? 1 : 2);
      cantidades[grupo]++;
      montos[grupo] += venta;
    }
    const grupos = [
      'Mayores a 1000',
      'Mayores a 500 y hasta 1000',
      'Hasta 500',
    ];
    return [
      for (int i = 0; i < 3; i++)
        '${grupos[i]}: ${cantidades[i]} ventas; ${dinero(montos[i])}',
      'Número de ventas: ${cantidades.reduce((a, b) => a + b)}',
      'Total vendido: ${dinero(montos.reduce((a, b) => a + b))}',
    ].join('\n');
  }

  String pagos() {
    double pago = 10, total = 0;
    final detalle = <String>[];
    for (int mes = 1; mes <= 20; mes++) {
      detalle.add('Mes $mes: ${dinero(pago)}');
      total += pago;
      pago *= 2;
    }
    return [...detalle, 'Total pagado: ${dinero(total)}'].join('\n');
  }

  String tiendas(List<String> datos) {
    final dimensiones = datos
        .take(3)
        .map((d) => int.tryParse(d.trim()))
        .toList();
    if (dimensiones.any((n) => n == null || n <= 0)) {
      throw const FormatException(
        'Ciudades, tiendas y empleados deben ser enteros positivos.',
      );
    }
    final c = dimensiones[0]!, t = dimensiones[1]!, n = dimensiones[2]!;
    final ventas = filas(datos[3]).map(numero).toList();
    if (ventas.length != c * t * n) {
      throw FormatException(
        'Se requieren ${c * t * n} ventas, una por empleado.',
      );
    }
    int posicion = 0;
    double totalCadena = 0;
    final detalle = <String>[];
    for (int ciudad = 1; ciudad <= c; ciudad++) {
      double totalCiudad = 0;
      for (int tienda = 1; tienda <= t; tienda++) {
        double totalTienda = 0;
        for (int empleado = 1; empleado <= n; empleado++) {
          final venta = ventas[posicion++];
          detalle.add(
            'Ciudad $ciudad · Tienda $tienda · Empleado $empleado: ${dinero(venta)}',
          );
          totalTienda += venta;
        }
        detalle.add(
          'Total tienda $tienda de ciudad $ciudad: ${dinero(totalTienda)}',
        );
        totalCiudad += totalTienda;
      }
      detalle.add('Total ciudad $ciudad: ${dinero(totalCiudad)}');
      totalCadena += totalCiudad;
    }
    return [...detalle, 'Total cadena: ${dinero(totalCadena)}'].join('\n');
  }

  String sueldos(String texto) {
    final detalle = <String>[];
    for (final fila in filas(texto)) {
      final datos = fila.split(';');
      if (datos.length != 3 || datos[0].trim().isEmpty) {
        throw const FormatException(
          'Formato por línea: nombre; horas; sueldo por hora.',
        );
      }
      final bruto = numero(datos[1]) * numero(datos[2]);
      // Criterio del ejercicio: 300 inicia el tramo del 9%; desde 450, 0%.
      final tasa = bruto <= 150
          ? 0.05
          : (bruto < 300 ? 0.07 : (bruto < 450 ? 0.09 : 0.0));
      final descuento = bruto * tasa;
      detalle.add(
        '${datos[0].trim()}: bruto ${dinero(bruto)}, descuento ${(tasa * 100).toInt()}% (${dinero(descuento)}), neto ${dinero(bruto - descuento)}',
      );
    }
    return ['Trabajadores: ${detalle.length}', ...detalle].join('\n');
  }

  String inversion(String texto) {
    final anio = int.tryParse(texto.trim());
    if (anio == null || anio < 1961 || anio > DateTime.now().year) {
      throw FormatException(
        'Ingresa un año entre 1961 y ${DateTime.now().year}.',
      );
    }
    double capital = 1500;
    for (int actual = 1961; actual < anio; actual++) {
      capital *= 1.15;
    }
    return 'Años transcurridos: ${anio - 1961}\nInversión acumulada: ${dinero(capital)}';
  }
}
