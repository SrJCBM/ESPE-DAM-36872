import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/vendedor_viewmodel.dart';
import '../widgets/campo_numero.dart';

class VendedorPantalla extends StatefulWidget {
  @override
  State<VendedorPantalla> createState() => _VendedorPantallaState();
}

class _VendedorPantallaState extends State<VendedorPantalla> {
  final sueldoController = TextEditingController();
  final ventasController = TextEditingController();

  void calcular() {
    final sueldo = double.tryParse(sueldoController.text);
    final ventas = double.tryParse(ventasController.text);

    if (sueldo == null ||
        ventas == null ||
        !sueldo.isFinite ||
        !ventas.isFinite ||
        sueldo < 0 ||
        ventas < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingresa valores válidos, mayores o iguales a 0')),
      );
      return;
    }

    final vm = context.read<VendedorViewModel>();
    final resultado = vm.calcular(sueldo, ventas);

    Navigator.pushNamed(
      context,
      '/resultado',
      arguments: resultado,
    );
  }

  @override
  void dispose() {
    sueldoController.dispose();
    ventasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datos del vendedor'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CampoNumero(
              etiqueta: 'Sueldo base',
              controller: sueldoController,
            ),
            SizedBox(height: 15),
            CampoNumero(
              etiqueta: 'Ventas del mes',
              controller: ventasController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calcular,
              child: Text('Calcular comisión'),
            ),
          ],
        ),
      ),
    );
  }
}