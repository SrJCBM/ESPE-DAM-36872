import 'package:flutter/material.dart';
import '../logica/ejercicios_logica.dart';
import 'formulario_ejercicio.dart';

class VentasPantalla extends StatelessWidget {
  const VentasPantalla({super.key});

  @override
  Widget build(BuildContext context) => FormularioEjercicio(
    titulo: '1. Ventas de Tiki Taka',
    instrucciones:
        'Ingresa una venta por línea. N es la cantidad de ventas ingresadas.',
    etiquetas: ['Ventas del día'],
    multilinea: true,
    calcular: (datos) => EjerciciosLogica().ventas(datos[0]),
  );
}
