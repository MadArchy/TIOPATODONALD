import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'usuario.freezed.dart';
part 'usuario.g.dart';

/// Conversor de Firestore `Timestamp` <-> `DateTime` para json_serializable.
class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json is Timestamp) {
      return json.toDate();
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}

/// Modelo inmutable de `usuarios/{uid}` (docs/03_modelo_datos.md).
@freezed
abstract class Usuario with _$Usuario {
  const factory Usuario({
    required String uid,
    required String nombre,
    required String email,
    String? hogarId,
    @Default(1) int diaInicioPeriodo,
    int? diaInicioPendiente,
    String? horaRecordatorio,
    @Default(<String>[]) List<String> fcmTokens,
    @TimestampConverter() required DateTime creadoEn,
  }) = _Usuario;

  factory Usuario.fromJson(Map<String, dynamic> json) =>
      _$UsuarioFromJson(json);

  factory Usuario.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return Usuario.fromJson(<String, dynamic>{
      ...data,
      'uid': doc.id,
    });
  }
}
