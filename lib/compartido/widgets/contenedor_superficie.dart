import 'package:flutter/material.dart';
import '../../configuracion/tema/colores.dart';

// contenedor base modular con estilo de superficie de alta tecnologia
class ContenedorSuperficie extends StatelessWidget {
  final Widget? hijo;
  final EdgeInsetsGeometry? relleno;
  final EdgeInsetsGeometry? margen;
  final double? ancho;
  final double? alto;
  final BorderRadius? radioBorde;
  final VoidCallback? alPresionar;

  const ContenedorSuperficie({
    super.key,
    this.hijo,
    this.relleno,
    this.margen,
    this.ancho,
    this.alto,
    this.radioBorde,
    this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    final radioEfectivo = radioBorde ?? BorderRadius.circular(12);

    final decoracion = BoxDecoration(
      color: ColoresApp.fondoSuperficie,
      borderRadius: radioEfectivo,
      border: Border.all(color: ColoresApp.bordeSuperficie, width: 1),
    );

    if (alPresionar != null) {
      return Container(
        width: ancho,
        height: alto,
        margin: margen,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radioEfectivo,
            onTap: alPresionar,
            child: Ink(decoration: decoracion, padding: relleno, child: hijo),
          ),
        ),
      );
    }

    return Container(
      width: ancho,
      height: alto,
      margin: margen,
      padding: relleno,
      decoration: decoracion,
      child: hijo,
    );
  }
}
