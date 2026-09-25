// abstraccion base para el manejo de fallos en el dominio
abstract class Fallo {
  final String mensaje;

  const Fallo(this.mensaje);
}

class FalloConexion extends Fallo {
  const FalloConexion(super.mensaje);
}

class FalloServidor extends Fallo {
  const FalloServidor(super.mensaje);
}

class FalloPermisos extends Fallo {
  const FalloPermisos(super.mensaje);
}

class FalloAlmacenamiento extends Fallo {
  const FalloAlmacenamiento(super.mensaje);
}
