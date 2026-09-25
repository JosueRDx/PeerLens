// interfaz para la lectura y generacion de informacion visual qr
abstract class ContratoFuenteDatosQr {
  String codificarDatos(Map<String, dynamic> datos);
  Map<String, dynamic> decodificarDatos(String contenidoVisual);
}
