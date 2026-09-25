import '../entidades/mensaje_senalizacion.dart';

// contrato abstracto para el canal de senalizacion y negociacion p2p
abstract class ContratoRepositorioSenalizacion {
  Stream<MensajeSenalizacion> get flujoMensajes;
  Future<void> iniciarServidorLocal(int puerto);
  Future<void> conectarAServidorRemoto(String direccionUri);
  Future<void> enviarMensaje(MensajeSenalizacion mensaje);
  Future<void> desconectar();
}
