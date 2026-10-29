import 'package:flutter/material.dart';
import '../controllers/edad_controller.dart';
import '../widgets/boton_calcular.dart';
import '../widgets/input_dato.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final controller = EdadController();

  final nombreCtrl = TextEditingController();
  final diaCtrl = TextEditingController();
  final mesCtrl = TextEditingController();
  final anioCtrl = TextEditingController();

  void calcular() {
    final resultado = controller.calcularEdad(
      diaCtrl.text,
      mesCtrl.text,
      anioCtrl.text,
      nombre: nombreCtrl.text,
    );

    //Paso de parametros
    Navigator.pushNamed(context, '/resultado', arguments: resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calcular edad'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Text('Ingresa tu nombre y tu fecha de nacimiento'),
            const SizedBox(height: 16),
            InputDato(
              controller: nombreCtrl,
              label: 'Nombre (opcional)',
              tipoTeclado: TextInputType.name,
            ),
            const SizedBox(height: 16),
            InputDato(controller: diaCtrl, label: 'Día'),
            const SizedBox(height: 16),
            InputDato(controller: mesCtrl, label: 'Mes'),
            const SizedBox(height: 16),
            InputDato(controller: anioCtrl, label: 'Año'),
            const SizedBox(height: 20),
            BotonCalcular(onPressed: calcular, label: 'Calcular edad'),
          ],
        ),
      ),
    );
  }
}
