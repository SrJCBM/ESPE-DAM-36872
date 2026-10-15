import 'package:flutter/material.dart';
import '../logica/viaje_estudiantil_logica.dart';

class ViajeEstudiantilPantalla extends StatefulWidget {
  const ViajeEstudiantilPantalla({super.key});

  @override
  State<ViajeEstudiantilPantalla> createState() =>
      _ViajeEstudiantilPantallaState();
}

class _ViajeEstudiantilPantallaState extends State<ViajeEstudiantilPantalla> {
  final alumnoController = TextEditingController();
  Viaje viaje = Viaje();
  String costoAlumno = '0.00';
  String pagoTotal = '0.00';
  String mensaje = '';

  void _calcularCosto() {
    final alumnos = int.tryParse(alumnoController.text.trim());
    if (alumnos == null || alumnos <= 0) {
      setState(() {
        mensaje = 'Por favor, ingrese un número válido de alumnos.';
        costoAlumno = '0.00';
        pagoTotal = '0.00';
      });
      return;
    }
    double costo = viaje.calcularCostoAlumno(alumnos);
    double total = viaje.calcularPagoTotal(alumnos);
    setState(() {
      costoAlumno = costo.toStringAsFixed(2);
      pagoTotal = total.toStringAsFixed(2);
      mensaje = '';
    });
  }

  void _limpiarCampos() {
    setState(() {
      alumnoController.clear();
      costoAlumno = '0.00';
      pagoTotal = '0.00';
      mensaje = '';
    });
  }

  @override
  void dispose() {
    alumnoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Costo del Viaje Estudiantil'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: alumnoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de alumnos',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calcularCosto,
              child: const Text('Calcular Costo Total'),
            ),
            const SizedBox(height: 20),
            Text(
              mensaje,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Costo por Alumno: \$$costoAlumno',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 20),
            Text(
              'Costo Total: \$$pagoTotal',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _limpiarCampos,
        backgroundColor: Colors.red,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
