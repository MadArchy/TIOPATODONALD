import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'miembro_hogar.dart' show NullableTimestampConverter;
import 'usuario.dart';

part 'pago_interno.freezed.dart';
part 'pago_interno.g.dart';

/// Modelo de `hogares/{h}/deudasInternas/{d}/pagos/{id}` (`docs/03_modelo_datos.md`).
@freezed
abstract class PagoInterno with _$PagoInterno {
  const factory PagoInterno({
    required String id,
    required int monto,
    @TimestampConverter() required DateTime fecha,
    required String registradoPor,
    @Default(false) bool confirmado,
    @NullableTimestampConverter() DateTime? confirmadoEn,
  }) = _PagoInterno;

  factory PagoInterno.fromJson(Map<String, dynamic> json) =>
      _$PagoInternoFromJson(json);

  factory PagoInterno.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return PagoInterno.fromJson(<String, dynamic>{
      ...data,
      'id': doc.id,
      'confirmado': data['confirmado'] ?? false,
    });
  }
}
