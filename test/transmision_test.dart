import 'package:flutter_test/flutter_test.dart';
import 'package:peerlens/caracteristicas/transmision/modelos/configuracion_video.dart';

void main() {
  group('ConfiguracionVideo', () {
    test('Perfil 720p genera restricciones correctas', () {
      const config = ConfiguracionVideo.altaDefinicion720p();

      expect(config.ancho, 1280);
      expect(config.alto, 720);
      expect(config.cuadrosPorSegundo, 30);
      expect(config.audioHabilitado, isFalse);

      final restricciones = config.aRestriccionesMedios(
        usarCamaraFrontal: false,
      );
      final video = restricciones['video'] as Map<String, dynamic>;
      final mandatory = video['mandatory'] as Map<String, dynamic>;

      expect(mandatory['minWidth'], '1280');
      expect(mandatory['minHeight'], '720');
      expect(video['facingMode'], 'environment');
    });

    test('Perfil 1080p con audio y camara frontal', () {
      const config = ConfiguracionVideo.altaDefinicion1080p(audio: true);

      expect(config.ancho, 1920);
      expect(config.alto, 1080);
      expect(config.audioHabilitado, isTrue);

      final restricciones = config.aRestriccionesMedios(
        usarCamaraFrontal: true,
      );
      expect(restricciones['audio'], isTrue);

      final video = restricciones['video'] as Map<String, dynamic>;
      expect(video['facingMode'], 'user');
    });

    test('Enum EstadoConexionP2p contiene estados requeridos', () {
      expect(EstadoConexionP2p.values, contains(EstadoConexionP2p.inicial));
      expect(EstadoConexionP2p.values, contains(EstadoConexionP2p.capturando));
      expect(EstadoConexionP2p.values, contains(EstadoConexionP2p.conectando));
      expect(
        EstadoConexionP2p.values,
        contains(EstadoConexionP2p.transmitiendo),
      );
      expect(
        EstadoConexionP2p.values,
        contains(EstadoConexionP2p.desconectado),
      );
      expect(EstadoConexionP2p.values, contains(EstadoConexionP2p.error));
    });
  });
}
