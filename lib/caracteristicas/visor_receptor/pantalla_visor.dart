import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../compartido/widgets/badge_estado.dart';
import '../../compartido/widgets/contenedor_superficie.dart';
import '../../configuracion/tema/colores.dart';
import '../red/contratos/servicio_mdns.dart';
import '../red/implementacion/servicio_mdns_nsd.dart';
import '../transmision/implementacion/motor_webrtc_receptor.dart';
import '../transmision/modelos/configuracion_video.dart';
import 'widgets/escaner_qr_ap.dart';
import 'widgets/hud_telemetria.dart';
import 'widgets/reproductor_webrtc.dart';

// pantalla principal del nodo visor con exploracion mdns y reproductor webrtc
class PantallaVisor extends StatefulWidget {
  const PantallaVisor({super.key});

  @override
  State<PantallaVisor> createState() => _PantallaVisorState();
}

class _PantallaVisorState extends State<PantallaVisor> {
  final TextEditingController _controladorIpManual = TextEditingController(
    text: '192.168.49.1:8080',
  );

  late final ServicioMdnsNsd _servicioMdns;
  late final MotorWebRtcReceptor _motorReceptor;

  StreamSubscription? _suscripcionMdns;
  StreamSubscription? _suscripcionEstadoWebrtc;
  StreamSubscription? _suscripcionCandidatos;
  StreamSubscription? _suscripcionWebSocket;
  WebSocketChannel? _canalWebSocket;
  Timer? _temporizadorPing;

