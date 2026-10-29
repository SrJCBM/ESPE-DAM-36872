import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/operario_viewmodel.dart';
import '../widgets/option_button.dart';
import '../widgets/campo_numero.dart';

class OperarioPantalla extends StatefulWidget{
  @override
  State<OperarioPantalla> createState() => _OperarioPantallaState();
}

class _OperarioPantallaState extends State<OperarioPantalla> {
  final sueldoController = TextEditingController();
  final antiguedadController = TextEditingController();

  void calcular(){
    double sueldo = double.parse(sueldoController.text);
    int antiguedad = int.parse(antiguedadController.text);
    final vm = context.read<OperarioViewModel>();
    final resultado = vm.calcular(sueldo, antiguedad);

    Navigator.pushNamed(context,
        '/resultado',
        arguments: resultado,
    );
  }
  @override
  Widget build(BuildContext context) {
    //
    final vm = context.watch<OperarioViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sueldo del operario'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(padding: EdgeInsets.all(20),
      child: Column(
          children: [
            CampoNumero(etiquete: 'Sueldo', controller: sueldoController),
            SizedBox(height: 10,),
            CampoNumero(etiquete: 'Antiguedad', controller: antiguedadController),
            SizedBox(height: 10,),
            OptionButton(titulo: 'Administrativo',
                valor: 'Administrativo',
                seleccionado: vm.tipoOperario,
                onChanged: (valor) => vm.seleccionarTipo(valor!),),
            OptionButton(titulo: 'Operario',
              valor: 'Operario',
              seleccionado: vm.tipoOperario,
              onChanged: (valor) => vm.seleccionarTipo(valor!),),

            ElevatedButton(onPressed: calcular, child: Text('calcular')),

      ],
      ),
      ),
    );
  }
}