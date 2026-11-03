import 'package:flutter/material.dart';

import '../atomos/campo_texto.dart';

/// Molécula: etiqueta y control de entrada, icono, ayuda y validación.
class EntradaCampo extends StatelessWidget {
  const EntradaCampo({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.icono,
    required this.validator,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.onChanged,
    this.hint,
  });
  final TextEditingController controller;
  final String etiqueta;
  final IconData icono;
  final String? Function(String?) validator;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: CampoTexto(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: hint,
        prefixIcon: Icon(icono),
        suffixIcon: suffix,
      ),
    ),
  );
}
