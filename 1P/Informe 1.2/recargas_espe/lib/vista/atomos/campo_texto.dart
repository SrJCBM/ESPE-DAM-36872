import 'package:flutter/material.dart';

/// Átomo de entrada: control elemental reutilizable por las moléculas.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controller,
    required this.decoration,
    required this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });
  final TextEditingController controller;
  final InputDecoration decoration;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: decoration,
    validator: validator,
    obscureText: obscureText,
    keyboardType: keyboardType,
    onChanged: onChanged,
    autocorrect: false,
    enableSuggestions: !obscureText,
  );
}
