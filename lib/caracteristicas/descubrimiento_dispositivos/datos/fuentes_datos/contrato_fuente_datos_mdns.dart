// interfaz para la integracion de bajo nivel con el servicio de resolucion mdns
abstract class ContratoFuenteDatosMdns {
  Future<void> publicarServicio(String nombre, String tipo, int puerto);
  Stream<dynamic> iniciarEscaneoServicios(String tipo);
  Future<void> detenerEscaneoServicios();
  Future<void> darDeBajaServicio();
}
