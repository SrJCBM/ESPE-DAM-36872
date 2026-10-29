import 'package:flutter/material.dart';

class CampoNumero extends StatelessWidget{
  final String etiquete;
  final TextEditingController controller;

  CampoNumero({required this.etiquete, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: etiquete),
    );  }

}