import 'package:flutter/material.dart';
import '../../../configuracion/tema/colores.dart';
import '../../red/implementacion/gestor_ap_android.dart';

// modal inferior con lista de redes wifi detectadas y formulario de credenciales
class HojaConfiguracionWifi extends StatefulWidget {
  final void Function(String ssid, String clave) alGuardar;

  const HojaConfiguracionWifi({super.key, required this.alGuardar});

  static Future<void> mostrar({
    required BuildContext context,
    required void Function(String ssid, String clave) alGuardar,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColoresApp.fondoSuperficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: ColoresApp.bordeSuperficie, width: 1),
      ),
      builder: (context) => HojaConfiguracionWifi(alGuardar: alGuardar),
    );
  }

  @override
  State<HojaConfiguracionWifi> createState() => _HojaConfiguracionWifiState();
}

class _HojaConfiguracionWifiState extends State<HojaConfiguracionWifi> {
  final _formularioClave = GlobalKey<FormState>();
  final _controladorSsid = TextEditingController();
  final _controladorClave = TextEditingController();
  final _gestorAp = GestorApAndroid();

  List<String> _redesDetectadas = [];
  bool _escaneando = true;
  bool _ocultarClave = true;
  bool _modoManual = false;
  String? _redSeleccionada;

  @override
  void initState() {
    super.initState();
    _escanearRedes();
  }

  @override
  void dispose() {
    _controladorSsid.dispose();
    _controladorClave.dispose();
    super.dispose();
  }

  Future<void> _escanearRedes() async {
    setState(() {
      _escaneando = true;
    });

    try {
      final redes = await _gestorAp.escanearRedesDisponibles();
      if (mounted) {
        setState(() {
          _redesDetectadas = redes;
          _escaneando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _escaneando = false;
        });
      }
    }
  }

  void _seleccionarRed(String ssid) {
    setState(() {
      _redSeleccionada = ssid;
      _controladorSsid.text = ssid;
      _modoManual = false;
    });
  }

  void _enviarFormulario() {
    if (_formularioClave.currentState?.validate() ?? false) {
      final ssid = _controladorSsid.text.trim();
      final clave = _controladorClave.text;
      widget.alGuardar(ssid, clave);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rellenoInferior = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + rellenoInferior),
      child: Form(
        key: _formularioClave,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColoresApp.bordeSuperficie,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Conectar a Red Wi-Fi',
                  style: TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_escaneando)
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: ColoresApp.acentoRed,
                    ),
                    tooltip: 'Escanear redes nuevamente',
                    onPressed: _escanearRedes,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecciona tu red doméstica de la lista para vincular la cámara',
              style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (_escaneando)
              _construirIndicadorEscaneo()
            else if (_redSeleccionada != null || _modoManual)
              _construirFormularioClave()
            else
              _construirListaRedes(),
          ],
        ),
      ),
    );
  }

  Widget _construirIndicadorEscaneo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.acentoRed),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Escaneando redes Wi-Fi cercanas...',
            style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _construirListaRedes() {
    if (_redesDetectadas.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: ColoresApp.textoSecundario,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se encontraron redes Wi-Fi visibles',
              style: TextStyle(color: ColoresApp.textoPrimario, fontSize: 14),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: ColoresApp.acentoRed,
                side: const BorderSide(color: ColoresApp.acentoRed),
              ),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Ingresar datos manualmente'),
              onPressed: () {
                setState(() {
                  _modoManual = true;
                });
              },
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _redesDetectadas.length,
            separatorBuilder: (context, index) =>
                const Divider(color: ColoresApp.bordeSuperficie, height: 1),
            itemBuilder: (context, index) {
              final red = _redesDetectadas[index];
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: const Icon(
                  Icons.wifi_rounded,
                  color: ColoresApp.acentoRed,
                  size: 20,
                ),
                title: Text(
                  red,
                  style: const TextStyle(
                    color: ColoresApp.textoPrimario,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: ColoresApp.textoSecundario,
                ),
                onTap: () => _seleccionarRed(red),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Ingresar red oculta manualmente'),
            style: TextButton.styleFrom(
              foregroundColor: ColoresApp.textoSecundario,
            ),
            onPressed: () {
              setState(() {
                _modoManual = true;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _construirFormularioClave() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_redSeleccionada != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: ColoresApp.bordeSuperficie.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColoresApp.bordeSuperficie),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_rounded,
                  color: ColoresApp.acentoRed,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _redSeleccionada!,
                    style: const TextStyle(
                      color: ColoresApp.textoPrimario,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _redSeleccionada = null;
                      _controladorSsid.clear();
                      _controladorClave.clear();
                    });
                  },
                  child: const Text('Cambiar'),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              controller: _controladorSsid,
              style: const TextStyle(color: ColoresApp.textoPrimario),
              decoration: InputDecoration(
                labelText: 'Nombre de Red SSID',
                labelStyle: const TextStyle(color: ColoresApp.textoSecundario),
                prefixIcon: const Icon(
                  Icons.wifi_rounded,
                  color: ColoresApp.acentoRed,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: ColoresApp.bordeSuperficie,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: ColoresApp.acentoRed),
                ),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'El nombre de red es requerido';
                }
                return null;
              },
            ),
          ),
        TextFormField(
          controller: _controladorClave,
          obscureText: _ocultarClave,
          style: const TextStyle(color: ColoresApp.textoPrimario),
          decoration: InputDecoration(
            labelText: 'Contraseña WPA2',
            labelStyle: const TextStyle(color: ColoresApp.textoSecundario),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: ColoresApp.acentoRed,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _ocultarClave
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: ColoresApp.textoSecundario,
              ),
              onPressed: () {
                setState(() {
                  _ocultarClave = !_ocultarClave;
                });
              },
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ColoresApp.bordeSuperficie),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ColoresApp.acentoRed),
            ),
          ),
          validator: (valor) {
            if (valor == null || valor.isEmpty) {
              return 'La contraseña no puede estar vacía';
            }
            if (valor.length < 8) {
              return 'La contraseña debe tener al menos 8 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.acentoRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _enviarFormulario,
            child: const Text(
              'Conectar a esta Red',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
