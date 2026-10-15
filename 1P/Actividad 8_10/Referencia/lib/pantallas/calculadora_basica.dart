import 'package:flutter/material.dart';
import '../logica/calculadora_logica.dart';

// crear el stateful/declarar

class CalculadoraPantalla extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalculadoraPantallaState();

}

//implementar el stateful/crear
class _CalculadoraPantallaState extends State<CalculadoraPantalla>{

  //mapeo
  final numero1 = TextEditingController();
  final numero2 = TextEditingController();
  //instance la logica
  Calculadora calculadora = Calculadora();
  //variable
  String resultado = '';
  //calculos
  void sumar(){
    double a = double.parse(numero1.text);
    double b = double.parse(numero2.text);
    setState(() {
      resultado = calculadora.sumar(a, b).toString();
    });
  }

  void restar(){
    double a = double.parse(numero1.text);
    double b = double.parse(numero2.text);
    setState(() {
      resultado = calculadora.restar(a, b).toString();
    });
  }

  void multiplicar(){
    double a = double.parse(numero1.text);
    double b = double.parse(numero2.text);
    setState(() {
      resultado = calculadora.multiplicar(a, b).toString();
    });
  }

  void dividir(){
    double a = double.parse(numero1.text);
    double b = double.parse(numero2.text);
    setState(() {
      //resultado = calculadora.dividir(a, b).toString();
      if(b == 0){
        resultado = 'Error';
      }else{
        resultado = calculadora.dividir(a, b).toString();
      }
    });
  }

  //limpiar

  void limpiar(){
    setState(() {
      numero1.clear();
      numero2.clear();
      resultado = '';
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora basica'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: numero1,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Numero 1',
                  border: OutlineInputBorder()
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: numero2,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Numero 2',
                  border: OutlineInputBorder()
              ),
            ),
            SizedBox(height: 20,),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                    onPressed: sumar,
                    child: Text('+')
                ),
                ElevatedButton(
                    onPressed: restar,
                    child: Text('-')
                ),
                ElevatedButton(
                    onPressed: multiplicar,
                    child: Text('*')
                ),
                ElevatedButton(
                    onPressed: dividir,
                    child: Text('/')
                ),
              ],
            ),
            SizedBox(height: 20,),
            Text(
              'Resultado:$resultado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: limpiar,
        child: Icon(Icons.clear),
        tooltip: 'limpiar',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}