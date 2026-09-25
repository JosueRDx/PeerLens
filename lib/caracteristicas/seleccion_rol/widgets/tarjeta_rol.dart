import 'package:flutter/material.dart';
import '../../../compartido/widgets/contenedor_superficie.dart';
import '../../../configuracion/tema/colores.dart';

// tarjeta tactil interactiva para seleccion de rol de dispositivo
class TarjetaRol extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final VoidCallback alSeleccionar;
  final Color colorAcento;

  const TarjetaRol({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.alSeleccionar,
    this.colorAcento = ColoresApp.acentoRed,
  });

  @override
  Widget build(BuildContext context) {
    return ContenedorSuperficie(
      alPresionar: alSeleccionar,
      relleno: const EdgeInsets.all(20),
      radioBorde: BorderRadius.circular(16),
      hijo: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorAcento.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorAcento.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(icono, color: colorAcento, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: ColoresApp.textoSecundario,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: ColoresApp.textoSecundario),
        ],
      ),
    );
  }
}
