import 'package:flutter_test/flutter_test.dart';
import 'package:peerlens/caracteristicas/red/contratos/servicio_mdns.dart';
import 'package:peerlens/caracteristicas/red/implementacion/gestor_ap_android.dart';
import 'package:peerlens/caracteristicas/red/implementacion/servicio_mdns_nsd.dart';

void main() {
  group('GestorApAndroid', () {
    test('Generacion de SSID con formato esperado', () {
      final ssid = GestorApAndroid.generarSsidAleatorio();
      expect(ssid.startsWith('PeerLens_AP_'), isTrue);
      expect(ssid.length, greaterThan(12));
    });

    test('Generacion de clave aleatoria con longitud configurada', () {
      final clave10 = GestorApAndroid.generarClaveAleatoria(longitud: 10);
      final clave16 = GestorApAndroid.generarClaveAleatoria(longitud: 16);

      expect(clave10.length, 10);
      expect(clave16.length, 16);
      expect(clave10, isNot(equals(clave16)));
    });
  });

  group('ServicioMdns y NodoDescubierto', () {
    test('Constantes de servicio mDNS para PeerLens', () {
      expect(ServicioMdnsNsd.tipoServicioP2p, '_camera-p2p._tcp');
      expect(ServicioMdnsNsd.nombreServicioCamara, 'camera-device');
      expect(ServicioMdnsNsd.puertoServidorDefecto, 8080);
    });

    test('Instanciacion de entidad NodoDescubierto', () {
      const nodo = NodoDescubierto(
        nombre: 'camera-device',
        tipo: '_camera-p2p._tcp',
        direccionIp: '192.168.49.1',
        puerto: 8080,
      );

      expect(nodo.nombre, 'camera-device');
      expect(nodo.tipo, '_camera-p2p._tcp');
      expect(nodo.direccionIp, '192.168.49.1');
      expect(nodo.puerto, 8080);
    });
  });
}
