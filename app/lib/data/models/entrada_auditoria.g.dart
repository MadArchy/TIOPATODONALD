// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entrada_auditoria.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EntradaAuditoria _$EntradaAuditoriaFromJson(Map<String, dynamic> json) =>
    _EntradaAuditoria(
      id: json['id'] as String,
      movimientoId: json['movimientoId'] as String?,
      accion: json['accion'] as String,
      antes:
          json['antes'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      despues:
          json['despues'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      porUid: json['porUid'] as String,
      aprobadoPor: json['aprobadoPor'] as String?,
      fecha: const TimestampConverter().fromJson(json['fecha']),
    );

Map<String, dynamic> _$EntradaAuditoriaToJson(_EntradaAuditoria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'movimientoId': instance.movimientoId,
      'accion': instance.accion,
      'antes': instance.antes,
      'despues': instance.despues,
      'porUid': instance.porUid,
      'aprobadoPor': instance.aprobadoPor,
      'fecha': const TimestampConverter().toJson(instance.fecha),
    };
