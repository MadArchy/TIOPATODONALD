// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Usuario _$UsuarioFromJson(Map<String, dynamic> json) => _Usuario(
  uid: json['uid'] as String,
  nombre: json['nombre'] as String,
  email: json['email'] as String,
  hogarId: json['hogarId'] as String?,
  diaInicioPeriodo: (json['diaInicioPeriodo'] as num?)?.toInt() ?? 1,
  diaInicioPendiente: (json['diaInicioPendiente'] as num?)?.toInt(),
  horaRecordatorio: json['horaRecordatorio'] as String?,
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  creadoEn: const TimestampConverter().fromJson(json['creadoEn']),
);

Map<String, dynamic> _$UsuarioToJson(_Usuario instance) => <String, dynamic>{
  'uid': instance.uid,
  'nombre': instance.nombre,
  'email': instance.email,
  'hogarId': instance.hogarId,
  'diaInicioPeriodo': instance.diaInicioPeriodo,
  'diaInicioPendiente': instance.diaInicioPendiente,
  'horaRecordatorio': instance.horaRecordatorio,
  'fcmTokens': instance.fcmTokens,
  'creadoEn': const TimestampConverter().toJson(instance.creadoEn),
};
