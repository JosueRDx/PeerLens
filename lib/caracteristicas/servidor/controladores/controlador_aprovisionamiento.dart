import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../nucleo/modelos/credencial_red.dart';
import '../../../nucleo/modelos/estado_nodo.dart';

// controlador de endpoints para aprovisionamiento de credenciales y telemetria
class ControladorAprovisionamiento {
  final Future<void> Function(CredencialRed)? alRecibirCredencial;
  final Future<EstadoNodo> Function()? alConsultarEstado;

  ControladorAprovisionamiento({
    this.alRecibirCredencial,
    this.alConsultarEstado,
  });

  Router get enrutador {
    final router = Router();

    router.post('/configurar-wifi', _manejarConfigurarWifi);
    router.get('/estado', _manejarEstado);

    return router;
  }

  Future<Response> _manejarConfigurarWifi(Request peticion) async {
    try {
      final cuerpoCadena = await peticion.readAsString();
      if (cuerpoCadena.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Cuerpo de solicitud vacio'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final mapa = jsonDecode(cuerpoCadena) as Map<String, dynamic>;
      final nombreRed = mapa['nombreRed'] as String?;
      final claveRed = mapa['claveRed'] as String?;

      if (nombreRed == null || nombreRed.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'El nombreRed es obligatorio'}),
          headers: {'content-type': 'application/json'},
        );
      }

      if (claveRed == null || claveRed.length < 8) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'La claveRed debe contener un minimo de 8 caracteres',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final credencial = CredencialRed(
        nombreRed: nombreRed.trim(),
        claveRed: claveRed,
        fechaGuardado: DateTime.now(),
      );

      if (alRecibirCredencial != null) {
        await alRecibirCredencial!(credencial);
      }

      return Response.ok(
        jsonEncode({
          'mensaje': 'Configuracion wifi procesada exitosamente',
          'nombreRed': credencial.nombreRed,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (error) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Fallo al procesar configuracion wifi'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _manejarEstado(Request peticion) async {
    try {
      EstadoNodo estadoActual;
      if (alConsultarEstado != null) {
        estadoActual = await alConsultarEstado!();
      } else {
        estadoActual = EstadoNodo(
          estado: TipoEstadoNodo.modoAp,
          direccionIp: '192.168.49.1',
          mensajeDetalle: 'Nodo emisor activo en espera de clientes',
          actualizadoEn: DateTime.now(),
        );
      }

      return Response.ok(
        estadoActual.toJson(),
        headers: {'content-type': 'application/json'},
      );
    } catch (error) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Fallo al obtener estado del nodo'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
