import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:wifi_iot/wifi_iot.dart';
import '../contratos/gestor_ap.dart';

// implementacion del gestor de punto de acceso y conectividad wifi para android
class GestorApAndroid implements GestorAp {
  @override
  bool get esPlataformaSoportada => !kIsWeb && Platform.isAndroid;

  // genera una clave alfanumerica segura de forma aleatoria
  static String generarClaveAleatoria({int longitud = 10}) {
    const caracteres = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final generador = Random.secure();
    return List.generate(
      longitud,
      (indice) => caracteres[generador.nextInt(caracteres.length)],
    ).join();
  }

  static String generarSsidAleatorio({String prefijo = 'PeerLens_AP'}) {
    final generador = Random.secure();
    final sufijo = generador.nextInt(9000) + 1000;
    return '${prefijo}_$sufijo';
  }

  @override
  Future<bool> estaPuntoAccesoHabilitado() async {
    if (!esPlataformaSoportada) {
      return false;
    }
    try {
      return await WiFiForIoTPlugin.isWiFiAPEnabled();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> habilitarPuntoAcceso({
    required String ssid,
    required String clave,
  }) async {
    if (!esPlataformaSoportada) {
      return false;
    }

    try {
      return await WiFiForIoTPlugin.setWiFiAPEnabled(true);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deshabilitarPuntoAcceso() async {
    if (!esPlataformaSoportada) {
      return false;
    }

    try {
      return await WiFiForIoTPlugin.setWiFiAPEnabled(false);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> conectarARedLan({
    required String ssid,
    required String clave,
  }) async {
    if (!esPlataformaSoportada) {
      return false;
    }

    try {
      await deshabilitarPuntoAcceso();
      return await WiFiForIoTPlugin.connect(
        ssid,
        password: clave,
        security: NetworkSecurity.WPA,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> desconectarDeRedLan() async {
    if (!esPlataformaSoportada) {
      return false;
    }

    try {
      return await WiFiForIoTPlugin.disconnect();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> obtenerDireccionIpLocal() async {
    if (!esPlataformaSoportada) {
      return null;
    }

    try {
      return await WiFiForIoTPlugin.getIP();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> obtenerSsidActual() async {
    if (!esPlataformaSoportada) {
      return null;
    }

    try {
      return await WiFiForIoTPlugin.getSSID();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> escanearRedesDisponibles() async {
    if (!esPlataformaSoportada) {
      return [];
    }

    try {
      // ignore: deprecated_member_use
      final redes = await WiFiForIoTPlugin.loadWifiList();
      final conjunto = <String>{};
      for (final red in redes) {
        final nombre = red.ssid;
        if (nombre != null &&
            nombre.trim().isNotEmpty &&
            nombre != '<unknown ssid>') {
          conjunto.add(nombre.trim());
        }
      }
      return conjunto.toList();
    } catch (_) {
      return [];
    }
  }
}
