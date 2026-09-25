import 'package:shared_preferences/shared_preferences.dart';
import '../errores/excepciones.dart';
import '../modelos/credencial_red.dart';
import 'repositorio_almacenamiento.dart';

// implementacion de persistencia segura mediante preferencias compartidas
class ServicioAlmacenamientoLocal implements RepositorioAlmacenamiento {
  static const String _claveCredencialRed = 'peerlens_credencial_red';
  static const String _claveRolPreferido = 'peerlens_rol_preferido';

  final SharedPreferences _preferencias;

  ServicioAlmacenamientoLocal(this._preferencias);

  static Future<ServicioAlmacenamientoLocal> crear() async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      return ServicioAlmacenamientoLocal(preferencias);
    } catch (error) {
      throw ExcepcionPersistenciaLocal(
        'Fallo al inicializar almacenamiento local: $error',
      );
    }
  }

  @override
  Future<void> guardarCredencialRed(CredencialRed credencial) async {
    try {
      final exito = await _preferencias.setString(
        _claveCredencialRed,
        credencial.toJson(),
      );
      if (!exito) {
        throw const ExcepcionPersistenciaLocal(
          'No se pudo persistir la credencial de red',
        );
      }
    } catch (error) {
      if (error is ExcepcionPersistenciaLocal) rethrow;
      throw ExcepcionPersistenciaLocal(
        'Error al guardar credencial de red: $error',
      );
    }
  }

  @override
  Future<CredencialRed?> obtenerCredencialRed() async {
    try {
      final jsonSerializado = _preferencias.getString(_claveCredencialRed);
      if (jsonSerializado == null || jsonSerializado.isEmpty) {
        return null;
      }
      return CredencialRed.fromJson(jsonSerializado);
    } catch (error) {
      throw ExcepcionPersistenciaLocal(
        'Error al deserializar credencial de red: $error',
      );
    }
  }

  @override
  Future<void> eliminarCredencialRed() async {
    try {
      await _preferencias.remove(_claveCredencialRed);
    } catch (error) {
      throw ExcepcionPersistenciaLocal(
        'Error al eliminar credencial de red: $error',
      );
    }
  }

  @override
  Future<void> guardarRolPreferido(String rol) async {
    try {
      final exito = await _preferencias.setString(_claveRolPreferido, rol);
      if (!exito) {
        throw const ExcepcionPersistenciaLocal(
          'No se pudo persistir el rol preferido',
        );
      }
    } catch (error) {
      if (error is ExcepcionPersistenciaLocal) rethrow;
      throw ExcepcionPersistenciaLocal(
        'Error al guardar rol preferido: $error',
      );
    }
  }

  @override
  Future<String?> obtenerRolPreferido() async {
    try {
      return _preferencias.getString(_claveRolPreferido);
    } catch (error) {
      throw ExcepcionPersistenciaLocal(
        'Error al obtener rol preferido: $error',
      );
    }
  }

  @override
  Future<void> limpiarTodo() async {
    try {
      await _preferencias.clear();
    } catch (error) {
      throw ExcepcionPersistenciaLocal(
        'Error al limpiar almacenamiento local: $error',
      );
    }
  }
}
