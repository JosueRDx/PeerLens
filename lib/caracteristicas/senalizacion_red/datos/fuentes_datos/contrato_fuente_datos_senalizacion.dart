// interfaz para la fuente de datos de senalizacion websocket
abstract class ContratoFuenteDatosSenalizacion {
  Stream<String> get flujoTextoPlano;
  Future<void> emitirMensaje(String datos);
  Future<void> cerrarCanal();
}
