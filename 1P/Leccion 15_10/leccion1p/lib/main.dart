import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const Bienvenida(),
      '/ejercicios': (context) => const Ejercicios(),
    },
  ),
);

class Bienvenida extends StatelessWidget {
  const Bienvenida({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('App de numeros')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Bienvenido'),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/ejercicios'),
            child: const Text('Ir a los ejercicios'),
          ),
        ],
      ),
    ),
  );
}

class Ejercicios extends StatefulWidget {
  const Ejercicios({super.key});

  @override
  State<Ejercicios> createState() => _EjerciciosState();
}

class _EjerciciosState extends State<Ejercicios> {
  final numeroController = TextEditingController();
  String resultado = '';

  void calcular() {
    final numero = int.tryParse(numeroController.text.trim());

    if (numero == null || numero < 0) {
      setState(
        () => resultado = 'Ingrese un número entero mayor o igual a cero.',
      );
      return;
    }

    bool primo = numero >= 2;
    for (int i = 2; i * i <= numero && primo; i++) {
      primo = numero % i != 0;
    }

    BigInt factorial = BigInt.one;
    List<String> pasos = [];
    for (int i = numero; i >= 1; i--) {
      factorial *= BigInt.from(i);
      pasos.add('$i');
    }
    String textoFactorial = numero == 0
        ? 'Factorial: 0! = 1'
        : 'Factorial: $numero! = ${pasos.join(' x ')} = $factorial';

    String texto = numero.toString();
    bool capicua = texto == texto.split('').reversed.join();

    setState(
      () => resultado =
          'Primo: ${primo ? "Es primo" : "No es primo"}\n\n'
          '$textoFactorial\n\n'
          'Capicúa: ${capicua ? "Es capicúa" : "No es capicúa"}',
    );
  }

  void limpiar() {
    setState(() {
      numeroController.clear();
      resultado = '';
    });
  }

  @override
  void dispose() {
    numeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ejercicios')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: numeroController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Ingrese un numero entero',
            ),
          ),
          ElevatedButton(onPressed: calcular, child: const Text('Calcular')),
          ElevatedButton(onPressed: limpiar, child: const Text('Limpiar')),
          Text(resultado),
        ],
      ),
    ),
  );
}
