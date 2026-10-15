import 'package:flutter/material.dart';
import 'pantallas/area_pantallas.dart';

void main() => runApp(Area());

class Area extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Area de un terreno',
      theme: ThemeData(primaryColor: Colors.black),
      home: AreaPantalla(), //llamar a panatlla
    );
  }
}
