import 'package:flutter/material.dart';
import 'caracteristicas/camara_emisor/pantalla_camara.dart';
import 'caracteristicas/seleccion_rol/pantalla_seleccion_rol.dart';
import 'caracteristicas/visor_receptor/pantalla_visor.dart';
import 'configuracion/tema/tema_app.dart';

// widget raiz de la aplicacion peerlens
class AplicacionPeerLens extends StatelessWidget {
  const AplicacionPeerLens({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeerLens',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.temaOscuro,
      home: const PantallaSeleccionRol(),
      routes: {
        '/camara': (context) => const PantallaCamara(),
        '/visor': (context) => const PantallaVisor(),
      },
    );
  }
}
