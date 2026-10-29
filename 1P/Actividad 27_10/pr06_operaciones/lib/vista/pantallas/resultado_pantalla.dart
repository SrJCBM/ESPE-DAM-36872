import 'package:flutter/material.dart';
import '../../modelos/operario_modelo.dart';

class ResultadoPantalla extends StatelessWidget {
  const ResultadoPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final operario =
    ModalRoute.of(context)!.settings.arguments as OperarioModelo;

    Widget dato(String titulo, String valor) {
      return ListTile(
        title: Text(titulo),
        trailing: Text(valor),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  dato('Tipo', operario.tipo),
                  dato('Sueldo', '\$${operario.sueldo}'),
                  dato('Antigüedad', '${operario.antiguedad} años'),
                  dato(
                    'Aumento',
                    '${operario.porcentaje * 100} %',
                  ),
                  dato('Valor aumento', '\$${operario.aumento}'),
                  dato('Sueldo final', '\$${operario.sueldoFinal}'),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}