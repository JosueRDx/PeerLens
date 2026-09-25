import '../modelos/credencial_red.dart';

// contrato abstracto para la persistencia local de configuraciones de red
abstract class RepositorioAlmacenamiento {
  Future<void> guardarCredencialRed(CredencialRed credencial);
  Future<CredencialRed?> obtenerCredencialRed();
  Future<void> eliminarCredencialRed();
  Future<void> guardarRolPreferido(String rol);
  Future<String?> obtenerRolPreferido();
  Future<void> limpiarTodo();
}
