// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movimiento.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Movimiento _$MovimientoFromJson(Map<String, dynamic> json) => _Movimiento(
  id: json['id'] as String,
  tipo: json['tipo'] as String,
  monto: (json['monto'] as num).toInt(),
  categoria: json['categoria'] as String?,
  deudaId: json['deudaId'] as String?,
  gastoFijoId: json['gastoFijoId'] as String?,
  fecha: const TimestampConverter().fromJson(json['fecha']),
  periodoId: json['periodoId'] as String,
  uid: json['uid'] as String,
  nota: json['nota'] as String? ?? '',
  fotoPath: json['fotoPath'] as String?,
  origen: json['origen'] as String? ?? 'formulario',
  estado: json['estado'] as String? ?? 'activo',
  creadoEn: const TimestampConverter().fromJson(json['creadoEn']),
  editadoEn: const NullableTimestampConverter().fromJson(json['editadoEn']),
  saldoAplicado: json['saldoAplicado'] as bool? ?? false,
);

Map<String, dynamic> _$MovimientoToJson(
  _Movimiento instance,
) => <String, dynamic>{
  'id': instance.id,
  'tipo': instance.tipo,
  'monto': instance.monto,
  'categoria': instance.categoria,
  'deudaId': instance.deudaId,
  'gastoFijoId': instance.gastoFijoId,
  'fecha': const TimestampConverter().toJson(instance.fecha),
  'periodoId': instance.periodoId,
  'uid': instance.uid,
  'nota': instance.nota,
  'fotoPath': instance.fotoPath,
  'origen': instance.origen,
  'estado': instance.estado,
  'creadoEn': const TimestampConverter().toJson(instance.creadoEn),
  'editadoEn': const NullableTimestampConverter().toJson(instance.editadoEn),
  'saldoAplicado': instance.saldoAplicado,
};
