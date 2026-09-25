enum EstadoWifi {
  desconectado,
  conectando,
  conectado,
  puntoAccesoActivo,
  desconocido,
}

// representacion del estado del punto de acceso y conectividad inalambrica
class EstadoPuntoAcceso {
  final EstadoWifi estado;
  final String? ssid;
  final String? direccionIpAsignada;
  final bool esPuntoAccesoHabilitado;

  const EstadoPuntoAcceso({
    required this.estado,
    this.ssid,
    this.direccionIpAsignada,
    required this.esPuntoAccesoHabilitado,
  });
}
