import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../compartido/widgets/contenedor_superficie.dart';
import '../../../configuracion/tema/colores.dart';

// componente para renderizar el codigo qr con las credenciales del punto de acceso
class VisorQrAp extends StatelessWidget {
  final String ssid;
  final String clave;
  final String urlServidor;

  const VisorQrAp({
    super.key,
    required this.ssid,
    required this.clave,
    this.urlServidor = 'http://192.168.49.1:8080',
  });

  String _generarCargaUtil() {
    return jsonEncode({'ssid': ssid, 'clave': clave, 'url': urlServidor});
  }

  @override
  Widget build(BuildContext context) {
    return ContenedorSuperficie(
      relleno: const EdgeInsets.all(20),
      radioBorde: BorderRadius.circular(16),
      hijo: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.qr_code_2_rounded,
                color: ColoresApp.acentoRed,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Escaneo Rápido de Enlace',
                style: TextStyle(
                  color: ColoresApp.textoPrimario,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: _generarCargaUtil(),
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SSID: $ssid',
            style: const TextStyle(
              color: ColoresApp.textoPrimario,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Clave: $clave',
            style: const TextStyle(
              color: ColoresApp.textoSecundario,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            urlServidor,
            style: const TextStyle(
              color: ColoresApp.acentoRed,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
