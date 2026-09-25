enum EstadoConexionP2p {
  inicial,
  capturando,
  conectando,
  transmitiendo,
  desconectado,
  error,
}

// modelo inmutable para parametros tecnicos de captura y resolucion de video
class ConfiguracionVideo {
  final int ancho;
  final int alto;
  final int cuadrosPorSegundo;
  final bool audioHabilitado;

  const ConfiguracionVideo({
    required this.ancho,
    required this.alto,
    required this.cuadrosPorSegundo,
    this.audioHabilitado = false,
  });

  const ConfiguracionVideo.altaDefinicion720p({bool audio = false})
    : ancho = 1280,
      alto = 720,
      cuadrosPorSegundo = 30,
      audioHabilitado = audio;

  const ConfiguracionVideo.altaDefinicion1080p({bool audio = false})
    : ancho = 1920,
      alto = 1080,
      cuadrosPorSegundo = 30,
      audioHabilitado = audio;

  Map<String, dynamic> aRestriccionesMedios({bool usarCamaraFrontal = false}) {
    return {
      'audio': audioHabilitado,
      'video': {
        'mandatory': {
          'minWidth': '$ancho',
          'minHeight': '$alto',
          'minFrameRate': '$cuadrosPorSegundo',
        },
        'facingMode': usarCamaraFrontal ? 'user' : 'environment',
        'optional': <Map<String, dynamic>>[],
      },
    };
  }
}
