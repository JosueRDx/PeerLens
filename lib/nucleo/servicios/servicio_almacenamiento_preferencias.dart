import 'package:shared_preferences/shared_preferences.dart';
import 'contrato_servicio_almacenamiento.dart';

// implementacion concreta de persistencia local usando shared preferences
class ServicioAlmacenamientoPreferencias
    implements ContratoServicioAlmacenamiento {
  final SharedPreferences _preferencias;

  ServicioAlmacenamientoPreferencias(this._preferencias);

  static Future<ServicioAlmacenamientoPreferencias> crear() async {
    final preferencias = await SharedPreferences.getInstance();
    return ServicioAlmacenamientoPreferencias(preferencias);
  }

  @override
  Future<bool> guardarCadena(String clave, String valor) async {
    return _preferencias.setString(clave, valor);
  }

  @override
  Future<String?> obtenerCadena(String clave) async {
    return _preferencias.getString(clave);
  }

  @override
  Future<bool> guardarEntero(String clave, int valor) async {
    return _preferencias.setInt(clave, valor);
  }

  @override
  Future<int?> obtenerEntero(String clave) async {
    return _preferencias.getInt(clave);
  }

  @override
  Future<bool> guardarBooleano(String clave, bool valor) async {
    return _preferencias.setBool(clave, valor);
  }

  @override
  Future<bool?> obtenerBooleano(String clave) async {
    return _preferencias.getBool(clave);
  }

  @override
  Future<bool> eliminar(String clave) async {
    return _preferencias.remove(clave);
  }

  @override
  Future<bool> limpiar() async {
    return _preferencias.clear();
  }
}
