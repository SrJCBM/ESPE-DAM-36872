import 'package:flutter/material.dart';

class CampoNumero extends StatelessWidget {
  final TextEditingController controller;
  
  CampoNumero({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        signed: true,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Ingrese un número',
      ),
    );
  }
}
