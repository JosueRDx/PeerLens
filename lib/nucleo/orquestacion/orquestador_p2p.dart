import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../caracteristicas/red/contratos/gestor_ap.dart';
import '../../caracteristicas/red/contratos/servicio_mdns.dart';
import '../../caracteristicas/red/implementacion/gestor_ap_android.dart';
import '../../caracteristicas/red/implementacion/servicio_mdns_nsd.dart';
import '../../caracteristicas/servidor/contratos/servidor_red.dart';
import '../../caracteristicas/servidor/controladores/controlador_aprovisionamiento.dart';
import '../../caracteristicas/servidor/controladores/controlador_senalizacion.dart';
import '../../caracteristicas/servidor/implementacion/servidor_shelf.dart';
import '../../caracteristicas/transmision/contratos/gestor_webrtc.dart';
import '../../caracteristicas/transmision/implementacion/motor_webrtc_emisor.dart';
import '../almacenamiento/repositorio_almacenamiento.dart';
import '../almacenamiento/servicio_almacenamiento_local.dart';
import '../modelos/credencial_red.dart';
import '../modelos/estado_nodo.dart';

// orquestador central del ciclo de vida p2p con maquina de estados y resiliencia
class OrquestadorP2p {
  final GestorAp _gestorAp;
  final ServidorRed _servidorRed;
  final ServicioMdns _servicioMdns;
  final GestorWebRtc _motorEmisor;
  final RepositorioAlmacenamiento? _almacenamientoInyectado;
  RepositorioAlmacenamiento? _almacenamiento;

  final StreamController<EstadoNodo> _controladorEstado =
      StreamController<EstadoNodo>.broadcast();

  EstadoNodo _estadoActual = EstadoNodo(
    estado: TipoEstadoNodo.modoAp,
    actualizadoEn: DateTime.now(),
  );

  Timer? _temporizadorReconexion;
  Timer? _temporizadorMonitoreo;
  StreamSubscription? _suscripcionEventosSenalizacion;
  StreamSubscription? _suscripcionMensajesSenalizacion;
  StreamSubscription? _suscripcionCandidatosEmisor;

  String _ssidAp = 'PeerLens_AP';
  String _claveAp = '12345678';
  bool _estaIniciado = false;

  OrquestadorP2p({
    GestorAp? gestorAp,
    ServidorRed? servidorRed,
    ServicioMdns? servicioMdns,
    GestorWebRtc? motorEmisor,
    RepositorioAlmacenamiento? almacenamiento,
  }) : _gestorAp = gestorAp ?? GestorApAndroid(),
       _servicioMdns = servicioMdns ?? ServicioMdnsNsd(),
       _motorEmisor = motorEmisor ?? MotorWebRtcEmisor(),
       _almacenamientoInyectado = almacenamiento,
       _servidorRed =
           servidorRed ??
           ServidorShelf(
             controladorAprovisionamiento: ControladorAprovisionamiento(),
             controladorSenalizacion: ControladorSenalizacion(),
           );

  EstadoNodo get estadoActual => _estadoActual;
  Stream<EstadoNodo> get flujoEstado => _controladorEstado.stream;
  String get ssidAp => _ssidAp;
  String get claveAp => _claveAp;
  bool get estaIniciado => _estaIniciado;
  GestorWebRtc get motorEmisor => _motorEmisor;
  ServidorRed get servidorRed => _servidorRed;

  String get urlServidor {
    final ip = _estadoActual.direccionIp ?? '192.168.49.1';
    return 'http://$ip:8080';
  }

  Future<void> iniciar() async {
    if (_estaIniciado) return;
    _estaIniciado = true;

    _almacenamiento =
        _almacenamientoInyectado ?? await ServicioAlmacenamientoLocal.crear();

    try {
      await _motorEmisor.inicializarRenderizador();
      if (_motorEmisor is MotorWebRtcEmisor) {
        await _motorEmisor.iniciarCapturaCamara();
      }
    } catch (_) {}

    final credencialGuardada = await _almacenamiento!.obtenerCredencialRed();

    if (credencialGuardada != null) {
      await _intentarConexionLan(credencialGuardada);
    } else {
      // deteccion de conexion existente en red wifi local
      final ipExistente = await _gestorAp.obtenerDireccionIpLocal();
      if (ipExistente != null &&
          ipExistente != '127.0.0.1' &&
          ipExistente != '192.168.49.1') {
        await _iniciarServiciosRed(ipExistente);
        _actualizarEstado(
          TipoEstadoNodo.enLineaLan,
          'En linea en red LAN existente',
          ip: ipExistente,
        );
      } else {
        await activarModoAp();
      }
    }
  }

