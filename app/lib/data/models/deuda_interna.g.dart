// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deuda_interna.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeudaInterna _$DeudaInternaFromJson(Map<String, dynamic> json) =>
    _DeudaInterna(
      id: json['id'] as String,
      acreedorUid: json['acreedorUid'] as String,
      deudorUid: json['deudorUid'] as String,
      montoInicial: (json['montoInicial'] as num).toInt(),
      saldo: (json['saldo'] as num).toInt(),
      concepto: json['concepto'] as String,
      estado: json['estado'] as String? ?? 'pendiente',
      creadaEn: const TimestampConverter().fromJson(json['creadaEn']),
    );

Map<String, dynamic> _$DeudaInternaToJson(_DeudaInterna instance) =>
    <String, dynamic>{
      'id': instance.id,
      'acreedorUid': instance.acreedorUid,
      'deudorUid': instance.deudorUid,
      'montoInicial': instance.montoInicial,
      'saldo': instance.saldo,
      'concepto': instance.concepto,
      'estado': instance.estado,
      'creadaEn': const TimestampConverter().toJson(instance.creadaEn),
    };
