import 'package:flutter/material.dart';
import '../../../configuracion/tema/colores.dart';

// vista principal del modo receptor y visor de transmision
class PaginaReceptorVisor extends StatelessWidget {
  const PaginaReceptorVisor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo Visor Receptor')),
      body: const Center(
        child: Text(
          'Esperando conexión de cámara remota',
          style: TextStyle(color: ColoresApp.textoSecundario),
        ),
      ),
    );
  }
}
