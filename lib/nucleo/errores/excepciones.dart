// abstraccion base para excepciones tecnicas en la capa de datos
class ExcepcionBase implements Exception {
  final String mensaje;

  const ExcepcionBase(this.mensaje);

  @override
  String toString() => mensaje;
}

class ExcepcionConexionRed extends ExcepcionBase {
  const ExcepcionConexionRed(super.mensaje);
}

class ExcepcionServidorLocal extends ExcepcionBase {
  const ExcepcionServidorLocal(super.mensaje);
}

class ExcepcionDispositivoCamara extends ExcepcionBase {
  const ExcepcionDispositivoCamara(super.mensaje);
}

class ExcepcionPersistenciaLocal extends ExcepcionBase {
  const ExcepcionPersistenciaLocal(super.mensaje);
}
