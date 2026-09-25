import 'dart:convert';

// representacion de los datos de emparejamiento entre emisor y receptor
class CredencialEmparejamiento {
  final String identificadorDispositivo;
  final String direccionIp;
  final int puerto;
  final String claveSeguridad;

  const CredencialEmparejamiento({
    required this.identificadorDispositivo,
    required this.direccionIp,
    required this.puerto,
    required this.claveSeguridad,
  });

  String aCadenaSerializada() {
    return jsonEncode({
      'id': identificadorDispositivo,
      'ip': direccionIp,
      'puerto': puerto,
      'clave': claveSeguridad,
    });
  }

  factory CredencialEmparejamiento.desdeCadenaSerializada(String jsonStr) {
    final mapa = jsonDecode(jsonStr) as Map<String, dynamic>;
    return CredencialEmparejamiento(
      identificadorDispositivo: mapa['id'] as String? ?? '',
      direccionIp: mapa['ip'] as String? ?? '',
      puerto: mapa['puerto'] as int? ?? 8080,
      claveSeguridad: mapa['clave'] as String? ?? '',
    );
  }
}
