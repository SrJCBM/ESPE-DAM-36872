import 'package:flutter/material.dart';
import '../modelos/vendedor_modelo.dart';

class VendedorViewModel extends ChangeNotifier {
  VendedorModelo? resultado;

  VendedorModelo calcular(double sueldoBase, double ventas) {
    double porcentaje = 0;

    if (ventas >= 2000) {
      porcentaje = 0.15;
    } else if (ventas >= 1000) {
      porcentaje = 0.10;
    } else if (ventas >= 500) {
      porcentaje = 0.05;
    }

    double comision = ventas * porcentaje;
    double sueldoFinal = sueldoBase + comision;

    final vendedor = VendedorModelo(
      sueldoBase: sueldoBase,
      ventas: ventas,
      porcentaje: porcentaje,
      comision: comision,
      sueldoFinal: sueldoFinal,
    );

    resultado = vendedor;
    notifyListeners();

    return vendedor;
  }
}