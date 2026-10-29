import 'package:flutter/material.dart';

class ResultadoView extends StatelessWidget {
  const ResultadoView({super.key});

  @override
  Widget build(BuildContext context) {
    //Para recibir los parametros desde la pantalla
    final resultado = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            resultado,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
