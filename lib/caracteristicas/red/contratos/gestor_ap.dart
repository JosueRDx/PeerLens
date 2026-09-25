// contrato abstracto para la gestion de punto de acceso local y conectividad wifi
abstract class GestorAp {
  bool get esPlataformaSoportada;
  Future<bool> estaPuntoAccesoHabilitado();
  Future<bool> habilitarPuntoAcceso({
    required String ssid,
    required String clave,
  });
  Future<bool> deshabilitarPuntoAcceso();
  Future<bool> conectarARedLan({required String ssid, required String clave});
  Future<bool> desconectarDeRedLan();
  Future<String?> obtenerDireccionIpLocal();
  Future<String?> obtenerSsidActual();
  Future<List<String>> escanearRedesDisponibles();
}
