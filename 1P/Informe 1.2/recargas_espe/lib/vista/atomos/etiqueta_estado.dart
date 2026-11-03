import 'package:flutter/material.dart';

import '../../tema/tema_aplicacion.dart';

class EtiquetaEstado extends StatelessWidget {
  const EtiquetaEstado({super.key, required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFE1EEE5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        texto,
        style: const TextStyle(
          color: TemaAplicacion.verde,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
