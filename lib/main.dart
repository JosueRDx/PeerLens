import 'package:flutter/material.dart';
import 'aplicacion.dart';

// punto de entrada principal de la aplicacion
void main() {
  // asegura la inicializacion de los enlaces del framework
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AplicacionPeerLens());
}
