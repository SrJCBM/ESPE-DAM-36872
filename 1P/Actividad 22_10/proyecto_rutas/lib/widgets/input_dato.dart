import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputDato extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType tipoTeclado;

  const InputDato({required this.controller, required this.label, this.tipoTeclado = TextInputType.number,});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: tipoTeclado,
      inputFormatters: tipoTeclado == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
    );
  }
}
