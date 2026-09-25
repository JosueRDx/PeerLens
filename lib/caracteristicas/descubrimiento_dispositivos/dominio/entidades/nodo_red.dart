// representacion de un dispositivo descubierto en la red local
class NodoRed {
  final String identificador;
  final String nombreDispositivo;
  final String direccionIp;
  final int puerto;
  final Map<String, String> atributos;

  const NodoRed({
    required this.identificador,
    required this.nombreDispositivo,
    required this.direccionIp,
    required this.puerto,
    this.atributos = const {},
  });
}
