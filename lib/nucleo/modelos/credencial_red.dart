import 'dart:convert';

// modelo inmutable para almacenar credenciales de conexion inalambrica
class CredencialRed {
  final String nombreRed;
  final String claveRed;
  final DateTime fechaGuardado;

  const CredencialRed({
    required this.nombreRed,
    required this.claveRed,
    required this.fechaGuardado,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombreRed': nombreRed,
      'claveRed': claveRed,
      'fechaGuardado': fechaGuardado.toIso8601String(),
    };
  }

  factory CredencialRed.fromMap(Map<String, dynamic> mapa) {
    return CredencialRed(
      nombreRed: mapa['nombreRed'] as String? ?? '',
      claveRed: mapa['claveRed'] as String? ?? '',
      fechaGuardado: mapa['fechaGuardado'] != null
          ? DateTime.parse(mapa['fechaGuardado'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory CredencialRed.fromJson(String fuente) =>
      CredencialRed.fromMap(jsonDecode(fuente) as Map<String, dynamic>);

  CredencialRed copyWith({
    String? nombreRed,
    String? claveRed,
    DateTime? fechaGuardado,
  }) {
    return CredencialRed(
      nombreRed: nombreRed ?? this.nombreRed,
      claveRed: claveRed ?? this.claveRed,
      fechaGuardado: fechaGuardado ?? this.fechaGuardado,
    );
  }
}
