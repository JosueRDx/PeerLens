import 'package:flutter/material.dart';

// definicion estatica e inmutable de los tokens de color
class ColoresApp {
  ColoresApp._();

  static const Color fondoPrimario = Color(0xFF0F172A);
  static const Color fondoSuperficie = Color(0xFF1E293B);
  static const Color bordeSuperficie = Color(0xFF334155);
  static const Color negroOled = Color(0xFF000000);
  static const Color acentoActivo = Color(0xFF10B981);
  static const Color acentoRed = Color(0xFF38BDF8);
  static const Color acentoAdvertencia = Color(0xFFF59E0B);
  static const Color acentoPeligro = Color(0xFFEF4444);
  static const Color textoPrimario = Color(0xFFF8FAFC);
  static const Color textoSecundario = Color(0xFF94A3B8);
}

// extension de tema para desacoplar colores semanticos personalizados
class ExtensionColoresApp extends ThemeExtension<ExtensionColoresApp> {
  final Color bordeSuperficie;
  final Color negroOled;
  final Color acentoActivo;
  final Color acentoRed;
  final Color acentoAdvertencia;
  final Color acentoPeligro;

  const ExtensionColoresApp._({
    required this.bordeSuperficie,
    required this.negroOled,
    required this.acentoActivo,
    required this.acentoRed,
    required this.acentoAdvertencia,
    required this.acentoPeligro,
  });

  const ExtensionColoresApp.predeterminado()
    : this._(
        bordeSuperficie: ColoresApp.bordeSuperficie,
        negroOled: ColoresApp.negroOled,
        acentoActivo: ColoresApp.acentoActivo,
        acentoRed: ColoresApp.acentoRed,
        acentoAdvertencia: ColoresApp.acentoAdvertencia,
        acentoPeligro: ColoresApp.acentoPeligro,
      );

  @override
  ExtensionColoresApp copyWith({
    Color? bordeSuperficie,
    Color? negroOled,
    Color? acentoActivo,
    Color? acentoRed,
    Color? acentoAdvertencia,
    Color? acentoPeligro,
  }) {
    return ExtensionColoresApp._(
      bordeSuperficie: bordeSuperficie ?? this.bordeSuperficie,
      negroOled: negroOled ?? this.negroOled,
      acentoActivo: acentoActivo ?? this.acentoActivo,
      acentoRed: acentoRed ?? this.acentoRed,
      acentoAdvertencia: acentoAdvertencia ?? this.acentoAdvertencia,
      acentoPeligro: acentoPeligro ?? this.acentoPeligro,
    );
  }

  @override
  ExtensionColoresApp lerp(
    ThemeExtension<ExtensionColoresApp>? other,
    double t,
  ) {
    if (other is! ExtensionColoresApp) {
      return this;
    }
    return ExtensionColoresApp._(
      bordeSuperficie:
          Color.lerp(bordeSuperficie, other.bordeSuperficie, t) ??
          bordeSuperficie,
      negroOled: Color.lerp(negroOled, other.negroOled, t) ?? negroOled,
      acentoActivo:
          Color.lerp(acentoActivo, other.acentoActivo, t) ?? acentoActivo,
      acentoRed: Color.lerp(acentoRed, other.acentoRed, t) ?? acentoRed,
      acentoAdvertencia:
          Color.lerp(acentoAdvertencia, other.acentoAdvertencia, t) ??
          acentoAdvertencia,
      acentoPeligro:
          Color.lerp(acentoPeligro, other.acentoPeligro, t) ?? acentoPeligro,
    );
  }
}
