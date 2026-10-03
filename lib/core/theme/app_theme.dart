import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  // Paleta de colores naranja
  static const Color primaryOrange = Color(0xFFFF6D00); // Naranja principal
  static const Color secondaryOrange = Color(0xFFFFAB40); // Naranja claro / secundario
  static const Color accentOrange = Color(0xFFFF8F00); // Para botones flotantes, FAB
  static const Color backgroundLight = Color(0xFFFFF3E0); // Fondo claro
  static const Color backgroundDark = Color(0xFF3E2723); // Fondo oscuro

  // Tema Claro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryOrange,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryOrange,
      secondary: secondaryOrange,
      background: backgroundLight,
    ),
    fontFamily: AppFonts.primaryFont,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    ),
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(backgroundColor: accentOrange),
  );

  // Tema Oscuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryOrange,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryOrange,
      secondary: secondaryOrange,
      background: backgroundDark,
    ),
    fontFamily: AppFonts.primaryFont,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    ),
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(backgroundColor: accentOrange),
  );
}
