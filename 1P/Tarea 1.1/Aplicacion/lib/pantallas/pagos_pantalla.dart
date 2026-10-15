import 'package:flutter/material.dart';
import '../logica/ejercicios_logica.dart';
import 'formulario_ejercicio.dart';

class PagosPantalla extends StatelessWidget {
  const PagosPantalla({super.key});

  @override
  Widget build(BuildContext context) => FormularioEjercicio(
    titulo: '2. Pagos mensuales',
    instrucciones:
        r'El primer pago es $10 y se duplica cada mes durante 20 meses.',
    etiquetas: [],
    multilinea: false,
    calcular: (datos) => EjerciciosLogica().pagos(),
  );
}
