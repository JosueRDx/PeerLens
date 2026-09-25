import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerlens/caracteristicas/red/contratos/gestor_ap.dart';
import 'package:peerlens/caracteristicas/red/contratos/servicio_mdns.dart';
import 'package:peerlens/caracteristicas/servidor/contratos/servidor_red.dart';
import 'package:peerlens/caracteristicas/transmision/contratos/gestor_webrtc.dart';
import 'package:peerlens/caracteristicas/transmision/modelos/configuracion_video.dart';
import 'package:peerlens/nucleo/almacenamiento/repositorio_almacenamiento.dart';
import 'package:peerlens/nucleo/modelos/credencial_red.dart';
import 'package:peerlens/nucleo/modelos/estado_nodo.dart';
import 'package:peerlens/nucleo/orquestacion/orquestador_p2p.dart';

class GestorApFalso implements GestorAp {
  bool apHabilitado = false;
  bool conectadoLan = false;
  String? ipFalsa = '192.168.1.100';

  @override
  bool get esPlataformaSoportada => true;

  @override
  Future<bool> estaPuntoAccesoHabilitado() async => apHabilitado;

  @override
  Future<bool> habilitarPuntoAcceso({
    required String ssid,
    required String clave,
  }) async {
    apHabilitado = true;
    conectadoLan = false;
    return true;
  }

  @override
  Future<bool> deshabilitarPuntoAcceso() async {
    apHabilitado = false;
    return true;
  }

  @override
  Future<bool> conectarARedLan({
    required String ssid,
    required String clave,
  }) async {
    conectadoLan = true;
    apHabilitado = false;
    return true;
  }

  @override
  Future<bool> desconectarDeRedLan() async {
    conectadoLan = false;
    return true;
  }

  @override
  Future<String?> obtenerDireccionIpLocal() async =>
      conectadoLan ? ipFalsa : null;

  @override
  Future<String?> obtenerSsidActual() async => conectadoLan ? 'MiWifi' : null;
}

class ServidorRedFalso implements ServidorRed {
  bool activo = false;

  @override
  bool get estaActivo => activo;

  @override
  int? get puertoActivo => activo ? 8080 : null;

  @override
  Stream<String> get flujoEventos => const Stream.empty();

  @override
  Future<void> iniciar({int puerto = 8080}) async {
    activo = true;
  }

  @override
  Future<void> detener() async {
    activo = false;
  }
}

class ServicioMdnsFalso implements ServicioMdns {
  bool registrado = false;

  @override
  bool get estaRegistrado => registrado;

  @override
  bool get estaExplorando => false;

  @override
  Stream<List<NodoDescubierto>> get flujoNodos => const Stream.empty();

  @override
  Future<void> registrarServicio({
    required String nombre,
    required String tipo,
    required int puerto,
  }) async {
    registrado = true;
  }

  @override
  Future<void> desregistrarServicio() async {
    registrado = false;
  }

  @override
  Future<void> iniciarExploracion({required String tipo}) async {}

  @override
  Future<void> detenerExploracion() async {}
}

class GestorWebRtcFalso implements GestorWebRtc {
  bool inicializado = false;

  @override
  RTCVideoRenderer get renderizador => RTCVideoRenderer();

  @override
  EstadoConexionP2p get estadoActual => EstadoConexionP2p.inicial;

  @override
  Stream<EstadoConexionP2p> get flujoEstado => const Stream.empty();

  @override
  Stream<RTCIceCandidate> get flujoCandidatoIce => const Stream.empty();

  @override
  Future<void> inicializarRenderizador() async {
    inicializado = true;
  }

  @override
  Future<RTCSessionDescription> crearOferta() async =>
      RTCSessionDescription('', 'offer');

  @override
  Future<RTCSessionDescription> crearRespuesta() async =>
      RTCSessionDescription('', 'answer');

  @override
  Future<void> establecerDescripcionRemota(
    RTCSessionDescription descripcion,
  ) async {}

  @override
  Future<void> agregarCandidatoIce(RTCIceCandidate candidato) async {}

  @override
  Future<void> liberarRecursos() async {}
}

class RepositorioAlmacenamientoFalso implements RepositorioAlmacenamiento {
  CredencialRed? credencialGuardada;
  String? rolGuardado;

  @override
  Future<void> guardarCredencialRed(CredencialRed credencial) async {
    credencialGuardada = credencial;
  }

