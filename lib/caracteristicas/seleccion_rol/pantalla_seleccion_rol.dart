import 'package:flutter/material.dart';
import '../../compartido/widgets/badge_estado.dart';
import '../../configuracion/tema/colores.dart';
import '../../nucleo/almacenamiento/servicio_almacenamiento_local.dart';
import '../transmision/paginas/pagina_emisor_camara.dart';
import '../transmision/paginas/pagina_receptor_visor.dart';
import 'widgets/tarjeta_rol.dart';

// pantalla principal para la eleccion interactiva del rol de dispositivo
class PantallaSeleccionRol extends StatefulWidget {
  const PantallaSeleccionRol({super.key});

  @override
  State<PantallaSeleccionRol> createState() => _PantallaSeleccionRolState();
}

class _PantallaSeleccionRolState extends State<PantallaSeleccionRol> {
  bool _recordarEleccion = false;

  @override
  void initState() {
    super.initState();
    _verificarRolPrevio();
  }

  Future<void> _verificarRolPrevio() async {
    try {
      final servicio = await ServicioAlmacenamientoLocal.crear();
      final rolGuardado = await servicio.obtenerRolPreferido();
      if (rolGuardado != null && mounted) {
        setState(() {
          _recordarEleccion = true;
        });
      }
    } catch (_) {}
  }

  // guarda la seleccion en persistencia local si la casilla esta marcada
  Future<void> _seleccionarRol(String rol, Widget paginaDestino) async {
    if (_recordarEleccion) {
      try {
        final servicio = await ServicioAlmacenamientoLocal.crear();
        await servicio.guardarRolPreferido(rol);
      } catch (_) {}
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => paginaDestino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PeerLens',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: BadgeEstado(
              etiqueta: 'LAN Activa',
              tipo: TipoEstadoBadge.red,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona el rol de este equipo',
                style: TextStyle(
                  color: ColoresApp.textoPrimario,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Define si este dispositivo actuara como camara emisora o pantalla receptora de video en tiempo real',
                style: TextStyle(
                  color: ColoresApp.textoSecundario,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              TarjetaRol(
                titulo: 'Modo Cámara',
                descripcion:
                    'Captura y transmite el video de la camara nativa hacia la red local con latencia minima',
                icono: Icons.videocam_rounded,
                colorAcento: ColoresApp.acentoRed,
                alSeleccionar: () =>
                    _seleccionarRol('camara', const PaginaEmisorCamara()),
              ),
              const SizedBox(height: 16),
              TarjetaRol(
                titulo: 'Modo Visor',
                descripcion:
                    'Recibe y visualiza el flujo de video en directo transmitido por el nodo camara',
                icono: Icons.monitor_rounded,
                colorAcento: ColoresApp.acentoActivo,
                alSeleccionar: () =>
                    _seleccionarRol('visor', const PaginaReceptorVisor()),
              ),
              const Spacer(),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(unselectedWidgetColor: ColoresApp.bordeSuperficie),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _recordarEleccion,
                  activeColor: ColoresApp.acentoRed,
                  title: const Text(
                    'Recordar mi eleccion en este dispositivo',
                    style: TextStyle(
                      color: ColoresApp.textoPrimario,
                      fontSize: 14,
                    ),
                  ),
                  onChanged: (valor) {
                    setState(() {
                      _recordarEleccion = valor ?? false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
