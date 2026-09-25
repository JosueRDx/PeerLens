import 'package:flutter/material.dart';
import '../../../configuracion/tema/colores.dart';

// modal inferior para el ingreso y configuracion de credenciales wifi domesticas
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
  bool _ocultarClave = true;

  @override
  void dispose() {
    _controladorSsid.dispose();
    _controladorClave.dispose();
    super.dispose();
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
            const Text(
              'Conectar a Red Wi-Fi',
              style: TextStyle(
                color: ColoresApp.textoPrimario,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ingresa los datos de tu red domestica para vincular la camara',
              style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _controladorSsid,
              style: const TextStyle(color: ColoresApp.textoPrimario),
              decoration: InputDecoration(
                labelText: 'Nombre de Red (SSID)',
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
            const SizedBox(height: 16),
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
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: ColoresApp.textoSecundario,
                  ),
                  onPressed: () =>
                      setState(() => _ocultarClave = !_ocultarClave),
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
                if (valor == null || valor.length < 8) {
                  return 'Minimo 8 caracteres para WPA2';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.acentoRed,
                  foregroundColor: ColoresApp.fondoPrimario,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _enviarFormulario,
                child: const Text(
                  'Conectar y Guardar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
