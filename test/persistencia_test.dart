import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peerlens/nucleo/modelos/credencial_red.dart';
import 'package:peerlens/nucleo/modelos/estado_nodo.dart';
import 'package:peerlens/nucleo/almacenamiento/servicio_almacenamiento_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de modelos de red y estado', () {
    test('Serializacion y deserializacion de CredencialRed', () {
      final fecha = DateTime.parse('2026-09-25T12:00:00.000Z');
      final credencial = CredencialRed(
        nombreRed: 'PeerLens_AP',
        claveRed: '12345678',
        fechaGuardado: fecha,
      );

      final json = credencial.toJson();
      final reconstruida = CredencialRed.fromJson(json);

      expect(reconstruida.nombreRed, 'PeerLens_AP');
      expect(reconstruida.claveRed, '12345678');
      expect(reconstruida.fechaGuardado, fecha);
    });

    test('Serializacion y deserializacion de EstadoNodo', () {
      final fecha = DateTime.parse('2026-09-25T12:00:00.000Z');
      final estado = EstadoNodo(
        estado: TipoEstadoNodo.modoAp,
        direccionIp: '192.168.49.1',
        mensajeDetalle: 'Punto de acceso activo',
        actualizadoEn: fecha,
      );

      final json = estado.toJson();
      final reconstruido = EstadoNodo.fromJson(json);

      expect(reconstruido.estado, TipoEstadoNodo.modoAp);
      expect(reconstruido.direccionIp, '192.168.49.1');
      expect(reconstruido.mensajeDetalle, 'Punto de acceso activo');
      expect(reconstruido.actualizadoEn, fecha);
    });
  });

  group('Pruebas de ServicioAlmacenamientoLocal', () {
    late ServicioAlmacenamientoLocal servicio;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Guardar, recuperar y eliminar credencial de red', () async {
      final preferencias = await SharedPreferences.getInstance();
      servicio = ServicioAlmacenamientoLocal(preferencias);

      final fecha = DateTime.parse('2026-09-25T12:00:00.000Z');
      final credencial = CredencialRed(
        nombreRed: 'RedPrueba',
        claveRed: 'claveSegura123',
        fechaGuardado: fecha,
      );

      await servicio.guardarCredencialRed(credencial);
      final recuperada = await servicio.obtenerCredencialRed();

      expect(recuperada, isNotNull);
      expect(recuperada!.nombreRed, 'RedPrueba');
      expect(recuperada.claveRed, 'claveSegura123');

      await servicio.eliminarCredencialRed();
      final despuesDeEliminar = await servicio.obtenerCredencialRed();
      expect(despuesDeEliminar, isNull);
    });

    test('Guardar y obtener rol preferido', () async {
      final preferencias = await SharedPreferences.getInstance();
      servicio = ServicioAlmacenamientoLocal(preferencias);

      await servicio.guardarRolPreferido('emisor');
      final rol = await servicio.obtenerRolPreferido();

      expect(rol, 'emisor');
    });
  });
}
