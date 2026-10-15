import 'package:flutter/material.dart';
import '../logica/ejercicios_logica.dart';
import 'formulario_ejercicio.dart';

class InversionPantalla extends StatelessWidget {
  const InversionPantalla({super.key});

  @override
  Widget build(BuildContext context) => FormularioEjercicio(
    titulo: '5. Inversión desde 1961',
    instrucciones:
        r'Capital inicial: $1500. Interés compuesto: 15% anual. Ingresa el año final (hasta el año actual).',
    etiquetas: ['Año final'],
    multilinea: false,
    calcular: (datos) => EjerciciosLogica().inversion(datos[0]),
  );
}
