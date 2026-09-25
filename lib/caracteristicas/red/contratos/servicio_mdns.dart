// modelo inmutable que representa un nodo descubierto mediante mdns
class NodoDescubierto {
  final String nombre;
  final String tipo;
  final String? direccionIp;
  final int? puerto;
  final Map<String, String> atributos;

  const NodoDescubierto({
    required this.nombre,
    required this.tipo,
    this.direccionIp,
    this.puerto,
    this.atributos = const {},
  });
}

// contrato abstracto para la publicacion y exploracion de servicios mdns
abstract class ServicioMdns {
  bool get estaRegistrado;
  bool get estaExplorando;
  Stream<List<NodoDescubierto>> get flujoNodos;

  Future<void> registrarServicio({
    required String nombre,
    required String tipo,
    required int puerto,
  });

  Future<void> desregistrarServicio();

  Future<void> iniciarExploracion({required String tipo});

  Future<void> detenerExploracion();
}
