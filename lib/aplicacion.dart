import 'package:flutter/material.dart';
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
      home: const Scaffold(
        body: Center(
          child: Text('PeerLens'),
        ),
      ),
    );
  }
}
