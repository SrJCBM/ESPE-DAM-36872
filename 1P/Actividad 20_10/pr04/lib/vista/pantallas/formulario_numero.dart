import 'package:flutter/material.dart';
import '../../controlador/numero_controlador.dart';
import '../organismos/formulario_numero.dart';
import '../../modelo/numeros_modelos.dart';

class NumerosPantalla extends StatefulWidget {
  NumerosPantalla({super.key});

  @override
  State<NumerosPantalla> createState() => _NumerosPantallaState();
}

class _NumerosPantallaState extends State<NumerosPantalla> {
  //mapeo de los controladores de texto para los campos de la caja de texto
  final a = TextEditingController();
  final b = TextEditingController();
  final c = TextEditingController();
  //instacia y conexion con la lógica
  final controlador = NumeroControlador();
  //variable para almacenar el resultado del cálculo
  NumeroModelo? resultado;

  void calcular() {
    int? n1 = int.tryParse(a.text);
    int? n2 = int.tryParse(b.text);
    int? n3 = int.tryParse(c.text);
    if (n1 == null || n2 == null || n3 == null) {
      // Mostrar un mensaje de error si alguno de los campos no es un número válido
      setState(() {
        resultado = null; // Reiniciar el resultado si hay un error
      });
      return;
    }
    setState(() {
      resultado = controlador.calcular(n1, n2, n3);
    });
  }

  void limpiar() {
    a.clear();
    b.clear();
    c.clear();
    setState(() => resultado = null);
  }

  @override
  void dispose() {
    a.dispose();
    b.dispose();
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Operaciones'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: calcular,
            tooltip: 'Calcular',
            icon: const Icon(Icons.calculate),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: limpiar,
        tooltip: 'Limpiar',
        child: const Icon(Icons.delete),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ingrese tres números:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            FormularioNumero(a: a, b: b, c: c),
            SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16.0),
              ),
              onPressed: calcular,
              child: Text('Calcular'),
            ),
            SizedBox(height: 20.0),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Text(
                      'Resultados:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    if (resultado != null) ...[
                      Text('Suma: ${resultado!.suma}'),
                      Text('Producto: ${resultado!.producto}'),
                      Text('Diferentes: ${resultado!.diferentes}'),
                      Text('Promedio: ${resultado!.promedio}'),
                    ] else ...[
                      Text('Ingrese números válidos para calcular.'),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
