import 'package:flutter/material.dart';

import '../../modelo/recarga.dart';
import '../moleculas/resumen_montos.dart';

class DetalleComprobante extends StatelessWidget {
  const DetalleComprobante({super.key, required this.comprobante});
  final Comprobante comprobante;

  @override
  Widget build(BuildContext context) {
    final r = comprobante;
    String dos(int n) => n.toString().padLeft(2, '0');
    final fecha =
        '${dos(r.fecha.day)}/${dos(r.fecha.month)}/${r.fecha.year} '
        '${dos(r.fecha.hour)}:${dos(r.fecha.minute)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 56,
          color: Color(0xFF135E4B),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _dato('Teléfono', r.telefono),
              _dato('Operadora', r.cotizacion.operadora.nombre),
              _dato('Forma de pago', r.formaPago.nombre),
              _dato('Usuario', r.usuario),
              _dato('Fecha local', fecha),
              const Divider(),
              const Text(
                'Número de comprobante',
                style: TextStyle(fontSize: 12),
              ),
              SelectableText(
                r.codigo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ResumenMontos(cotizacion: r.cotizacion),
      ],
    );
  }

  Widget _dato(String etiqueta, String valor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(child: Text(etiqueta)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            valor,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
