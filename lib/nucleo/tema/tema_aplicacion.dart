import 'package:flutter/material.dart';
import 'colores_tema.dart';

// configuracion del tema visual de la aplicacion
abstract class TemaAplicacion {
  static ThemeData get temaOscuro {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ColoresTema.fondoOscuro,
      colorScheme: const ColorScheme.dark(
        primary: ColoresTema.secundario,
        secondary: ColoresTema.acento,
        surface: ColoresTema.superficieOscura,
        error: ColoresTema.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresTema.primario,
        foregroundColor: ColoresTema.textoClaro,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
