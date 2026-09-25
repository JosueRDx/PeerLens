import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../modelos/configuracion_video.dart';

// contrato abstracto para la orquestacion del motor de comunicacion webrtc
abstract class GestorWebRtc {
  RTCVideoRenderer get renderizador;
  EstadoConexionP2p get estadoActual;
  Stream<EstadoConexionP2p> get flujoEstado;
  Stream<RTCIceCandidate> get flujoCandidatoIce;

  Future<void> inicializarRenderizador();
  Future<RTCSessionDescription> crearOferta();
  Future<RTCSessionDescription> crearRespuesta();
  Future<void> establecerDescripcionRemota(RTCSessionDescription descripcion);
  Future<void> agregarCandidatoIce(RTCIceCandidate candidato);
  Future<void> liberarRecursos();
}
