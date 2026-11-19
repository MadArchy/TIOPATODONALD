import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'usuario.dart';

part 'miembro_hogar.freezed.dart';
part 'miembro_hogar.g.dart';

/// Conversor opcional de Firestore `Timestamp?` <-> `DateTime?`.
class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}

/// Modelo inmutable de `hogares/{h}/miembros/{uid}` (`docs/03_modelo_datos.md`).
@freezed
abstract class MiembroHogar with _$MiembroHogar {
  const factory MiembroHogar({
    required String uid,
    required String nombre,
    @Default('miembro') String rol,
    @Default('activo') String estado,
    @TimestampConverter() required DateTime unidoEn,
    @NullableTimestampConverter() DateTime? retiradoEn,
  }) = _MiembroHogar;

  factory MiembroHogar.fromJson(Map<String, dynamic> json) =>
      _$MiembroHogarFromJson(json);

  factory MiembroHogar.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return MiembroHogar.fromJson(<String, dynamic>{
      ...data,
      'uid': doc.id,
    });
  }
}