  Future<void> _intentarConexionLan(CredencialRed credencial) async {
    _cancelarTemporizadores();
    _actualizarEstado(TipoEstadoNodo.conectandoLan, 'Conectando a red router');

    final conectado = await _gestorAp.conectarARedLan(
      ssid: credencial.nombreRed,
      clave: credencial.claveRed,
    );

    if (conectado) {
      final ip = await _gestorAp.obtenerDireccionIpLocal() ?? '127.0.0.1';
      await _iniciarServiciosRed(ip);
      _actualizarEstado(
        TipoEstadoNodo.enLineaLan,
        'En linea en red LAN',
        ip: ip,
      );
      _iniciarMonitoreoConexionLan(credencial);
    } else {
      // si falla la conexion inicial se revierte a modo ap local
      await activarModoAp();
    }
  }

  void _iniciarMonitoreoConexionLan(CredencialRed credencial) {
    _temporizadorMonitoreo?.cancel();
    _temporizadorMonitoreo = Timer.periodic(const Duration(seconds: 5), (
      _,
    ) async {
      final ipActual = await _gestorAp.obtenerDireccionIpLocal();
      if (ipActual == null &&
          _estadoActual.estado == TipoEstadoNodo.enLineaLan) {
        _iniciarReconexionAutomatica(credencial);
      }
    });
  }

