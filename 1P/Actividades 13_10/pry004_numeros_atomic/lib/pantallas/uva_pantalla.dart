import 'package:flutter/material.dart';
import '../controlador/uva_controlador.dart';

class UvaPantalla extends StatefulWidget {
  const UvaPantalla({super.key});

  @override
  State<UvaPantalla> createState() => _UvaPantallaState();
}

class _UvaPantallaState extends State<UvaPantalla> {
  final precioController = TextEditingController();
  final kilosController = TextEditingController();
  final tipoController = TextEditingController();
  final tamanoController = TextEditingController();
  final controlador = UvaControlador();
  String resultado = '';

  void calcular() {
    setState(() {
      resultado = controlador.calcular(
        precioController.text,
        kilosController.text,
        tipoController.text,
        tamanoController.text,
      );
    });
  }

  void limpiar() {
    setState(() {
      precioController.clear();
      kilosController.clear();
      tipoController.clear();
      tamanoController.clear();
      resultado = '';
    });
  }

  @override
  void dispose() {
    precioController.dispose();
    kilosController.dispose();
    tipoController.dispose();
    tamanoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta de Uvas'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: precioController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Precio inicial por kilo',
              ),
            ),
            TextField(
              controller: kilosController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Cantidad de kilos'),
            ),
            TextField(
              controller: tipoController,
              decoration: const InputDecoration(
                labelText: 'Tipo de uva (A o B)',
              ),
            ),
            TextField(
              controller: tamanoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tamaño (1 o 2)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: calcular, child: const Text('Calcular')),
            ElevatedButton(onPressed: limpiar, child: const Text('Limpiar')),
            const SizedBox(height: 20),
            Text(resultado, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
