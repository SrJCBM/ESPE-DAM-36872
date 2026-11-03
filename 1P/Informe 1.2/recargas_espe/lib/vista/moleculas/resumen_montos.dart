import 'package:flutter/material.dart';

import '../../modelo/recarga.dart';
import '../../tema/tema_aplicacion.dart';

class ResumenMontos extends StatelessWidget {
  const ResumenMontos({super.key, required this.cotizacion});
  final Cotizacion? cotizacion;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFE8EEE7),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        _fila(
          'Valor de recarga',
          Dinero.formato(cotizacion?.valorCentavos ?? 0),
        ),
        const SizedBox(height: 8),
        _fila(
          'Comisión${cotizacion == null ? '' : ' (${cotizacion!.operadora.porcentaje})'}',
          Dinero.formato(cotizacion?.comisionCentavos ?? 0),
        ),
        const Divider(height: 26),
        _fila(
          'Total a pagar',
          Dinero.formato(cotizacion?.totalCentavos ?? 0),
          total: true,
        ),
      ],
    ),
  );

  Widget _fila(String etiqueta, String valor, {bool total = false}) => Row(
    children: [
      Expanded(child: Text(etiqueta)),
      const SizedBox(width: 8),
      Text(
        valor,
        style: TextStyle(
          fontSize: total ? 25 : 16,
          fontWeight: total ? FontWeight.w700 : FontWeight.w500,
          color: TemaAplicacion.tinta,
        ),
      ),
    ],
  );
}
