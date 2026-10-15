import 'package:flutter/material.dart';

// Comparte únicamente los campos y botones; cada ejercicio tiene su ruta.
class FormularioEjercicio extends StatefulWidget {
  final String titulo, instrucciones;
  final List<String> etiquetas;
  final String Function(List<String>) calcular;
  final bool multilinea;

  const FormularioEjercicio({
    super.key,
    required this.titulo,
    required this.instrucciones,
    required this.etiquetas,
    required this.calcular,
    this.multilinea = true,
  });

  @override
  State<FormularioEjercicio> createState() => _FormularioEjercicioState();
}

class _FormularioEjercicioState extends State<FormularioEjercicio> {
  late final controles = [
    for (final _ in widget.etiquetas) TextEditingController(),
  ];
  String resultado = '';

  void calcular() {
    FocusScope.of(context).unfocus();
    try {
      final respuesta = widget.calcular([for (final c in controles) c.text]);
      setState(() => resultado = respuesta);
    } on FormatException catch (error) {
      setState(() => resultado = error.message);
    }
  }

  @override
  void dispose() {
    for (final control in controles) {
      control.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.titulo)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.instrucciones),
          const SizedBox(height: 16),
          for (int i = 0; i < controles.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                controller: controles[i],
                minLines: widget.multilinea && i == controles.length - 1
                    ? 3
                    : 1,
                maxLines: widget.multilinea && i == controles.length - 1
                    ? 6
                    : 1,
                decoration: InputDecoration(
                  labelText: widget.etiquetas[i],
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => resultado = ''),
              ),
            ),
          ElevatedButton(onPressed: calcular, child: const Text('Calcular')),
          TextButton(
            onPressed: () {
              for (final control in controles) {
                control.clear();
              }
              setState(() => resultado = '');
            },
            child: const Text('Limpiar'),
          ),
          const SizedBox(height: 10),
          Text(resultado, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver al menú'),
          ),
        ],
      ),
    ),
  );
}
