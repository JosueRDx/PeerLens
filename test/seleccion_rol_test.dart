import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peerlens/compartido/widgets/badge_estado.dart';
import 'package:peerlens/caracteristicas/seleccion_rol/widgets/tarjeta_rol.dart';
import 'package:peerlens/caracteristicas/seleccion_rol/pantalla_seleccion_rol.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BadgeEstado', () {
    testWidgets('Renderiza etiqueta correctamente', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BadgeEstado(
              etiqueta: 'En línea',
              tipo: TipoEstadoBadge.activo,
            ),
          ),
        ),
      );

      expect(find.text('En línea'), findsOneWidget);
    });
  });

  group('TarjetaRol', () {
    testWidgets('Renderiza titulo y descripcion y responde a toques', (
      tester,
    ) async {
      var fuePresionado = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarjetaRol(
              titulo: 'Modo Cámara',
              descripcion: 'Transmite el video',
              icono: Icons.videocam,
              alSeleccionar: () => fuePresionado = true,
            ),
          ),
        ),
      );

      expect(find.text('Modo Cámara'), findsOneWidget);
      expect(find.text('Transmite el video'), findsOneWidget);

      await tester.tap(find.byType(TarjetaRol));
      await tester.pump();

      expect(fuePresionado, isTrue);
    });
  });

  group('PantallaSeleccionRol', () {
    testWidgets('Renderiza opciones principales y checkbox de recordar', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PantallaSeleccionRol()));
      await tester.pumpAndSettle();

      expect(find.text('PeerLens'), findsOneWidget);
      expect(find.text('LAN Activa'), findsOneWidget);
      expect(find.text('Modo Cámara'), findsOneWidget);
      expect(find.text('Modo Visor'), findsOneWidget);
      expect(
        find.text('Recordar mi eleccion en este dispositivo'),
        findsOneWidget,
      );
    });
  });
}
