import 'intencion.dart';

/// Contrato del intérprete de chat (`docs/05_ia.md`).
/// Nivel 1: [InterpreteReglas]. Nivel 2 (futuro): [InterpreteIA].
abstract class Interprete {
  Future<Intencion> interpretar(String texto, ContextoUsuario ctx);
}
