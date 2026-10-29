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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Color(0xFF0B1220),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0B1220),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Color(0xFF162238),
        ),
        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: Color(0xFF162238),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
        ),
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