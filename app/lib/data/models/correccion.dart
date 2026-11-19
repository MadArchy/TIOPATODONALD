import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'miembro_hogar.dart' show NullableTimestampConverter;
import 'usuario.dart';

part 'correccion.freezed.dart';
part 'correccion.g.dart';

/// Modelo de `hogares/{h}/correcciones/{id}` (`docs/03_modelo_datos.md`).
@freezed
abstract class Correccion with _$Correccion {
  const factory Correccion({
    required String id,
    required String movimientoId,
    required String solicitanteUid,
    required String motivo,
    @Default(<String, dynamic>{}) Map<String, dynamic> cambios,
    @Default('pendiente') String estado,
    String? resueltaPor,
    @NullableTimestampConverter() DateTime? resueltaEn,
    String? motivoRechazo,
    @TimestampConverter() required DateTime creadoEn,
  }) = _Correccion;

  factory Correccion.fromJson(Map<String, dynamic> json) =>
      _$CorreccionFromJson(json);

  factory Correccion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawCambios = data['cambios'];
    return Correccion.fromJson(<String, dynamic>{
      ...data,
      'id': doc.id,
      'estado': data['estado'] ?? 'pendiente',
      'cambios': rawCambios is Map
          ? Map<String, dynamic>.from(rawCambios)
          : <String, dynamic>{},
      'motivo': data['motivo'] ?? '',
    });
  }
}
