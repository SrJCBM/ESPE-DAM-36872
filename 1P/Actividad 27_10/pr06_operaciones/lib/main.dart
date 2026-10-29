import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/operario_viewmodel.dart';
import 'vista/pantallas/operario_pantalla.dart';
import 'vista/pantallas/resultado_pantalla.dart';

void main() {

  runApp(

    ChangeNotifierProvider(
      create: (_) =>
          OperarioViewModel(),

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner:
      false,

      initialRoute: '/',

      routes: {

        '/': (context) =>
         OperarioPantalla(),

        '/resultado': (context) =>
        const ResultadoPantalla(),
      },
    );
  }
}