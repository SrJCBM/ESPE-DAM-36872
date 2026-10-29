import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodel/vendedor_viewmodel.dart';
import 'vista/pantallas/inicio_pantalla.dart';
import 'vista/pantallas/vendedor_pantalla.dart';
import 'vista/pantallas/resultado_pantalla.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => VendedorViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Comisión de ventas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => InicioPantalla(),
        '/vendedor': (context) => VendedorPantalla(),
        '/resultado': (context) => ResultadoPantalla(),
      },
    );
  }
}