  @override
  Future<CredencialRed?> obtenerCredencialRed() async => credencialGuardada;

  @override
  Future<void> eliminarCredencialRed() async {
    credencialGuardada = null;
  }

  @override
  Future<void> guardarRolPreferido(String rol) async {
    rolGuardado = rol;
  }

  @override
  Future<String?> obtenerRolPreferido() async => rolGuardado;

  @override
  Future<void> limpiarTodo() async {
    credencialGuardada = null;
    rolGuardado = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'OrquestadorP2p activa modo AP por defecto si no existen credenciales',
    () async {
      final gestorAp = GestorApFalso();
      final servidor = ServidorRedFalso();
      final mdns = ServicioMdnsFalso();
      final webrtc = GestorWebRtcFalso();
      final repo = RepositorioAlmacenamientoFalso();

      final orquestador = OrquestadorP2p(
        gestorAp: gestorAp,
        servidorRed: servidor,
        servicioMdns: mdns,
        motorEmisor: webrtc,
        almacenamiento: repo,
      );

      await orquestador.iniciar();

      expect(orquestador.estadoActual.estado, TipoEstadoNodo.modoAp);
      expect(gestorAp.apHabilitado, isTrue);
      expect(servidor.activo, isTrue);
      expect(mdns.registrado, isTrue);
      expect(webrtc.inicializado, isTrue);
    },
  );

  test(
    'OrquestadorP2p se conecta a LAN si encuentra credenciales previas',
    () async {
      final gestorAp = GestorApFalso();
      final servidor = ServidorRedFalso();
      final mdns = ServicioMdnsFalso();
      final webrtc = GestorWebRtcFalso();
      final repo = RepositorioAlmacenamientoFalso()
        ..credencialGuardada = CredencialRed(
          nombreRed: 'RedCasa',
          claveRed: '12345678',
          fechaGuardado: DateTime.now(),
        );

      final orquestador = OrquestadorP2p(
        gestorAp: gestorAp,
        servidorRed: servidor,
        servicioMdns: mdns,
        motorEmisor: webrtc,
        almacenamiento: repo,
      );

      await orquestador.iniciar();

      expect(orquestador.estadoActual.estado, TipoEstadoNodo.enLineaLan);
      expect(gestorAp.conectadoLan, isTrue);
      expect(orquestador.estadoActual.direccionIp, '192.168.1.100');
    },
  );

  test('OrquestadorP2p aprovisiona nueva red y conecta', () async {
    final gestorAp = GestorApFalso();
    final servidor = ServidorRedFalso();
    final mdns = ServicioMdnsFalso();
    final webrtc = GestorWebRtcFalso();
    final repo = RepositorioAlmacenamientoFalso();

    final orquestador = OrquestadorP2p(
      gestorAp: gestorAp,
      servidorRed: servidor,
      servicioMdns: mdns,
      motorEmisor: webrtc,
      almacenamiento: repo,
    );

    await orquestador.iniciar();
    expect(orquestador.estadoActual.estado, TipoEstadoNodo.modoAp);

    await orquestador.aprovisionarNuevaRed('WifiOficina', 'claveSegura123');

    expect(repo.credencialGuardada?.nombreRed, 'WifiOficina');
    expect(orquestador.estadoActual.estado, TipoEstadoNodo.enLineaLan);
  });

  test('OrquestadorP2p olvida red y retorna a modo AP', () async {
    final gestorAp = GestorApFalso();
    final servidor = ServidorRedFalso();
    final mdns = ServicioMdnsFalso();
    final webrtc = GestorWebRtcFalso();
    final repo = RepositorioAlmacenamientoFalso()
      ..credencialGuardada = CredencialRed(
        nombreRed: 'RedVieja',
        claveRed: 'password99',
        fechaGuardado: DateTime.now(),
      );

    final orquestador = OrquestadorP2p(
      gestorAp: gestorAp,
      servidorRed: servidor,
      servicioMdns: mdns,
      motorEmisor: webrtc,
      almacenamiento: repo,
    );

    await orquestador.iniciar();
    expect(orquestador.estadoActual.estado, TipoEstadoNodo.enLineaLan);

    await orquestador.olvidarRedYRetornarAp();

    expect(repo.credencialGuardada, isNull);
    expect(orquestador.estadoActual.estado, TipoEstadoNodo.modoAp);
    expect(gestorAp.apHabilitado, isTrue);
  });
}
