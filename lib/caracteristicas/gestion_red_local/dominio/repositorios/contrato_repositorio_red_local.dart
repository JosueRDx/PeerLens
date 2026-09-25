import '../entidades/estado_punto_acceso.dart';

// contrato abstracto para la gestion de red local e infraestructura inalambrica
abstract class ContratoRepositorioRedLocal {
  Future<EstadoPuntoAcceso> obtenerEstadoActual();
  Future<bool> habilitarPuntoAcceso(String ssid, String contrasena);
  Future<bool> deshabilitarPuntoAcceso();
  Future<bool> conectarARedWifi(String ssid, String contrasena);
  Future<String?> obtenerDireccionIpLocal();
}
