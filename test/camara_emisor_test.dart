import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peerlens/caracteristicas/camara_emisor/widgets/visor_qr_ap.dart';
import 'package:peerlens/caracteristicas/camara_emisor/widgets/botonera_control.dart';
import 'package:peerlens/caracteristicas/camara_emisor/pantalla_camara.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VisorQrAp', () {
    testWidgets('Renderiza datos de conexion y URL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VisorQrAp(ssid: 'PeerLens_Test', clave: 'pass1234'),
          ),
        ),
      );

      expect(find.text('SSID: PeerLens_Test'), findsOneWidget);
      expect(find.text('Clave: pass1234'), findsOneWidget);
      expect(find.text('http://192.168.49.1:8080'), findsOneWidget);
    });
  });

  group('BotoneraControl', () {
    testWidgets('Renderiza botones y dispara callbacks', (tester) async {
      var presionoWifi = false;
      var presionoReiniciar = false;
      var presionoReset = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BotoneraControl(
              alPresionarConectarWifi: () => presionoWifi = true,
              alPresionarReiniciarServidor: () => presionoReiniciar = true,
              alPresionarResetearRed: () => presionoReset = true,
            ),
          ),
        ),
      );

      expect(find.text('Conectar a Wi-Fi'), findsOneWidget);
      expect(find.text('Reiniciar Servidor'), findsOneWidget);
      expect(find.text('Olvidar Red / Reset'), findsOneWidget);

      await tester.tap(find.text('Conectar a Wi-Fi'));
      expect(presionoWifi, isTrue);

      await tester.tap(find.text('Reiniciar Servidor'));
      expect(presionoReiniciar, isTrue);

      await tester.tap(find.text('Olvidar Red / Reset'));
      expect(presionoReset, isTrue);
    });
  });

  group('PantallaCamara', () {
    testWidgets('Renderiza dashboard de camara con HUD de metricas', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PantallaCamara()));
      await tester.pump();

      expect(find.text('Cámara Emisora'), findsOneWidget);
      expect(find.text('Modo AP'), findsOneWidget);
      expect(find.text('Resolución'), findsOneWidget);
      expect(find.text('Velocidad'), findsOneWidget);
      expect(find.text('Receptores'), findsOneWidget);
      expect(find.text('Conectar a Wi-Fi'), findsOneWidget);
    });
  });
}
