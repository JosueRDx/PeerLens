import 'package:flutter/material.dart';
import '../../configuracion/tema/colores.dart';

enum TipoEstadoBadge { activo, red, alerta, error }

// componente visual indicador de estado de red con punto luminoso
class BadgeEstado extends StatelessWidget {
  final String etiqueta;
  final TipoEstadoBadge tipo;

  const BadgeEstado({
    super.key,
    required this.etiqueta,
    this.tipo = TipoEstadoBadge.activo,
  });

  Color _obtenerColorIndicador() {
    switch (tipo) {
      case TipoEstadoBadge.activo:
        return ColoresApp.acentoActivo;
      case TipoEstadoBadge.red:
        return ColoresApp.acentoRed;
      case TipoEstadoBadge.alerta:
        return ColoresApp.acentoAdvertencia;
      case TipoEstadoBadge.error:
        return ColoresApp.acentoPeligro;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _obtenerColorIndicador();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ColoresApp.fondoSuperficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeSuperficie, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            etiqueta,
            style: const TextStyle(
              color: ColoresApp.textoSecundario,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
