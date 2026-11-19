import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'miembro_hogar.dart' show NullableTimestampConverter;
import 'usuario.dart';

part 'movimiento.freezed.dart';
part 'movimiento.g.dart';

/// Modelo de `hogares/{h}/movimientos/{id}` (`docs/03_modelo_datos.md`).
@freezed
abstract class Movimiento with _$Movimiento {
  const factory Movimiento({
    required String id,
    required String tipo,
    required int monto,
    String? categoria,
    String? deudaId,
    String? gastoFijoId,
    @TimestampConverter() required DateTime fecha,
    required String periodoId,
    required String uid,
    @Default('') String nota,
    String? fotoPath,
    @Default('formulario') String origen,
    @Default('activo') String estado,
    @TimestampConverter() required DateTime creadoEn,
    @NullableTimestampConverter() DateTime? editadoEn,
    @Default(false) bool saldoAplicado,
  }) = _Movimiento;

  factory Movimiento.fromJson(Map<String, dynamic> json) =>
      _$MovimientoFromJson(json);

  factory Movimiento.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return Movimiento.fromJson(<String, dynamic>{
      ...data,
      'id': doc.id,
      'nota': data['nota'] ?? '',
      'origen': data['origen'] ?? 'formulario',
      'estado': data['estado'] ?? 'activo',
      'saldoAplicado': data['saldoAplicado'] ?? false,
    });
  }
}
