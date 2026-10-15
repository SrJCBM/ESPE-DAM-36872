import 'package:flutter/material.dart';
import 'pantallas/panel_herramientas.dart';

void main() => runApp(const HerramientasApp());

class HerramientasApp extends StatelessWidget {
  const HerramientasApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Calculadoras',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF276451)),
      scaffoldBackgroundColor: const Color(0xFFF5F7F4),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
    home: const PanelHerramientas(),
  );
}
