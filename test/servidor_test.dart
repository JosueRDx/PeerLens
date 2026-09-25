import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';
import 'package:peerlens/nucleo/modelos/credencial_red.dart';
import 'package:peerlens/nucleo/modelos/estado_nodo.dart';
import 'package:peerlens/caracteristicas/servidor/controladores/controlador_aprovisionamiento.dart';
import 'package:peerlens/caracteristicas/servidor/controladores/controlador_senalizacion.dart';
import 'package:peerlens/caracteristicas/servidor/implementacion/servidor_shelf.dart';

void main() {
  group('ControladorAprovisionamiento', () {
    late ControladorAprovisionamiento controlador;
    CredencialRed? credencialCapturada;

    setUp(() {
      credencialCapturada = null;
      controlador = ControladorAprovisionamiento(
        alRecibirCredencial: (credencial) async {
          credencialCapturada = credencial;
        },
        alConsultarEstado: () async {
          return EstadoNodo(
            estado: TipoEstadoNodo.modoAp,
            direccionIp: '192.168.49.1',
            mensajeDetalle: 'Activo',
            actualizadoEn: DateTime.parse('2026-09-25T12:00:00.000Z'),
          );
        },
      );
    });

    test('POST /configurar-wifi con datos validos', () async {
      final peticion = Request(
        'POST',
        Uri.parse('http://localhost/configurar-wifi'),
        body: jsonEncode({
          'nombreRed': 'PeerLens_Wifi',
          'claveRed': 'seguridad123',
        }),
      );

      final respuesta = await controlador.enrutador.call(peticion);

      expect(respuesta.statusCode, 200);
      expect(credencialCapturada, isNotNull);
      expect(credencialCapturada!.nombreRed, 'PeerLens_Wifi');
      expect(credencialCapturada!.claveRed, 'seguridad123');
    });

    test('POST /configurar-wifi con clave corta rechaza con 400', () async {
      final peticion = Request(
        'POST',
        Uri.parse('http://localhost/configurar-wifi'),
        body: jsonEncode({'nombreRed': 'PeerLens_Wifi', 'claveRed': '123'}),
      );

      final respuesta = await controlador.enrutador.call(peticion);

      expect(respuesta.statusCode, 400);
      expect(credencialCapturada, isNull);
    });

    test('GET /estado devuelve estado serializado', () async {
      final peticion = Request('GET', Uri.parse('http://localhost/estado'));

      final respuesta = await controlador.enrutador.call(peticion);
      final cuerpo = await respuesta.readAsString();
      final mapa = jsonDecode(cuerpo) as Map<String, dynamic>;

      expect(respuesta.statusCode, 200);
      expect(mapa['estado'], 'modoAp');
      expect(mapa['direccionIp'], '192.168.49.1');
    });
  });

  group('ServidorShelf ciclo de vida', () {
    test('Iniciar y detener servidor en puerto libre', () async {
      final controladorAprovisionamiento = ControladorAprovisionamiento();
      final controladorSenalizacion = ControladorSenalizacion();
      final servidor = ServidorShelf(
        controladorAprovisionamiento: controladorAprovisionamiento,
        controladorSenalizacion: controladorSenalizacion,
      );

      expect(servidor.estaActivo, isFalse);

      await servidor.iniciar(puerto: 0);
      expect(servidor.estaActivo, isTrue);
      expect(servidor.puertoActivo, isNotNull);

      await servidor.detener();
      expect(servidor.estaActivo, isFalse);
    });
  });
}
