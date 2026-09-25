import 'dart:async';
import 'package:nsd/nsd.dart' as nsd;
import '../contratos/servicio_mdns.dart';

// implementacion del servicio mdns utilizando la libreria nsd
class ServicioMdnsNsd implements ServicioMdns {
  static const String tipoServicioP2p = '_camera-p2p._tcp';
  static const String nombreServicioCamara = 'camera-device';
  static const int puertoServidorDefecto = 8080;

  nsd.Registration? _registroActivo;
  nsd.Discovery? _exploracionActiva;
  final Map<String, NodoDescubierto> _nodosRegistrados = {};

  final StreamController<List<NodoDescubierto>> _controladorNodos =
      StreamController<List<NodoDescubierto>>.broadcast();

  @override
  bool get estaRegistrado => _registroActivo != null;

  @override
  bool get estaExplorando => _exploracionActiva != null;

  @override
  Stream<List<NodoDescubierto>> get flujoNodos => _controladorNodos.stream;

  Future<void> registrarServicioCamaraDefecto({
    int puerto = puertoServidorDefecto,
  }) async {
    await registrarServicio(
      nombre: nombreServicioCamara,
      tipo: tipoServicioP2p,
      puerto: puerto,
    );
  }

  @override
  Future<void> registrarServicio({
    required String nombre,
    required String tipo,
    required int puerto,
  }) async {
    if (estaRegistrado) {
      await desregistrarServicio();
    }

    final servicio = nsd.Service(name: nombre, type: tipo, port: puerto);

    _registroActivo = await nsd.register(servicio);
  }

  @override
  Future<void> desregistrarServicio() async {
    if (_registroActivo != null) {
      await nsd.unregister(_registroActivo!);
      _registroActivo = null;
    }
  }

  Future<void> iniciarExploracionCamaras() async {
    await iniciarExploracion(tipo: tipoServicioP2p);
  }

  @override
  Future<void> iniciarExploracion({required String tipo}) async {
    if (estaExplorando) {
      await detenerExploracion();
    }

    _nodosRegistrados.clear();

    _exploracionActiva = await nsd.startDiscovery(
      tipo,
      ipLookupType: nsd.IpLookupType.v4,
    );

    _exploracionActiva!.addServiceListener((servicio, estado) {
      if (estado == nsd.ServiceStatus.found) {
        final nodo = _mapearANodo(servicio);
        _nodosRegistrados[nodo.nombre] = nodo;
        _controladorNodos.add(_nodosRegistrados.values.toList());
      } else if (estado == nsd.ServiceStatus.lost) {
        if (servicio.name != null) {
          _nodosRegistrados.remove(servicio.name);
          _controladorNodos.add(_nodosRegistrados.values.toList());
        }
      }
    });
  }

  @override
  Future<void> detenerExploracion() async {
    if (_exploracionActiva != null) {
      await nsd.stopDiscovery(_exploracionActiva!);
      _exploracionActiva = null;
    }
  }

  // mapea un servicio de red descubierto hacia la entidad nodo descubierto
  NodoDescubierto _mapearANodo(nsd.Service servicio) {
    String? ipResuelta;
    if (servicio.addresses != null && servicio.addresses!.isNotEmpty) {
      ipResuelta = servicio.addresses!.first.address;
    } else if (servicio.host != null) {
      ipResuelta = servicio.host;
    }

    return NodoDescubierto(
      nombre: servicio.name ?? 'dispositivo_desconocido',
      tipo: servicio.type ?? tipoServicioP2p,
      direccionIp: ipResuelta,
      puerto: servicio.port,
    );
  }

  Future<void> liberarRecursos() async {
    await desregistrarServicio();
    await detenerExploracion();
    await _controladorNodos.close();
  }
}