  // inicia periodo de gracia de 30 segundos antes de revertir a modo ap
  void _iniciarReconexionAutomatica(CredencialRed credencial) {
    _temporizadorMonitoreo?.cancel();
    _actualizarEstado(
      TipoEstadoNodo.conectandoLan,
      'Conexion LAN perdida reintentando por 30 segundos',
    );

    var segundosTranscurridos = 0;

    _temporizadorReconexion?.cancel();
    _temporizadorReconexion = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      segundosTranscurridos += 3;

      final reintentar = await _gestorAp.conectarARedLan(
        ssid: credencial.nombreRed,
        clave: credencial.claveRed,
      );

      if (reintentar) {
        final nuevaIp = await _gestorAp.obtenerDireccionIpLocal();
        if (nuevaIp != null) {
          timer.cancel();
          _actualizarEstado(
            TipoEstadoNodo.enLineaLan,
            'Reconexion LAN exitosa',
            ip: nuevaIp,
          );
          _iniciarMonitoreoConexionLan(credencial);
          return;
        }
      }

      // al cumplirse 30 segundos se activa automaticamente el punto de acceso
      if (segundosTranscurridos >= 30) {
        timer.cancel();
        await activarModoAp();
      }
    });
  }

  Future<void> activarModoAp() async {
    _cancelarTemporizadores();
    _ssidAp = GestorApAndroid.generarSsidAleatorio();
    _claveAp = GestorApAndroid.generarClaveAleatoria();

    await _gestorAp.desconectarDeRedLan();
    await _gestorAp.habilitarPuntoAcceso(ssid: _ssidAp, clave: _claveAp);

    const ipAp = '192.168.49.1';
    await _iniciarServiciosRed(ipAp);

    _actualizarEstado(
      TipoEstadoNodo.modoAp,
      'Punto de acceso local activo',
      ip: ipAp,
    );
  }

  Future<void> _iniciarServiciosRed(String ip) async {
    try {
      if (!_servidorRed.estaActivo) {
        await _servidorRed.iniciar(puerto: 8080);
      }
    } catch (_) {}

    _configurarSenalizacionWebrtc();

    try {
      if (_servicioMdns.estaRegistrado) {
        await _servicioMdns.desregistrarServicio();
      }
      await _servicioMdns.registrarServicio(
        nombre: 'camera-device',
        tipo: '_camera-p2p._tcp',
        puerto: 8080,
      );
    } catch (_) {}
  }

  // coordina el intercambio de senales webrtc sobre el canal websocket del servidor
  void _configurarSenalizacionWebrtc() {
    if (_servidorRed is! ServidorShelf) return;
    final servidor = _servidorRed;
    final senalizacion = servidor.controladorSenalizacion;

    _suscripcionEventosSenalizacion?.cancel();
    _suscripcionEventosSenalizacion = senalizacion.flujoEventos.listen((
      evento,
    ) async {
      if (evento == 'Cliente websocket conectado') {
        try {
          final oferta = await _motorEmisor.crearOferta();
          senalizacion.emitirDesdeServidor(
            jsonEncode({'tipo': 'oferta', 'sdp': oferta.sdp}),
          );
        } catch (_) {}
      }
    });

    _suscripcionMensajesSenalizacion?.cancel();
    _suscripcionMensajesSenalizacion = senalizacion.flujoMensajes.listen((
      mensaje,
    ) async {
      try {
        final mapa = jsonDecode(mensaje) as Map<String, dynamic>;
        final tipo = mapa['tipo'];

        if (tipo == 'respuesta') {
          final sdp = mapa['sdp'] as String;
          await _motorEmisor.establecerDescripcionRemota(
            RTCSessionDescription(sdp, 'answer'),
          );
        } else if (tipo == 'candidato') {
          final candidato = mapa['candidato'] ?? mapa['candidate'];
          final sdpMid = mapa['sdpMid']?.toString();
          final sdpMLineIndex = mapa['sdpMLineIndex'];
          if (candidato != null) {
            await _motorEmisor.agregarCandidatoIce(
              RTCIceCandidate(
                candidato.toString(),
                sdpMid,
                sdpMLineIndex is int
                    ? sdpMLineIndex
                    : int.tryParse(sdpMLineIndex.toString()),
              ),
            );
          }
        } else if (tipo == 'ping') {
          senalizacion.emitirDesdeServidor(
            jsonEncode({'tipo': 'pong', 'tiempo': mapa['tiempo']}),
          );
        }
      } catch (_) {}
    });

    _suscripcionCandidatosEmisor?.cancel();
    _suscripcionCandidatosEmisor = _motorEmisor.flujoCandidatoIce.listen((
      candidato,
    ) {
      senalizacion.emitirDesdeServidor(
        jsonEncode({
          'tipo': 'candidato',
          'candidato': candidato.candidate,
          'sdpMid': candidato.sdpMid,
          'sdpMLineIndex': candidato.sdpMLineIndex,
        }),
      );
    });
  }

  Future<void> aprovisionarNuevaRed(String ssid, String clave) async {
    final credencial = CredencialRed(
      nombreRed: ssid,
      claveRed: clave,
      fechaGuardado: DateTime.now(),
    );

    if (_almacenamiento != null) {
      await _almacenamiento!.guardarCredencialRed(credencial);
    }

    await _intentarConexionLan(credencial);
  }

  Future<void> olvidarRedYRetornarAp() async {
    if (_almacenamiento != null) {
      await _almacenamiento!.eliminarCredencialRed();
    }
    await activarModoAp();
  }

  void _cancelarTemporizadores() {
    _temporizadorReconexion?.cancel();
    _temporizadorReconexion = null;
    _temporizadorMonitoreo?.cancel();
    _temporizadorMonitoreo = null;
  }

  void _actualizarEstado(TipoEstadoNodo estado, String detalle, {String? ip}) {
    _estadoActual = EstadoNodo(
      estado: estado,
      direccionIp: ip ?? _estadoActual.direccionIp,
      mensajeDetalle: detalle,
      actualizadoEn: DateTime.now(),
    );
    _controladorEstado.add(_estadoActual);
  }

  Future<void> liberarRecursos() async {
    _cancelarTemporizadores();
    _suscripcionEventosSenalizacion?.cancel();
    _suscripcionMensajesSenalizacion?.cancel();
    _suscripcionCandidatosEmisor?.cancel();
    _estaIniciado = false;
    await _servicioMdns.desregistrarServicio();
    await _servidorRed.detener();
    await _motorEmisor.liberarRecursos();
    await _controladorEstado.close();
  }
}
