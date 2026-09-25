import 'package:flutter/material.dart';
import '../../../configuracion/tema/colores.dart';

// barra ergonomica de controles tecnicos para la camara emisora
class BotoneraControl extends StatelessWidget {
  final VoidCallback alPresionarConectarWifi;
  final VoidCallback alPresionarReiniciarServidor;
  final VoidCallback alPresionarResetearRed;

  const BotoneraControl({
    super.key,
    required this.alPresionarConectarWifi,
    required this.alPresionarReiniciarServidor,
    required this.alPresionarResetearRed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.acentoRed,
              foregroundColor: ColoresApp.fondoPrimario,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.wifi_find_rounded, size: 20),
            label: const Text(
              'Conectar a Wi-Fi',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: alPresionarConectarWifi,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresApp.textoPrimario,
                    side: const BorderSide(color: ColoresApp.bordeSuperficie),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Reiniciar Servidor',
                    style: TextStyle(fontSize: 13),
                  ),
                  onPressed: alPresionarReiniciarServidor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresApp.acentoPeligro,
                    side: BorderSide(
                      color: ColoresApp.acentoPeligro.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_forever_rounded, size: 18),
                  label: const Text(
                    'Olvidar Red / Reset',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: alPresionarResetearRed,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
