// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'correccion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Correccion _$CorreccionFromJson(Map<String, dynamic> json) => _Correccion(
  id: json['id'] as String,
  movimientoId: json['movimientoId'] as String,
  solicitanteUid: json['solicitanteUid'] as String,
  motivo: json['motivo'] as String,
  cambios:
      json['cambios'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  estado: json['estado'] as String? ?? 'pendiente',
  resueltaPor: json['resueltaPor'] as String?,
  resueltaEn: const NullableTimestampConverter().fromJson(json['resueltaEn']),
  motivoRechazo: json['motivoRechazo'] as String?,
  creadoEn: const TimestampConverter().fromJson(json['creadoEn']),
);

Map<String, dynamic> _$CorreccionToJson(
  _Correccion instance,
) => <String, dynamic>{
  'id': instance.id,
  'movimientoId': instance.movimientoId,
  'solicitanteUid': instance.solicitanteUid,
  'motivo': instance.motivo,
  'cambios': instance.cambios,
  'estado': instance.estado,
  'resueltaPor': instance.resueltaPor,
  'resueltaEn': const NullableTimestampConverter().toJson(instance.resueltaEn),
  'motivoRechazo': instance.motivoRechazo,
  'creadoEn': const TimestampConverter().toJson(instance.creadoEn),
};
