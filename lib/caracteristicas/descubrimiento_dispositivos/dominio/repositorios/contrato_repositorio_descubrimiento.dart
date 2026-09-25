import '../entidades/nodo_red.dart';

// contrato abstracto para el descubrimiento y anuncio de nodos mdns
abstract class ContratoRepositorioDescubrimiento {
  Stream<List<NodoRed>> get flujoNodosDescubiertos;
  Future<void> registrarServicioLocal(String nombre, int puerto);
  Future<void> iniciarDescubrimiento();
  Future<void> detenerDescubrimiento();
  Future<void> cancelarRegistroServicio();
}
