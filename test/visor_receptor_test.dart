import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peerlens/caracteristicas/visor_receptor/pantalla_visor.dart';
import 'package:peerlens/caracteristicas/visor_receptor/widgets/escaner_qr_ap.dart';
import 'package:peerlens/caracteristicas/visor_receptor/widgets/hud_telemetria.dart';
import 'package:peerlens/caracteristicas/visor_receptor/widgets/reproductor_webrtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  testWidgets('HudTelemetria renderiza metricas y dispara callbacks', (
    WidgetTester tester,
  ) async {
    bool alternado = false;
    bool desconectado = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HudTelemetria(
            latenciaMs: 35,
            cuadrosPorSegundo: 30,
            resolucion: '1280x720',
            esPantallaCompleta: false,
            nombreCamara: 'Xiaomi Redmi Note',
            onAlternarPantallaCompleta: () => alternado = true,
            onDesconectar: () => desconectado = true,
          ),
        ),
      ),
    );

    expect(find.text('35 ms'), findsOneWidget);
    expect(find.text('30 FPS'), findsOneWidget);
    expect(find.text('1280x720'), findsOneWidget);
    expect(find.text('Xiaomi Redmi Note'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.fullscreen_rounded));
    await tester.pump();
    expect(alternado, isTrue);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump();
    expect(desconectado, isTrue);
  });

  testWidgets(
    'ReproductorWebRtc muestra estado de espera cuando no transmite',
    (WidgetTester tester) async {
      final renderizador = RTCVideoRenderer();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReproductorWebRtc(
              renderizador: renderizador,
              estaTransmitiendo: false,
              superposicion: const Text('Overlay Superpuesto'),
            ),
          ),
        ),
      );

      expect(find.text('Estableciendo Enlace WebRTC'), findsOneWidget);
      expect(find.text('Overlay Superpuesto'), findsOneWidget);
    },
  );

  testWidgets('EscanerQrAp permite alternar a entrada manual y enviar datos', (
    WidgetTester tester,
  ) async {
    String? urlDetectada;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EscanerQrAp(
            alDetectar: ({required ssid, required clave, required url}) {
              urlDetectada = url;
            },
          ),
        ),
      ),
    );

    expect(find.text('Escanear QR de Cámara'), findsOneWidget);
    expect(find.text('Manual'), findsOneWidget);

    await tester.tap(find.text('Manual'));
    await tester.pump();

    expect(find.text('Conexión Directa al Emisor'), findsOneWidget);
    expect(find.text('Conectar al Nodo'), findsOneWidget);

    await tester.tap(find.text('Conectar al Nodo'));
    await tester.pump();

    expect(urlDetectada, 'http://192.168.49.1:8080');
  });

  testWidgets('PantallaVisor renderiza interfaz de exploracion mDNS', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaVisor()));

    expect(find.text('PeerLens - Visor'), findsOneWidget);
    expect(find.text('Exploración de Red Local'), findsOneWidget);
    expect(find.text('Escanear QR'), findsOneWidget);
    expect(find.text('Conexión Directa por Dirección IP'), findsOneWidget);
  });
}
