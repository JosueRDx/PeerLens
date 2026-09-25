import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../configuracion/tema/colores.dart';

// widget contenedor del renderizador webrtc adaptado al viewport manteniendo relacion de aspecto
class ReproductorWebRtc extends StatelessWidget {
  final RTCVideoRenderer renderizador;
  final bool estaTransmitiendo;
  final Widget? superposicion;
  final VoidCallback? alTocar;

  const ReproductorWebRtc({
    super.key,
    required this.renderizador,
    this.estaTransmitiendo = true,
    this.superposicion,
    this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alTocar,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: ColoresApp.negroOled,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (estaTransmitiendo)
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: renderizador.videoWidth > 0
                        ? renderizador.videoWidth.toDouble()
                        : 1280,
                    height: renderizador.videoHeight > 0
                        ? renderizador.videoHeight.toDouble()
                        : 720,
                    child: RTCVideoView(
                      renderizador,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                      mirror: false,
                    ),
                  ),
                ),
              )
            else
              _construirIndicadorEspera(),
            ?superposicion,
          ],
        ),
      ),
    );
  }

  Widget _construirIndicadorEspera() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.acentoRed),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Estableciendo Enlace WebRTC',
              style: TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Negociando sesión P2P con el nodo emisor en red local',
              textAlign: TextAlign.center,
              style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
