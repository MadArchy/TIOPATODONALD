// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pago_interno.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PagoInterno _$PagoInternoFromJson(Map<String, dynamic> json) => _PagoInterno(
  id: json['id'] as String,
  monto: (json['monto'] as num).toInt(),
  fecha: const TimestampConverter().fromJson(json['fecha']),
  registradoPor: json['registradoPor'] as String,
  confirmado: json['confirmado'] as bool? ?? false,
  confirmadoEn: const NullableTimestampConverter().fromJson(
    json['confirmadoEn'],
  ),
);

Map<String, dynamic> _$PagoInternoToJson(_PagoInterno instance) =>
    <String, dynamic>{
      'id': instance.id,
      'monto': instance.monto,
      'fecha': const TimestampConverter().toJson(instance.fecha),
      'registradoPor': instance.registradoPor,
      'confirmado': instance.confirmado,
      'confirmadoEn': const NullableTimestampConverter().toJson(
        instance.confirmadoEn,
      ),
    };
