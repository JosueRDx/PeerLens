import 'package:flutter/material.dart';
import 'colores.dart';

// configuracion del tema visual oscuro de la aplicacion
class TemaApp {
  TemaApp._();

  static ThemeData get temaOscuro {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ColoresApp.fondoPrimario,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: ColoresApp.acentoRed,
        onPrimary: ColoresApp.fondoPrimario,
        secondary: ColoresApp.acentoActivo,
        onSecondary: ColoresApp.fondoPrimario,
        error: ColoresApp.acentoPeligro,
        onError: ColoresApp.textoPrimario,
        surface: ColoresApp.fondoSuperficie,
        onSurface: ColoresApp.textoPrimario,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.fondoPrimario,
        foregroundColor: ColoresApp.textoPrimario,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: ColoresApp.fondoSuperficie,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ColoresApp.bordeSuperficie, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.acentoRed,
          foregroundColor: ColoresApp.fondoPrimario,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColoresApp.textoPrimario,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: ColoresApp.bordeSuperficie, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: ColoresApp.textoPrimario,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: ColoresApp.textoPrimario,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: ColoresApp.textoPrimario,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: ColoresApp.textoPrimario),
        bodyMedium: TextStyle(color: ColoresApp.textoSecundario),
        labelLarge: TextStyle(
          color: ColoresApp.textoPrimario,
          fontWeight: FontWeight.w500,
        ),
      ),
      extensions: const [ExtensionColoresApp.predeterminado()],
    );
  }
}
