import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/vendedor_viewmodel.dart';

class InicioPantalla extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VendedorViewModel>();
    final resultado = vm.resultado;

    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Comisión de ventas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Ingresa el sueldo base y las ventas del mes '
                  'para poder calcular el sueldo final',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/vendedor'),
              child: Text('Comenzar'),
            ),
            if (resultado != null)
              Text(
                'Último sueldo calculado: '
                    '\$${resultado.sueldoFinal.toStringAsFixed(2)}',
              ),
          ],
        ),
      ),
    );
  }
}