import 'package:flutter/material.dart';
import '../../../configuracion/tema/colores.dart';

// vista principal del modo emisor de camara
class PaginaEmisorCamara extends StatelessWidget {
  const PaginaEmisorCamara({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo Cámara Emisor')),
      body: const Center(
        child: Text(
          'Feed de cámara local en espera de inicialización',
          style: TextStyle(color: ColoresApp.textoSecundario),
        ),
      ),
    );
  }
}
