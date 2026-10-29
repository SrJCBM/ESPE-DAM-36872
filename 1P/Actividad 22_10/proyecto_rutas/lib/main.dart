import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'views/resultado_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edad',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeView(),
        '/resultado': (context) => const ResultadoView(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}
