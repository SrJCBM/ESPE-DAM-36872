import 'package:flutter/material.dart';

import '../../modelo/recarga.dart';
import '../atomos/boton_principal.dart';
import '../organismos/pagina_base.dart';
import '../organismos/detalle_comprobante.dart';

class ComprobantePantalla extends StatelessWidget {
  const ComprobantePantalla({
    super.key,
    required this.comprobante,
    required this.onNueva,
    required this.onLogout,
  });
  final Comprobante comprobante;
  final VoidCallback onNueva;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => PaginaBase(
    paso: '03 / COMPROBANTE',
    titulo: 'Simulación completada.',
    descripcion: 'Este comprobante registra el resultado de la práctica.',
    onLogout: onLogout,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetalleComprobante(comprobante: comprobante),
        const SizedBox(height: 24),
        BotonPrincipal(
          texto: 'Nueva recarga',
          icono: Icons.add,
          onPressed: onNueva,
        ),
      ],
    ),
  );
}
