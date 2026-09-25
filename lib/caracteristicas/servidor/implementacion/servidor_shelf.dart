import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import '../contratos/servidor_red.dart';
import '../controladores/controlador_aprovisionamiento.dart';
import '../controladores/controlador_senalizacion.dart';

// orquestador del servidor local con pipeline de middlewares y enrutamiento
class ServidorShelf implements ServidorRed {
  final ControladorAprovisionamiento controladorAprovisionamiento;
  final ControladorSenalizacion controladorSenalizacion;

  final StreamController<String> _controladorEventos =
      StreamController<String>.broadcast();
  HttpServer? _servidorHttp;

  ServidorShelf({
    required this.controladorAprovisionamiento,
    required this.controladorSenalizacion,
  });

  @override
  bool get estaActivo => _servidorHttp != null;

  @override
  int? get puertoActivo => _servidorHttp?.port;

  @override
  Stream<String> get flujoEventos => _controladorEventos.stream;

  @override
  Future<void> iniciar({int puerto = 8080}) async {
    if (estaActivo) {
      _controladorEventos.add('El servidor ya se encuentra activo');
      return;
    }

    try {
      final enrutadorPrincipal = Router();

      enrutadorPrincipal.mount(
        '/api',
        controladorAprovisionamiento.enrutador.call,
      );

      enrutadorPrincipal.all('/ws', controladorSenalizacion.manejador);

      enrutadorPrincipal.get('/salud', (Request peticion) {
        return Response.ok(
          '{"estado":"activo"}',
          headers: {'content-type': 'application/json'},
        );
      });

      final pipeline = const Pipeline()
          .addMiddleware(_crearMiddlewareCors())
          .addMiddleware(_crearMiddlewareRegistro())
          .addHandler(enrutadorPrincipal.call);

      _servidorHttp = await io.serve(pipeline, InternetAddress.anyIPv4, puerto);

      _controladorEventos.add(
        'Servidor activo en el puerto ${_servidorHttp!.port}',
      );
    } catch (error) {
      _controladorEventos.add('Error al iniciar el servidor: $error');
      rethrow;
    }
  }

  @override
  Future<void> detener() async {
    if (_servidorHttp == null) {
      return;
    }

    try {
      await controladorSenalizacion.cerrarCanales();
      await _servidorHttp!.close(force: true);
      _servidorHttp = null;
      _controladorEventos.add('Servidor detenido correctamente');
    } catch (error) {
      _controladorEventos.add('Error al detener el servidor: $error');
      rethrow;
    }
  }

  // middleware para soporte de solicitudes de origen cruzado
  static Middleware _crearMiddlewareCors() {
    const cabecerasCors = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
    };

    return (Handler manejador) {
      return (Request peticion) async {
        if (peticion.method == 'OPTIONS') {
          return Response.ok('', headers: cabecerasCors);
        }

        final respuesta = await manejador(peticion);
        return respuesta.change(headers: cabecerasCors);
      };
    };
  }

  // middleware de registro basico de peticiones entrantes
  Middleware _crearMiddlewareRegistro() {
    return (Handler manejador) {
      return (Request peticion) async {
        _controladorEventos.add(
          'Peticion recibida: ${peticion.method} ${peticion.url.path}',
        );
        return manejador(peticion);
      };
    };
  }
}
