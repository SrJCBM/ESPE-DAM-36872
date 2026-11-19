import 'package:flutter/material.dart';

ThemeData temaAcademico(Brightness brillo) {
  final colores = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6442D6),
    brightness: brillo,
  );
  return ThemeData(
    colorScheme: colores,
    useMaterial3: true,
    scaffoldBackgroundColor: colores.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: colores.surface,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colores.surfaceContainer,
      indicatorColor: colores.primaryContainer,
      height: 72,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colores.surfaceContainerLow,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colores.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(48, 52)),
    ),
  );
}
