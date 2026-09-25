import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../compartido/widgets/contenedor_superficie.dart';
import '../../../configuracion/tema/colores.dart';

// widget para escanear codigo qr y extraer credenciales de conexion
class EscanerQrAp extends StatefulWidget {
  final void Function({
    required String ssid,
    required String clave,
    required String url,
  })
  alDetectar;
  final VoidCallback? alCerrar;

  const EscanerQrAp({super.key, required this.alDetectar, this.alCerrar});

  static Future<void> mostrar({
    required BuildContext context,
    required void Function({
      required String ssid,
      required String clave,
      required String url,
    })
    alDetectar,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EscanerQrAp(
        alDetectar: alDetectar,
        alCerrar: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<EscanerQrAp> createState() => _EscanerQrApState();
}

class _EscanerQrApState extends State<EscanerQrAp> {
  late final MobileScannerController _controlador;
  final TextEditingController _controladorTextoManual = TextEditingController(
    text: 'http://192.168.49.1:8080',
  );
  bool _detectado = false;
  bool _mostrarEntradaManual = false;

  @override
  void initState() {
    super.initState();
    _controlador = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    _controladorTextoManual.dispose();
    super.dispose();
  }

  void _procesarCodigo(BarcodeCapture captura) {
    if (_detectado) return;

    for (final codigo in captura.barcodes) {
      final valor = codigo.rawValue;
      if (valor != null && valor.isNotEmpty) {
        _detectado = true;
        _interpretarContenido(valor);
        break;
      }
    }
  }

  void _interpretarContenido(String contenido) {
    try {
      final mapa = jsonDecode(contenido) as Map<String, dynamic>;
      final ssid = mapa['ssid']?.toString() ?? '';
      final clave = mapa['clave']?.toString() ?? '';
      final url = mapa['url']?.toString() ?? 'http://192.168.49.1:8080';
      widget.alDetectar(ssid: ssid, clave: clave, url: url);
    } catch (_) {
      // decodificacion directa en caso de url de texto plano
      widget.alDetectar(ssid: '', clave: '', url: contenido);
    }
  }

  void _enviarManual() {
    final texto = _controladorTextoManual.text.trim();
    if (texto.isNotEmpty) {
      _interpretarContenido(texto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: ColoresApp.fondoPrimario,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _construirBarraSuperior(),
          Expanded(
            child: _mostrarEntradaManual
                ? _construirEntradaManual()
                : _construirVisorCamara(),
          ),
          _construirBarraInferior(),
        ],
      ),
    );
  }

  Widget _construirBarraSuperior() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(
                Icons.qr_code_scanner_rounded,
                color: ColoresApp.acentoRed,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Escanear QR de Cámara',
                style: TextStyle(
                  color: ColoresApp.textoPrimario,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: ColoresApp.textoSecundario,
            ),
            onPressed: widget.alCerrar ?? () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _construirVisorCamara() {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: _controlador,
          onDetect: _procesarCodigo,
          errorBuilder: (context, error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.videocam_off_rounded,
                      color: ColoresApp.acentoPeligro,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cámara no disponible en este dispositivo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColoresApp.textoPrimario,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.errorDetails?.message ??
                          'Permiso denegado o entorno simulado',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ColoresApp.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.acentoRed,
                      ),
                      onPressed: () {
                        setState(() {
                          _mostrarEntradaManual = true;
                        });
                      },
                      icon: const Icon(Icons.keyboard_rounded),
                      label: const Text('Ingresar URL manualmente'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        _construirMarcoEscaneo(),
        Positioned(
          top: 16,
          child: Row(
            children: [
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                onPressed: () => _controlador.toggleTorch(),
              ),
              const SizedBox(width: 12),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                icon: const Icon(
                  Icons.cameraswitch_rounded,
                  color: Colors.white,
                ),
                onPressed: () => _controlador.switchCamera(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirMarcoEscaneo() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        border: Border.all(
          color: ColoresApp.acentoRed.withValues(alpha: 0.8),
          width: 2.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _construirEntradaManual() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.link_rounded, color: ColoresApp.acentoRed, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Conexión Directa al Emisor',
            style: TextStyle(
              color: ColoresApp.textoPrimario,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingresa la dirección IP y puerto del servidor local',
            textAlign: TextAlign.center,
            style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controladorTextoManual,
            style: const TextStyle(
              color: ColoresApp.textoPrimario,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(
              labelText: 'URL o IP del Servidor',
              hintText: 'http://192.168.49.1:8080',
              prefixIcon: Icon(Icons.lan_rounded, color: ColoresApp.acentoRed),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.acentoRed,
              ),
              onPressed: _enviarManual,
              child: const Text('Conectar al Nodo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBarraInferior() {
    return ContenedorSuperficie(
      relleno: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hijo: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _mostrarEntradaManual
                  ? 'Modo entrada manual activo'
                  : 'Apunta la cámara al código QR mostrado en la cámara emisora',
              style: const TextStyle(
                color: ColoresApp.textoSecundario,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _mostrarEntradaManual = !_mostrarEntradaManual;
              });
            },
            child: Text(
              _mostrarEntradaManual ? 'Usar Cámara' : 'Manual',
              style: const TextStyle(
                color: ColoresApp.acentoRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
