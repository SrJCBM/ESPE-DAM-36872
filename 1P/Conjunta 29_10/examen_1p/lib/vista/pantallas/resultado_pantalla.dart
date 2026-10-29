import 'package:flutter/material.dart';
import '../../modelos/vendedor_modelo.dart';

class ResultadoPantalla extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vendedor =
    ModalRoute.of(context)!.settings.arguments as VendedorModelo;

    Widget dato(String titulo, String valor) {
      return ListTile(
        title: Text(titulo),
        trailing: Text(valor),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultado'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  dato(
                    'Sueldo base',
                    '\$${vendedor.sueldoBase.toStringAsFixed(2)}',
                  ),
                  dato(
                    'Ventas del mes',
                    '\$${vendedor.ventas.toStringAsFixed(2)}',
                  ),
                  dato(
                    'Porcentaje',
                    '${(vendedor.porcentaje * 100).toStringAsFixed(0)} %',
                  ),
                  dato(
                    'Comisión',
                    '\$${vendedor.comision.toStringAsFixed(2)}',
                  ),
                  dato(
                    'Sueldo final',
                    '\$${vendedor.sueldoFinal.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}