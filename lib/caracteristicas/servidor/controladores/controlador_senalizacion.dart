import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// controlador de canal websocket para intercambio bidireccional de senales webrtc
class ControladorSenalizacion {
  final Set<WebSocketChannel> _canalesConectados = {};
  final StreamController<String> _controladorMensajes =
      StreamController<String>.broadcast();
  final StreamController<String> _controladorEventos =
      StreamController<String>.broadcast();

  Stream<String> get flujoMensajes => _controladorMensajes.stream;
  Stream<String> get flujoEventos => _controladorEventos.stream;
  int get cantidadConexionesActivas => _canalesConectados.length;

  Handler get manejador {
    return webSocketHandler((WebSocketChannel canal, String? subprotocolo) {
      _canalesConectados.add(canal);
      _controladorEventos.add('Cliente websocket conectado');

      canal.stream.listen(
        (datos) {
          final mensaje = datos.toString();
          _controladorMensajes.add(mensaje);
          // retransmite el mensaje hacia los demas clientes conectados
          retransmitir(mensaje, remitenteExcluido: canal);
        },
        onDone: () {
          _canalesConectados.remove(canal);
          _controladorEventos.add('Cliente websocket desconectado');
        },
        onError: (error) {
          _canalesConectados.remove(canal);
          _controladorEventos.add('Error en sesion websocket: $error');
        },
      );
    });
  }

  void retransmitir(String mensaje, {WebSocketChannel? remitenteExcluido}) {
    for (final canal in _canalesConectados) {
      if (canal != remitenteExcluido) {
        canal.sink.add(mensaje);
      }
    }
  }

  void emitirDesdeServidor(String mensaje) {
    retransmitir(mensaje);
  }

  Future<void> cerrarCanales() async {
    for (final canal in _canalesConectados) {
      await canal.sink.close();
    }
    _canalesConectados.clear();
  }

  Future<void> liberarRecursos() async {
    await cerrarCanales();
    await _controladorMensajes.close();
    await _controladorEventos.close();
  }
}
