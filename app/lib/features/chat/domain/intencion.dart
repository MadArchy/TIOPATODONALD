import 'package:freezed_annotation/freezed_annotation.dart';

part 'intencion.freezed.dart';
part 'intencion.g.dart';

/// Acciones válidas del chat (`docs/05_ia.md`).
abstract final class AccionesIntencion {
  static const proponerMovimiento = 'proponerMovimiento';
  static const consultarEstado = 'consultarEstado';
  static const consultarCategoria = 'consultarCategoria';
  static const consultarDeuda = 'consultarDeuda';
  static const pedirCorreccion = 'pedirCorreccion';
  static const noEntendido = 'noEntendido';

  static const Set<String> todas = <String>{
    proponerMovimiento,
    consultarEstado,
    consultarCategoria,
    consultarDeuda,
    pedirCorreccion,
    noEntendido,
  };
}

/// Contrato JSON entre intérprete (reglas o IA) y la UI del chat.
@freezed
abstract class Intencion with _$Intencion {
  const factory Intencion({
    required String accion,
    String? tipo,
    int? monto,
    String? categoria,
    /// Fecha propuesta `YYYY-MM-DD` (America/Bogota calendario).
    String? fecha,
    String? nota,
    String? deudaId,
    String? movimientoId,
    Map<String, dynamic>? cambios,
    String? motivo,
    String? textoOriginal,
    @Default(0.0) double confianza,
  }) = _Intencion;

  factory Intencion.fromJson(Map<String, dynamic> json) =>
      _$IntencionFromJson(json);
}

/// Deuda mínima para que el intérprete resuelva nombres.
class DeudaContextoChat {
  const DeudaContextoChat({
    required this.id,
    required this.entidad,
    required this.saldoActual,
    required this.diaPago,
  });

  final String id;
  final String entidad;
  final int saldoActual;
  final int diaPago;
}

/// Contexto del usuario para interpretar sin tocar Firestore.
class ContextoUsuario {
  const ContextoUsuario({
    required this.ahora,
    required this.diaInicioPeriodo,
    required this.presupuesto,
    required this.gastado,
    required this.disponiblePorDia,
    this.gastadoPorCategoria = const <String, int>{},
    this.deudas = const <DeudaContextoChat>[],
  });

  final DateTime ahora;
  final int diaInicioPeriodo;
  final int presupuesto;
  final int gastado;
  final int disponiblePorDia;
  final Map<String, int> gastadoPorCategoria;
  final List<DeudaContextoChat> deudas;
}
