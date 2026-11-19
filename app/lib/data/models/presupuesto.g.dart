// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presupuesto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Presupuesto _$PresupuestoFromJson(Map<String, dynamic> json) => _Presupuesto(
  id: json['id'] as String,
  uid: json['uid'] as String,
  periodoId: json['periodoId'] as String,
  monto: (json['monto'] as num).toInt(),
  alertasEnviadas:
      (json['alertasEnviadas'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  actualizadoEn: const TimestampConverter().fromJson(json['actualizadoEn']),
);

Map<String, dynamic> _$PresupuestoToJson(
  _Presupuesto instance,
) => <String, dynamic>{
  'id': instance.id,
  'uid': instance.uid,
  'periodoId': instance.periodoId,
  'monto': instance.monto,
  'alertasEnviadas': instance.alertasEnviadas,
  'actualizadoEn': const TimestampConverter().toJson(instance.actualizadoEn),
};
