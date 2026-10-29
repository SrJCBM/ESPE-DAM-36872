import 'package:flutter/material.dart';
import 'vista/pantallas/formulario_numero.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/numeros',
      routes: {'/numeros': (context) => NumerosPantalla()},
    );
  }
}
