import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../contratos/gestor_webrtc.dart';
import '../modelos/configuracion_video.dart';

// implementacion del motor webrtc para el nodo emisor con captura de camara nativa
class MotorWebRtcEmisor implements GestorWebRtc {
  // configuracion de conexion para red local sin servidores stun o turn externos
  static const Map<String, dynamic> _configuracionP2p = {
    'iceServers': <Map<String, dynamic>>[],
    'sdpSemantics': 'unified-plan',
  };

  final RTCVideoRenderer _renderizador = RTCVideoRenderer();
  final ConfiguracionVideo configuracion;

  RTCPeerConnection? _conexionP2p;
  MediaStream? _flujoLocal;
  EstadoConexionP2p _estadoActual = EstadoConexionP2p.inicial;

  final StreamController<EstadoConexionP2p> _controladorEstado =
      StreamController<EstadoConexionP2p>.broadcast();
  final StreamController<RTCIceCandidate> _controladorCandidatos =
      StreamController<RTCIceCandidate>.broadcast();

  MotorWebRtcEmisor({
    this.configuracion = const ConfiguracionVideo.altaDefinicion720p(),
  });

  @override
  RTCVideoRenderer get renderizador => _renderizador;

  @override
  EstadoConexionP2p get estadoActual => _estadoActual;

  @override
  Stream<EstadoConexionP2p> get flujoEstado => _controladorEstado.stream;

  @override
  Stream<RTCIceCandidate> get flujoCandidatoIce =>
      _controladorCandidatos.stream;

  // inicializa el renderizador y comienza la captura de video local
  @override
  Future<void> inicializarRenderizador() async {
    await _renderizador.initialize();
  }

  Future<void> iniciarCapturaCamara({bool camaraFrontal = false}) async {
    _actualizarEstado(EstadoConexionP2p.capturando);

    try {
      final restricciones = configuracion.aRestriccionesMedios(
        usarCamaraFrontal: camaraFrontal,
      );

      _flujoLocal = await navigator.mediaDevices.getUserMedia(restricciones);
      _renderizador.srcObject = _flujoLocal;
    } catch (error) {
      _actualizarEstado(EstadoConexionP2p.error);
      rethrow;
    }
  }

  Future<void> prepararConexionP2p() async {
    _actualizarEstado(EstadoConexionP2p.conectando);

    _conexionP2p = await createPeerConnection(_configuracionP2p);

    if (_flujoLocal != null) {
      for (final track in _flujoLocal!.getTracks()) {
        await _conexionP2p!.addTrack(track, _flujoLocal!);
      }
    }

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
    if (_conexionP2p == null) {
      await prepararConexionP2p();
    }

    const restriccionesOferta = {
      'mandatory': {'OfferToReceiveAudio': false, 'OfferToReceiveVideo': false},
      'optional': <Map<String, dynamic>>[],
    };

    final oferta = await _conexionP2p!.createOffer(restriccionesOferta);
    await _conexionP2p!.setLocalDescription(oferta);
    return oferta;
  }

  @override
  Future<RTCSessionDescription> crearRespuesta() async {
    throw UnsupportedError(
      'El nodo emisor solo genera ofertas y procesa respuestas remotas',
    );
  }

  @override
  Future<void> establecerDescripcionRemota(
    RTCSessionDescription descripcion,
  ) async {
    if (_conexionP2p == null) {
      throw StateError('La conexion peer no ha sido inicializada');
    }
    await _conexionP2p!.setRemoteDescription(descripcion);
  }

  @override
  Future<void> agregarCandidatoIce(RTCIceCandidate candidato) async {
    if (_conexionP2p != null) {
      await _conexionP2p!.addCandidate(candidato);
    }
  }

  void alternarSilencioMicrofono() {
    if (_flujoLocal != null) {
      for (final track in _flujoLocal!.getAudioTracks()) {
        track.enabled = !track.enabled;
      }
    }
  }

  void alternarVideo() {
    if (_flujoLocal != null) {
      for (final track in _flujoLocal!.getVideoTracks()) {
        track.enabled = !track.enabled;
      }
    }
  }

  void _actualizarEstado(EstadoConexionP2p nuevoEstado) {
    _estadoActual = nuevoEstado;
    _controladorEstado.add(nuevoEstado);
  }

  @override
  Future<void> liberarRecursos() async {
    _actualizarEstado(EstadoConexionP2p.desconectado);

    if (_flujoLocal != null) {
      for (final track in _flujoLocal!.getTracks()) {
        await track.stop();
      }
      await _flujoLocal!.dispose();
      _flujoLocal = null;
    }

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
