import 'package:flutter/material.dart';
import '../logica/ejercicios_logica.dart';
import 'formulario_ejercicio.dart';

class TiendasPantalla extends StatelessWidget {
  const TiendasPantalla({super.key});

  @override
  Widget build(BuildContext context) => FormularioEjercicio(
    titulo: '3. Ventas de El mandilón',
    instrucciones:
        'Ingresa C ciudades, T tiendas por ciudad y N empleados por tienda. Luego una venta por línea, en orden: ciudad, tienda y empleado.',
    etiquetas: [
      'Ciudades (C)',
      'Tiendas por ciudad (T)',
      'Empleados por tienda (N)',
      'Ventas por empleado',
    ],
    multilinea: true,
    calcular: (datos) => EjerciciosLogica().tiendas(datos),
  );
}
