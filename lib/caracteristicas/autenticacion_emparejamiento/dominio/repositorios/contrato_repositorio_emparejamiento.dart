import '../entidades/credencial_emparejamiento.dart';

// contrato abstracto para la gestion y verificacion del emparejamiento
abstract class ContratoRepositorioEmparejamiento {
  Future<CredencialEmparejamiento> generarCredencialPropia();
  Future<bool> verificarCredencialRemota(CredencialEmparejamiento credencial);
}
