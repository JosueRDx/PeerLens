enum TipoMensajeSenalizacion { oferta, respuesta, candidatoIce, desconexion }

// representacion de un mensaje de senalizacion en el protocolo de comunicacion
class MensajeSenalizacion {
  final TipoMensajeSenalizacion tipo;
  final String remitente;
  final Map<String, dynamic> cargaUtil;

  const MensajeSenalizacion({
    required this.tipo,
    required this.remitente,
    required this.cargaUtil,
  });

  Map<String, dynamic> aMapa() {
    return {'tipo': tipo.name, 'remitente': remitente, 'cargaUtil': cargaUtil};
  }

  factory MensajeSenalizacion.desdeMapa(Map<String, dynamic> mapa) {
    return MensajeSenalizacion(
      tipo: TipoMensajeSenalizacion.values.firstWhere(
        (elemento) => elemento.name == mapa['tipo'],
        orElse: () => TipoMensajeSenalizacion.desconexion,
      ),
      remitente: mapa['remitente'] as String? ?? '',
      cargaUtil: Map<String, dynamic>.from(mapa['cargaUtil'] as Map? ?? {}),
    );
  }
}
