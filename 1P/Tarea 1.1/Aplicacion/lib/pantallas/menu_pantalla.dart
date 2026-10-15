import 'package:flutter/material.dart';

class MenuPantalla extends StatelessWidget {
  const MenuPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    const opciones = {
      '/ventas': '1. Ventas de Tiki Taka',
      '/pagos': '2. Pagos durante 20 meses',
      '/tiendas': '3. Ventas de El mandilón',
      '/sueldos': '4. Sueldos semanales',
      '/inversion': '5. Inversión desde 1961',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Menú de ejercicios')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('NRC 36872', style: TextStyle(fontSize: 22)),
          const Text('Selecciona un ejercicio.'),
          const SizedBox(height: 20),
          for (final opcion in opciones.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, opcion.key),
                child: Text(opcion.value),
              ),
            ),
        ],
      ),
    );
  }
}
