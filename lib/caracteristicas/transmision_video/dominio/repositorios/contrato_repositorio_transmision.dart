import '../entidades/sesion_transmision.dart';

// contrato abstracto para la orquestacion de transmision de video y audio
abstract class ContratoRepositorioTransmision {
  Stream<SesionTransmision> get flujoSesion;
  Future<void> inicializarDispositivosLocales();
  Future<void> alternarCamara();
  Future<void> alternarMicrofono();
  Future<void> finalizarTransmision();
  void liberarRecursos();
}
