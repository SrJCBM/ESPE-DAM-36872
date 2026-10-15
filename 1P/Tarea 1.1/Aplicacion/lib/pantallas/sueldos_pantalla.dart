import 'package:flutter/material.dart';
import '../logica/ejercicios_logica.dart';
import 'formulario_ejercicio.dart';

class SueldosPantalla extends StatelessWidget {
  const SueldosPantalla({super.key});

  @override
  Widget build(BuildContext context) => FormularioEjercicio(
    titulo: '4. Sueldos semanales',
    instrucciones:
        'Un trabajador por línea: nombre; horas; sueldo por hora. Ejemplo: Ana; 10; 15. Descuentos: hasta 150, 5%; más de 150 y menos de 300, 7%; de 300 a menos de 450, 9%. Desde 450: 0% (no definido en el enunciado).',
    etiquetas: ['Trabajadores'],
    multilinea: true,
    calcular: (datos) => EjerciciosLogica().sueldos(datos[0]),
  );
}
