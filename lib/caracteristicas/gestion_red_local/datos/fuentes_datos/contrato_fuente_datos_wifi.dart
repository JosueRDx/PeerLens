// interfaz para la manipulacion directa del hardware wifi en android
abstract class ContratoFuenteDatosWifi {
  Future<bool> configurarPuntoAcceso(String ssid, String clave);
  Future<bool> apagarPuntoAcceso();
  Future<bool> asociarRed(String ssid, String clave);
  Future<String?> consultarIpLocal();
}
