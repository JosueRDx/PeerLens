import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../compartido/widgets/badge_estado.dart';
import '../../compartido/widgets/contenedor_superficie.dart';
import '../../configuracion/tema/colores.dart';
import '../../nucleo/almacenamiento/servicio_almacenamiento_local.dart';
import '../../nucleo/modelos/credencial_red.dart';
import '../red/implementacion/gestor_ap_android.dart';
import '../transmision/implementacion/motor_webrtc_emisor.dart';
import 'widgets/botonera_control.dart';
import 'widgets/hoja_configuracion_wifi.dart';
import 'widgets/visor_qr_ap.dart';

// dashboard principal para el control y streaming del nodo camara emisora
class PantallaCamara extends StatefulWidget {
  const PantallaCamara({super.key});

  @override
  State<PantallaCamara> createState() => _PantallaCamaraState();
}

class _PantallaCamaraState extends State<PantallaCamara> {
  bool _modoAhorroOled = false;
  bool _mostrarQr = false;
  String _ssidAp = 'PeerLens_AP_8080';
  String _claveAp = '12345678';
  final int _clientesConectados = 1;
  final String _resolucionTexto = '1280x720';
  final int _cuadrosPorSegundo = 30;

  late final MotorWebRtcEmisor _motorEmisor;
  bool _renderizadorInicializado = false;

  @override
  void initState() {
    super.initState();
    _motorEmisor = MotorWebRtcEmisor();
    _iniciarComponentes();
  }

  // inicializa el motor de captura de video local y componentes de red
  Future<void> _iniciarComponentes() async {
    _ssidAp = GestorApAndroid.generarSsidAleatorio();
    _claveAp = GestorApAndroid.generarClaveAleatoria();

    try {
      await _motorEmisor.inicializarRenderizador();
      await _motorEmisor.iniciarCapturaCamara();
      if (mounted) {
        setState(() {
          _renderizadorInicializado = true;
        });
      }
    } catch (_) {
      // captura protegida para entornos de prueba o simulador
    }
  }

  @override
  void dispose() {
    _motorEmisor.liberarRecursos();
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
          final servicio = await ServicioAlmacenamientoLocal.crear();
          await servicio.guardarCredencialRed(
            CredencialRed(
              nombreRed: ssid,
              claveRed: clave,
              fechaGuardado: DateTime.now(),
            ),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Credenciales guardadas para red $ssid'),
                backgroundColor: ColoresApp.acentoActivo,
              ),
            );
          }
        } catch (_) {}
      },
    );
  }

  void _reiniciarServidor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reiniciando servidor de señalización local'),
        backgroundColor: ColoresApp.acentoRed,
      ),
    );
  }

  Future<void> _resetearRed() async {
    try {
      final servicio = await ServicioAlmacenamientoLocal.crear();
      await servicio.eliminarCredencialRed();
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
                  'Toca la pantalla para restablecer la vista',
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
          const Padding(
            padding: EdgeInsets.only(right: 12, left: 4),
            child: BadgeEstado(etiqueta: 'Modo AP', tipo: TipoEstadoBadge.red),
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
                VisorQrAp(ssid: _ssidAp, clave: _claveAp),
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
                          _motorEmisor.renderizador,
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
                              'Sensor de Cámara Activo',
                              style: TextStyle(
                                color: ColoresApp.textoSecundario,
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
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                color: ColoresApp.acentoActivo,
                                size: 10,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'EN VIVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
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
              // hud de metricas tecnicas
              ContenedorSuperficie(
                relleno: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hijo: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _construirElementoHud(
                      Icons.aspect_ratio_rounded,
                      'Resolución',
                      _resolucionTexto,
                      ColoresApp.acentoRed,
                    ),
                    _construirElementoHud(
                      Icons.speed_rounded,
                      'Velocidad',
                      '$_cuadrosPorSegundo FPS',
                      ColoresApp.acentoActivo,
                    ),
                    _construirElementoHud(
                      Icons.people_alt_rounded,
                      'Receptores',
                      '$_clientesConectados Activo',
                      ColoresApp.acentoAdvertencia,
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

  Widget _construirElementoHud(
    IconData icono,
    String titulo,
    String valor,
    Color colorAcento,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: colorAcento, size: 20),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: const TextStyle(
            color: ColoresApp.textoSecundario,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            color: ColoresApp.textoPrimario,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
