import 'intencion.dart';
import 'interprete.dart';

/// Puerta de IA (Nivel 2). Declarado para el MVP; no se usa todavía.
/// Cuando se active, llamará a la Cloud Function `asistente`.
class InterpreteIA implements Interprete {
  const InterpreteIA();

  @override
  Future<Intencion> interpretar(String texto, ContextoUsuario ctx) async {
    return Intencion(
      accion: AccionesIntencion.noEntendido,
      textoOriginal: texto,
      confianza: 0,
    );
  }
}
