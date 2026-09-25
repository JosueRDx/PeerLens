import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../compartido/widgets/badge_estado.dart';
import '../../compartido/widgets/contenedor_superficie.dart';
import '../../configuracion/tema/colores.dart';
import '../../nucleo/modelos/estado_nodo.dart';
import '../../nucleo/orquestacion/orquestador_p2p.dart';
import 'widgets/botonera_control.dart';
import 'widgets/hoja_configuracion_wifi.dart';
import 'widgets/visor_qr_ap.dart';

// dashboard principal para el control y streaming del nodo camara emisora
class PantallaCamara extends StatefulWidget {
  final OrquestadorP2p? orquestadorPruebas;

  const PantallaCamara({super.key, this.orquestadorPruebas});

  @override
  State<PantallaCamara> createState() => _PantallaCamaraState();
}

class _PantallaCamaraState extends State<PantallaCamara> {
  late final OrquestadorP2p _orquestador;
  StreamSubscription? _suscripcionEstado;

  bool _modoAhorroOled = false;
  bool _mostrarQr = true;
  bool _renderizadorInicializado = false;

  final int _clientesConectados = 1;
  final String _resolucionTexto = '1280x720';
  final int _cuadrosPorSegundo = 30;

  @override
  void initState() {
    super.initState();
    _orquestador = widget.orquestadorPruebas ?? OrquestadorP2p();
    _iniciarComponentes();
  }

  // inicializa el motor de captura de video local y componentes de red
  Future<void> _iniciarComponentes() async {
    _suscripcionEstado = _orquestador.flujoEstado.listen((estado) {
      if (mounted) {
        setState(() {});
      }
    });

    try {
      await _orquestador.iniciar();
      if (mounted) {
        setState(() {
          _renderizadorInicializado = true;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _suscripcionEstado?.cancel();
    _orquestador.liberarRecursos();
    super.dispose();
  }

  // activa o desactiva la pantalla negra completa para optimizar consumo oled
  void _alternarAhorroOled() {
    setState(() {
      _modoAhorroOled = !_modoAhorroOled;
    });
  }

  void _abrirConfiguracionWifi() {
    HojaConfiguracionWifi.mostrar(
      context: context,
      alGuardar: (ssid, clave) async {
        try {
          await _orquestador.aprovisionarNuevaRed(ssid, clave);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Conectando a red Wi-Fi $ssid'),
                backgroundColor: ColoresApp.acentoActivo,
              ),
            );
          }
        } catch (_) {}
      },
    );
  }

  Future<void> _reiniciarServidor() async {
    try {
      await _orquestador.servidorRed.detener();
      await _orquestador.servidorRed.iniciar(puerto: 8080);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servidor de señalización reiniciado en puerto 8080'),
            backgroundColor: ColoresApp.acentoRed,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _resetearRed() async {
    try {
      await _orquestador.olvidarRedYRetornarAp();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales eliminadas retornando a modo AP'),
            backgroundColor: ColoresApp.acentoPeligro,
          ),
        );
      }
    } catch (_) {}
  }

  TipoEstadoBadge _obtenerTipoBadge() {
    switch (_orquestador.estadoActual.estado) {
      case TipoEstadoNodo.modoAp:
        return TipoEstadoBadge.red;
      case TipoEstadoNodo.conectandoLan:
        return TipoEstadoBadge.alerta;
      case TipoEstadoNodo.enLineaLan:
        return TipoEstadoBadge.activo;
      case TipoEstadoNodo.error:
        return TipoEstadoBadge.error;
    }
  }

  String _obtenerEtiquetaBadge() {
    switch (_orquestador.estadoActual.estado) {
      case TipoEstadoNodo.modoAp:
        return 'Modo AP';
      case TipoEstadoNodo.conectandoLan:
        return 'Conectando';
      case TipoEstadoNodo.enLineaLan:
        final ip = _orquestador.estadoActual.direccionIp;
        return ip != null ? 'LAN $ip' : 'En Línea LAN';
      case TipoEstadoNodo.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_modoAhorroOled) {
      return Scaffold(
        backgroundColor: ColoresApp.negroOled,
        body: InkWell(
          onTap: _alternarAhorroOled,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam_outlined, color: Colors.white24, size: 48),
                SizedBox(height: 12),
                Text(
                  'Ahorro OLED Activo',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Toca la pantalla para restaurar la vista',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColoresApp.fondoPrimario,
      appBar: AppBar(
        title: const Text(
          'Cámara Emisora',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _mostrarQr ? Icons.qr_code_2 : Icons.qr_code_2_outlined,
              color: ColoresApp.acentoRed,
            ),
            tooltip: 'Código QR de conexión',
            onPressed: () => setState(() => _mostrarQr = !_mostrarQr),
          ),
          IconButton(
            icon: const Icon(
              Icons.nightlight_round,
              color: ColoresApp.textoSecundario,
            ),
            tooltip: 'Modo Ahorro OLED',
            onPressed: _alternarAhorroOled,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: BadgeEstado(
              etiqueta: _obtenerEtiquetaBadge(),
              tipo: _obtenerTipoBadge(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_mostrarQr) ...[
                VisorQrAp(
                  ssid: _orquestador.ssidAp,
                  clave: _orquestador.claveAp,
                  urlServidor: _orquestador.urlServidor,
                ),
                const SizedBox(height: 16),
              ],
              // contenedor de previsualizacion de transmision
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 240,
                  color: ColoresApp.fondoSuperficie,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_renderizadorInicializado)
                        RTCVideoView(
                          _orquestador.motorEmisor.renderizador,
                          mirror: false,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      else
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: ColoresApp.textoSecundario,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Iniciando cámara nativa...',
                              style: TextStyle(
                                color: ColoresApp.textoSecundario,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.circle,
                                color: ColoresApp.acentoActivo,
                                size: 8,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'TRANSMITIENDO EN VIVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // hud de metricas tecnicas en tiempo real
              ContenedorSuperficie(
                relleno: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hijo: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _construirElementoMetrica(
                      icono: Icons.hd_outlined,
                      etiqueta: 'Resolución',
                      valor: _resolucionTexto,
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      color: ColoresApp.bordeSuperficie,
                    ),
                    _construirElementoMetrica(
                      icono: Icons.speed,
                      etiqueta: 'Velocidad',
                      valor: '$_cuadrosPorSegundo FPS',
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      color: ColoresApp.bordeSuperficie,
                    ),
                    _construirElementoMetrica(
                      icono: Icons.people_alt_rounded,
                      etiqueta: 'Receptores',
                      valor: '$_clientesConectados',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BotoneraControl(
                alPresionarConectarWifi: _abrirConfiguracionWifi,
                alPresionarReiniciarServidor: _reiniciarServidor,
                alPresionarResetearRed: _resetearRed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirElementoMetrica({
    required IconData icono,
    required String etiqueta,
    required String valor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 14, color: ColoresApp.acentoRed),
            const SizedBox(width: 4),
            Text(
              valor,
              style: const TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: const TextStyle(
            color: ColoresApp.textoSecundario,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
