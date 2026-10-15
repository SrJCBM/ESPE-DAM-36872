import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//definir mi clase principal

//1. Declarar el Statefull

class AreaPantalla extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _AreaPantallaState();

}

//2. Implementar el statefull

class _AreaPantallaState extends State<AreaPantalla>{
  //mapeo de objetos

  final baseCtrl=TextEditingController();
  final alturaCtrl=TextEditingController();

  double area = 0, perimetro = 0, valor = 0;

  //logica (metodos de los calculos)

  void calcular(){
    //
    final base = double.tryParse(baseCtrl.text) ??0;
    final altura = double.tryParse(alturaCtrl.text) ??0;
    //setState
    setState(() {
      area = base * altura;
      perimetro = 2 * (base + altura);
      valor = area * 500;
    });
  }




  //diseño

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Area de un terreno'),
          centerTitle: true,
        ),
        //contenedor principal
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Ingrese las madedidas del terreno', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,)),
              SizedBox(height: 20,),
              //campos texto
              TextField(
                controller: baseCtrl, //conectar el controlador
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Base metros',
                    border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: alturaCtrl, //conectar el controlador
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Altura metros',
                    border: OutlineInputBorder()
                ),
              ),

              SizedBox(height: 10,),
              //boton
              ElevatedButton(
                  onPressed: calcular,
                  child: Text('Calcular')
              ),

              SizedBox(height: 10,),
              //resultados
              Text('Area: ${area.toStringAsFixed(2)} m2'),
              Text('Perimetro: ${perimetro.toStringAsFixed(2)} m2'),
              Text('Valor total: \S${valor.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),)

            ],
          ),
        )

    );

  }
}