import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../contratos/gestor_webrtc.dart';
import '../modelos/configuracion_video.dart';

// implementacion del motor webrtc para el nodo receptor visor de streaming
class MotorWebRtcReceptor implements GestorWebRtc {
  // configuracion de conexion para red local sin servidores stun o turn externos
  static const Map<String, dynamic> _configuracionP2p = {
    'iceServers': <Map<String, dynamic>>[],
    'sdpSemantics': 'unified-plan',
  };

  final RTCVideoRenderer _renderizador = RTCVideoRenderer();
  RTCPeerConnection? _conexionP2p;
  EstadoConexionP2p _estadoActual = EstadoConexionP2p.inicial;

  final StreamController<EstadoConexionP2p> _controladorEstado =
      StreamController<EstadoConexionP2p>.broadcast();
  final StreamController<RTCIceCandidate> _controladorCandidatos =
      StreamController<RTCIceCandidate>.broadcast();

  @override
  RTCVideoRenderer get renderizador => _renderizador;

  @override
  EstadoConexionP2p get estadoActual => _estadoActual;

  @override
  Stream<EstadoConexionP2p> get flujoEstado => _controladorEstado.stream;

  @override
  Stream<RTCIceCandidate> get flujoCandidatoIce =>
      _controladorCandidatos.stream;

  @override
  Future<void> inicializarRenderizador() async {
    await _renderizador.initialize();
  }

  Future<void> prepararConexionP2p() async {
    _actualizarEstado(EstadoConexionP2p.conectando);

    _conexionP2p = await createPeerConnection(_configuracionP2p);

    // enlaza el flujo de video y audio remoto al renderizador visual
    _conexionP2p!.onTrack = (RTCTrackEvent evento) {
      if (evento.streams.isNotEmpty) {
        _renderizador.srcObject = evento.streams[0];
        _actualizarEstado(EstadoConexionP2p.transmitiendo);
      }
    };

    _conexionP2p!.onIceCandidate = (RTCIceCandidate candidato) {
      _controladorCandidatos.add(candidato);
    };

    _conexionP2p!.onConnectionState = (RTCPeerConnectionState estado) {
      switch (estado) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _actualizarEstado(EstadoConexionP2p.transmitiendo);
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          _actualizarEstado(EstadoConexionP2p.desconectado);
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          _actualizarEstado(EstadoConexionP2p.error);
        default:
          break;
      }
    };
  }

  @override
  Future<RTCSessionDescription> crearOferta() async {
    throw UnsupportedError(
      'El nodo receptor solo procesa ofertas y genera respuestas SDP',
    );
  }

  @override
  Future<void> establecerDescripcionRemota(
    RTCSessionDescription descripcion,
  ) async {
    if (_conexionP2p == null) {
      await prepararConexionP2p();
    }
    await _conexionP2p!.setRemoteDescription(descripcion);
  }

  @override
  Future<RTCSessionDescription> crearRespuesta() async {
    if (_conexionP2p == null) {
      throw StateError('La conexion peer no ha sido inicializada');
    }

    const restriccionesRespuesta = {
      'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
      'optional': <Map<String, dynamic>>[],
    };

    final respuesta = await _conexionP2p!.createAnswer(restriccionesRespuesta);
    await _conexionP2p!.setLocalDescription(respuesta);
    return respuesta;
  }

  @override
  Future<void> agregarCandidatoIce(RTCIceCandidate candidato) async {
    if (_conexionP2p != null) {
      await _conexionP2p!.addCandidate(candidato);
    }
  }

  void _actualizarEstado(EstadoConexionP2p nuevoEstado) {
    _estadoActual = nuevoEstado;
    _controladorEstado.add(nuevoEstado);
  }

  @override
  Future<void> liberarRecursos() async {
    _actualizarEstado(EstadoConexionP2p.desconectado);

    if (_conexionP2p != null) {
      await _conexionP2p!.close();
      await _conexionP2p!.dispose();
      _conexionP2p = null;
    }

    await _renderizador.dispose();
    await _controladorEstado.close();
    await _controladorCandidatos.close();
  }
}