  List<NodoDescubierto> _camarasDetectadas = [];
  bool _modoReproductor = false;
  bool _conectando = false;
  bool _esPantallaCompleta = false;
  bool _mostrarHud = true;
  int _latenciaMs = 28;
  final int _cuadrosPorSegundo = 30;
  final String _resolucion = '1280x720';
  String? _nombreCamaraConectada;
  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _servicioMdns = ServicioMdnsNsd();
    _motorReceptor = MotorWebRtcReceptor();
    _inicializarServicios();
  }

  Future<void> _inicializarServicios() async {
    try {
      await _motorReceptor.inicializarRenderizador();
    } catch (_) {}

    _suscripcionEstadoWebrtc = _motorReceptor.flujoEstado.listen((estado) {
      if (estado == EstadoConexionP2p.transmitiendo) {
        if (mounted) {
          setState(() {
            _conectando = false;
          });
        }
      } else if (estado == EstadoConexionP2p.error) {
        if (mounted) {
          setState(() {
            _conectando = false;
            _mensajeError = 'Error en el enlace WebRTC con la cámara';
          });
        }
      }
    });

    _suscripcionCandidatos = _motorReceptor.flujoCandidatoIce.listen((
      candidato,
    ) {
      _canalWebSocket?.sink.add(
        jsonEncode({
          'tipo': 'candidato',
          'candidato': candidato.candidate,
          'sdpMid': candidato.sdpMid,
          'sdpMLineIndex': candidato.sdpMLineIndex,
        }),
      );
    });

    _suscripcionMdns = _servicioMdns.flujoNodos.listen((nodos) {
      if (mounted) {
        setState(() {
          _camarasDetectadas = nodos;
        });
      }
    });

    try {
      await _servicioMdns.iniciarExploracionCamaras();
    } catch (_) {}
  }

  @override
  void dispose() {
    _detenerSesionStreaming();
    _suscripcionMdns?.cancel();
    _suscripcionEstadoWebrtc?.cancel();
    _suscripcionCandidatos?.cancel();
    _servicioMdns.detenerExploracion();
    _motorReceptor.liberarRecursos();
    _controladorIpManual.dispose();
    super.dispose();
  }

  void _detenerSesionStreaming() {
    _temporizadorPing?.cancel();
    _temporizadorPing = null;
    _suscripcionWebSocket?.cancel();
    _suscripcionWebSocket = null;
    _canalWebSocket?.sink.close();
    _canalWebSocket = null;
  }

  Future<void> _conectarACamara({
    required String direccionHost,
    int puerto = 8080,
    String? nombre,
  }) async {
    setState(() {
      _conectando = true;
      _modoReproductor = true;
      _mensajeError = null;
      _nombreCamaraConectada = nombre ?? 'Cámara $direccionHost';
    });

    _detenerSesionStreaming();

    try {
      var hostLimpio = direccionHost
          .replaceAll('http://', '')
          .replaceAll('https://', '')
          .replaceAll('ws://', '')
          .replaceAll('wss://', '');

      if (hostLimpio.contains('/')) {
        hostLimpio = hostLimpio.split('/')[0];
      }

      var puertoFinal = puerto;

      if (hostLimpio.contains(':')) {
        final partes = hostLimpio.split(':');
        hostLimpio = partes[0];
        puertoFinal = int.tryParse(partes[1]) ?? puerto;
      }

      final uriWs = Uri.parse('ws://$hostLimpio:$puertoFinal/ws');
      _canalWebSocket = WebSocketChannel.connect(uriWs);

      await _motorReceptor.prepararConexionP2p();

      _suscripcionWebSocket = _canalWebSocket!.stream.listen(
        _procesarMensajeSenalizacion,
        onError: (error) {
          if (mounted) {
            setState(() {
              _conectando = false;
              _mensajeError =
                  'Error de conexión con el servidor de señalización';
            });
          }
        },
        onDone: () {
          if (mounted && _modoReproductor) {
            setState(() {
              _conectando = false;
            });
          }
        },
      );

      _iniciarMedicionLatencia();
    } catch (error) {
      if (mounted) {
        setState(() {
          _conectando = false;
          _mensajeError = 'No fue posible iniciar la conexión: $error';
        });
      }
    }
  }

  void _iniciarMedicionLatencia() {
    _temporizadorPing?.cancel();
    _temporizadorPing = Timer.periodic(const Duration(seconds: 2), (_) {
      try {
        _canalWebSocket?.sink.add(
          jsonEncode({
            'tipo': 'ping',
            'tiempo': DateTime.now().millisecondsSinceEpoch,
          }),
        );
      } catch (_) {}
    });
  }

  Future<void> _procesarMensajeSenalizacion(dynamic datos) async {
    try {
      final mapa = jsonDecode(datos.toString()) as Map<String, dynamic>;
      final tipo = mapa['tipo'];

      if (tipo == 'oferta') {
        final sdp = mapa['sdp'] as String;
        await _motorReceptor.establecerDescripcionRemota(
          RTCSessionDescription(sdp, 'offer'),
        );
        final respuesta = await _motorReceptor.crearRespuesta();
        _canalWebSocket?.sink.add(
          jsonEncode({'tipo': 'respuesta', 'sdp': respuesta.sdp}),
        );
      } else if (tipo == 'candidato') {
        final candidato = mapa['candidato'] ?? mapa['candidate'];
        final sdpMid = mapa['sdpMid']?.toString();
        final sdpMLineIndex = mapa['sdpMLineIndex'];
        if (candidato != null) {
          await _motorReceptor.agregarCandidatoIce(
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
        _canalWebSocket?.sink.add(
          jsonEncode({'tipo': 'pong', 'tiempo': mapa['tiempo']}),
        );
      } else if (tipo == 'pong') {
        final tiempoEnvio = mapa['tiempo'] as int?;
        if (tiempoEnvio != null && mounted) {
          final rtt = DateTime.now().millisecondsSinceEpoch - tiempoEnvio;
          setState(() {
            _latenciaMs = (rtt / 2).round().clamp(12, 450);
          });
        }
      }
    } catch (_) {}
  }

  void _desconectar() {
    _detenerSesionStreaming();
    setState(() {
      _modoReproductor = false;
      _conectando = false;
      _esPantallaCompleta = false;
      _nombreCamaraConectada = null;
    });
  }

  void _abrirEscanerQr() {
    EscanerQrAp.mostrar(
      context: context,
      alDetectar: ({required ssid, required clave, required url}) {
        Navigator.of(context).pop();
        _conectarACamara(
          direccionHost: url,
          nombre: ssid.isNotEmpty ? ssid : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_modoReproductor) {
      return _construirModoReproductor();
    }
    return _construirModoDescubrimiento();
  }

  Widget _construirModoReproductor() {
    return Scaffold(
      backgroundColor: ColoresApp.negroOled,
      body: ReproductorWebRtc(
        renderizador: _motorReceptor.renderizador,
        estaTransmitiendo: !_conectando,
        alTocar: () {
          setState(() {
            _mostrarHud = !_mostrarHud;
          });
        },
        superposicion: HudTelemetria(
          latenciaMs: _latenciaMs,
          cuadrosPorSegundo: _cuadrosPorSegundo,
          resolucion: _resolucion,
          esPantallaCompleta: _esPantallaCompleta,
          visible: _mostrarHud,
          nombreCamara: _nombreCamaraConectada,
          onAlternarPantallaCompleta: () {
            setState(() {
              _esPantallaCompleta = !_esPantallaCompleta;
            });
          },
          onDesconectar: _desconectar,
        ),
      ),
    );
  }

  Widget _construirModoDescubrimiento() {
    return Scaffold(
      backgroundColor: ColoresApp.fondoPrimario,
      appBar: AppBar(
        title: const Text('PeerLens - Visor'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: BadgeEstado(
                etiqueta: 'mDNS Activo',
                tipo: TipoEstadoBadge.red,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_mensajeError != null) _construirBannerError(),
              _construirTarjetaCabecera(),
              const SizedBox(height: 20),
              _construirBotoneraAcciones(),
              const SizedBox(height: 24),
              _construirSeccionDispositivos(),
              const SizedBox(height: 24),
              _construirTarjetaConexionDirecta(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirBannerError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresApp.acentoPeligro.withValues(alpha: 0.15),
        border: Border.all(color: ColoresApp.acentoPeligro),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: ColoresApp.acentoPeligro,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _mensajeError!,
              style: const TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: ColoresApp.textoSecundario,
            ),
            onPressed: () {
              setState(() {
                _mensajeError = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaCabecera() {
    return ContenedorSuperficie(
      relleno: const EdgeInsets.all(20),
      radioBorde: BorderRadius.circular(20),
      hijo: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.acentoRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: ColoresApp.acentoRed,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exploración de Red Local',
                  style: TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Buscando cámaras activas anunciadas mediante mDNS',
                  style: TextStyle(
                    color: ColoresApp.textoSecundario,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBotoneraAcciones() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.acentoRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text(
                'Escanear QR',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: _abrirEscanerQr,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirSeccionDispositivos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cámaras Detectadas (${_camarasDetectadas.length})',
              style: const TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_camarasDetectadas.isNotEmpty)
              const BadgeEstado(
                etiqueta: 'Disponibles',
                tipo: TipoEstadoBadge.activo,
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_camarasDetectadas.isEmpty)
          ContenedorSuperficie(
            relleno: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            radioBorde: BorderRadius.circular(16),
            hijo: Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.wifi_tethering_rounded,
                    color: ColoresApp.textoSecundario,
                    size: 36,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No se han encontrado cámaras en la red',
                    style: TextStyle(
                      color: ColoresApp.textoPrimario,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Conéctate a la misma red Wi-Fi o escanea el QR del emisor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColoresApp.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._camarasDetectadas.map(_construirTarjetaCamara),
      ],
    );
  }

  Widget _construirTarjetaCamara(NodoDescubierto nodo) {
    final ip = nodo.direccionIp ?? '192.168.49.1';
    final puerto = nodo.puerto ?? 8080;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ContenedorSuperficie(
        relleno: const EdgeInsets.all(16),
        radioBorde: BorderRadius.circular(16),
        hijo: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColoresApp.acentoActivo.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: ColoresApp.acentoActivo,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nodo.nombre,
                    style: const TextStyle(
                      color: ColoresApp.textoPrimario,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$ip:$puerto',
                    style: const TextStyle(
                      color: ColoresApp.textoSecundario,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.acentoRed,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _conectarACamara(
                direccionHost: ip,
                puerto: puerto,
                nombre: nodo.nombre,
              ),
              child: const Text('Conectar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTarjetaConexionDirecta() {
    return ContenedorSuperficie(
      relleno: const EdgeInsets.all(20),
      radioBorde: BorderRadius.circular(18),
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lan_rounded, color: ColoresApp.acentoRed, size: 20),
              SizedBox(width: 8),
              Text(
                'Conexión Directa por Dirección IP',
                style: TextStyle(
                  color: ColoresApp.textoPrimario,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Utiliza esta opción si te conectaste directamente al Hotspot del emisor',
            style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controladorIpManual,
                  style: const TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    hintText: '192.168.49.1:8080',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.acentoRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final texto = _controladorIpManual.text.trim();
                  if (texto.isNotEmpty) {
                    _conectarACamara(direccionHost: texto);
                  }
                },
                child: const Text('Conectar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
