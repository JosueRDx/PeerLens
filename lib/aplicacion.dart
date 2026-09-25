import 'package:flutter/material.dart';
import 'nucleo/tema/tema_aplicacion.dart';

// widget raiz de la aplicacion peerlens
class AplicacionPeerLens extends StatelessWidget {
  const AplicacionPeerLens({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeerLens',
      debugShowCheckedModeBanner: false,
      theme: TemaAplicacion.temaOscuro,
      home: const Scaffold(body: Center(child: Text('PeerLens'))),
    );
  }
}
