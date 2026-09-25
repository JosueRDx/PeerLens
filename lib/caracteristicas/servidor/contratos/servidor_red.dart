// contrato abstracto para la gestion del ciclo de vida del servidor de red local
abstract class ServidorRed {
  bool get estaActivo;
  int? get puertoActivo;
  Stream<String> get flujoEventos;
  Future<void> iniciar({int puerto = 8080});
  Future<void> detener();
}
