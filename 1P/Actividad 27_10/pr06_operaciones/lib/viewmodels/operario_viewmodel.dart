import 'package:flutter/material.dart';
import '../modelos/operario_modelo.dart';

class OperarioViewModel extends ChangeNotifier {
  String tipoOperario = 'Operario';

  void seleccionarTipo(String tipo){
    tipoOperario = tipo;
    notifyListeners();
  }

  OperarioModelo calcular(double sueldo, int antiguedad){
    double porcentaje = 0;
    if(sueldo < 500 && antiguedad >= 10){
      porcentaje=0.20;
    } else if (sueldo <500 && antiguedad < 10) {
      porcentaje = 0.05;
    }
    double aumento = sueldo * porcentaje;
    double sueldoFinal = sueldo + aumento;

    return OperarioModelo(
      sueldo:sueldo,
      antiguedad: antiguedad,
      tipo: tipoOperario,
      porcentaje: porcentaje,
      aumento: aumento,
      sueldoFinal: sueldoFinal
    );
  }
}