import 'dart:convert';

enum TipoEstadoNodo { modoAp, conectandoLan, enLineaLan, error }

// modelo inmutable para representar el estado operativo del nodo en la red
class EstadoNodo {
  final TipoEstadoNodo estado;
  final String? direccionIp;
  final String? mensajeDetalle;
  final DateTime actualizadoEn;

  const EstadoNodo({
    required this.estado,
    this.direccionIp,
    this.mensajeDetalle,
    required this.actualizadoEn,
  });

  Map<String, dynamic> toMap() {
    return {
      'estado': estado.name,
      'direccionIp': direccionIp,
      'mensajeDetalle': mensajeDetalle,
      'actualizadoEn': actualizadoEn.toIso8601String(),
    };
  }

  factory EstadoNodo.fromMap(Map<String, dynamic> mapa) {
    return EstadoNodo(
      estado: TipoEstadoNodo.values.firstWhere(
        (elemento) => elemento.name == mapa['estado'],
        orElse: () => TipoEstadoNodo.error,
      ),
      direccionIp: mapa['direccionIp'] as String?,
      mensajeDetalle: mapa['mensajeDetalle'] as String?,
      actualizadoEn: mapa['actualizadoEn'] != null
          ? DateTime.parse(mapa['actualizadoEn'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory EstadoNodo.fromJson(String fuente) =>
      EstadoNodo.fromMap(jsonDecode(fuente) as Map<String, dynamic>);

  EstadoNodo copyWith({
    TipoEstadoNodo? estado,
    String? direccionIp,
    String? mensajeDetalle,
    DateTime? actualizadoEn,
  }) {
    return EstadoNodo(
      estado: estado ?? this.estado,
      direccionIp: direccionIp ?? this.direccionIp,
      mensajeDetalle: mensajeDetalle ?? this.mensajeDetalle,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }
}
