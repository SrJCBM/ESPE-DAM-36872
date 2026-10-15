import 'package:flutter/material.dart';
import 'package:pry003_costo_viaje/pantallas/viaje_estudiantil_pantallas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ViajeEstudiantilPantalla(),
    );
  }
}
