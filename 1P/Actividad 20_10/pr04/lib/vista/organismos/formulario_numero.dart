import 'package:flutter/material.dart';
import '../moleculas/entrada_numero.dart';

class FormularioNumero extends StatelessWidget {
  final TextEditingController a;
  final TextEditingController b;
  final TextEditingController c;
  const FormularioNumero({
    super.key,
    required this.a,
    required this.b,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EntradaNumero(controller: a, etiqueta: 'Número A'),
        SizedBox(height: 10.0),
        EntradaNumero(controller: b, etiqueta: 'Número B'),
        SizedBox(height: 10.0),
        EntradaNumero(controller: c, etiqueta: 'Número C'),
      ],
    );
  }

  
}
