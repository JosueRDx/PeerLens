enum EstadoSesionTransmision { desconectado, conectando, conectado, fallido }

// entidad que representa el estado de una sesion de transmision de video
class SesionTransmision {
  final String identificadorRemoto;
  final EstadoSesionTransmision estado;
  final bool videoActivo;
  final bool audioActivo;

  const SesionTransmision({
    required this.identificadorRemoto,
    required this.estado,
    required this.videoActivo,
    required this.audioActivo,
  });

  SesionTransmision copiarCon({
    String? identificadorRemoto,
    EstadoSesionTransmision? estado,
    bool? videoActivo,
    bool? audioActivo,
  }) {
    return SesionTransmision(
      identificadorRemoto: identificadorRemoto ?? this.identificadorRemoto,
      estado: estado ?? this.estado,
      videoActivo: videoActivo ?? this.videoActivo,
      audioActivo: audioActivo ?? this.audioActivo,
    );
  }
}
