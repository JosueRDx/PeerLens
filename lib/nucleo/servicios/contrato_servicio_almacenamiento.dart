// contrato abstracto para la persistencia de configuraciones
abstract class ContratoServicioAlmacenamiento {
  Future<bool> guardarCadena(String clave, String valor);
  Future<String?> obtenerCadena(String clave);
  Future<bool> guardarEntero(String clave, int valor);
  Future<int?> obtenerEntero(String clave);
  Future<bool> guardarBooleano(String clave, bool valor);
  Future<bool?> obtenerBooleano(String clave);
  Future<bool> eliminar(String clave);
  Future<bool> limpiar();
}
