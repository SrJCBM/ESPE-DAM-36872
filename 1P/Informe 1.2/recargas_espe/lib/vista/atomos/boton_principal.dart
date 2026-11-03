import 'package:flutter/material.dart';

class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icono = Icons.arrow_forward_rounded,
  });
  final String texto;
  final VoidCallback onPressed;
  final IconData icono;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icono, size: 20),
    label: Text(texto),
  );
}
