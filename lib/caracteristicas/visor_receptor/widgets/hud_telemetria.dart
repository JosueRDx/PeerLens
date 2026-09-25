import 'package:flutter/material.dart';
import '../../../compartido/widgets/badge_estado.dart';
import '../../../compartido/widgets/contenedor_superficie.dart';
import '../../../configuracion/tema/colores.dart';

// overlay superpuesto con telemetria en tiempo real y controles del reproductor
class HudTelemetria extends StatelessWidget {
  final int latenciaMs;
  final int cuadrosPorSegundo;
  final String resolucion;
  final bool esPantallaCompleta;
  final bool visible;
  final String? nombreCamara;
  final VoidCallback onAlternarPantallaCompleta;
  final VoidCallback onDesconectar;

  const HudTelemetria({
    super.key,
    required this.latenciaMs,
    required this.cuadrosPorSegundo,
    required this.resolucion,
    required this.esPantallaCompleta,
    this.visible = true,
    this.nombreCamara,
    required this.onAlternarPantallaCompleta,
    required this.onDesconectar,
  });

  Color _obtenerColorLatencia() {
    if (latenciaMs < 60) return ColoresApp.acentoActivo;
    if (latenciaMs < 120) return ColoresApp.acentoAdvertencia;
    return ColoresApp.acentoPeligro;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: IgnorePointer(
        ignoring: !visible,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _construirBarraSuperior(context),
                _construirBarraInferior(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirBarraSuperior(BuildContext context) {
    return ContenedorSuperficie(
      relleno: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      radioBorde: BorderRadius.circular(16),
      hijo: Row(
        children: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white10,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ColoresApp.textoPrimario,
              size: 16,
            ),
            tooltip: 'Regresar a lista de cámaras',
            onPressed: onDesconectar,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nombreCamara ?? 'Cámara PeerLens',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    BadgeEstado(
                      etiqueta: 'En Vivo',
                      tipo: TipoEstadoBadge.activo,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white10,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
            ),
            icon: Icon(
              esPantallaCompleta
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
              color: ColoresApp.textoPrimario,
              size: 20,
            ),
            tooltip: esPantallaCompleta
                ? 'Salir de pantalla completa'
                : 'Pantalla completa',
            onPressed: onAlternarPantallaCompleta,
          ),
        ],
      ),
    );
  }

  Widget _construirBarraInferior() {
    final colorLatencia = _obtenerColorLatencia();

    return ContenedorSuperficie(
      relleno: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      radioBorde: BorderRadius.circular(16),
      hijo: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _construirChipMetrica(
            icono: Icons.speed_rounded,
            colorIcono: colorLatencia,
            valor: '$latenciaMs ms',
            etiqueta: 'Latencia P2P',
            colorValor: colorLatencia,
          ),
          Container(height: 28, width: 1, color: ColoresApp.bordeSuperficie),
          _construirChipMetrica(
            icono: Icons.movie_filter_rounded,
            colorIcono: ColoresApp.acentoRed,
            valor: '$cuadrosPorSegundo FPS',
            etiqueta: 'Cuadros',
            colorValor: ColoresApp.textoPrimario,
          ),
          Container(height: 28, width: 1, color: ColoresApp.bordeSuperficie),
          _construirChipMetrica(
            icono: Icons.high_quality_rounded,
            colorIcono: ColoresApp.acentoActivo,
            valor: resolucion,
            etiqueta: 'Resolución',
            colorValor: ColoresApp.textoPrimario,
          ),
        ],
      ),
    );
  }

  Widget _construirChipMetrica({
    required IconData icono,
    required Color colorIcono,
    required String valor,
    required String etiqueta,
    required Color colorValor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: colorIcono, size: 14),
            const SizedBox(width: 4),
            Text(
              valor,
              style: TextStyle(
                color: colorValor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: const TextStyle(
            color: ColoresApp.textoSecundario,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
