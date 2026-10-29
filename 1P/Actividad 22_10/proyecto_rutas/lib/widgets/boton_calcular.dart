import 'package:flutter/material.dart';

class BotonCalcular extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const BotonCalcular({
    super.key,
    required this.onPressed,
    this.label = 'Calcular',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
