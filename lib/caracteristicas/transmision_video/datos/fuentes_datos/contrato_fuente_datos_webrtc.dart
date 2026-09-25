// interfaz para la interaccion de bajo nivel con el motor webrtc
abstract class ContratoFuenteDatosWebRtc {
  Future<void> configurarConexionPuntoAPunto();
  Future<String> crearOfertaSdp();
  Future<String> crearRespuestaSdp();
  Future<void> establecerDescripcionRemota(String sdp, String tipo);
  Future<void> agregarCandidatoIce(
    String candidato,
    String sdpMid,
    int sdpMLineIndex,
  );
  Future<void> cerrarConexion();
}
