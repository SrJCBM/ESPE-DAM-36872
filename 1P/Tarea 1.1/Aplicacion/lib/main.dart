import 'package:flutter/material.dart';
import 'pantallas/menu_pantalla.dart';
import 'pantallas/ventas_pantalla.dart';
import 'pantallas/pagos_pantalla.dart';
import 'pantallas/tiendas_pantalla.dart';
import 'pantallas/sueldos_pantalla.dart';
import 'pantallas/inversion_pantalla.dart';

void main() => runApp(const EjerciciosApp());

class EjerciciosApp extends StatelessWidget {
  const EjerciciosApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Ejercicios NRC 36872',
    theme: ThemeData(colorSchemeSeed: Colors.teal),
    initialRoute: '/',
    routes: {
      '/': (_) => const MenuPantalla(),
      '/ventas': (_) => const VentasPantalla(),
      '/pagos': (_) => const PagosPantalla(),
      '/tiendas': (_) => const TiendasPantalla(),
      '/sueldos': (_) => const SueldosPantalla(),
      '/inversion': (_) => const InversionPantalla(),
    },
  );
}
