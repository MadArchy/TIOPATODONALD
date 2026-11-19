// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'miembro_hogar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MiembroHogar _$MiembroHogarFromJson(Map<String, dynamic> json) =>
    _MiembroHogar(
      uid: json['uid'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String? ?? 'miembro',
      estado: json['estado'] as String? ?? 'activo',
      unidoEn: const TimestampConverter().fromJson(json['unidoEn']),
      retiradoEn: const NullableTimestampConverter().fromJson(
        json['retiradoEn'],
      ),
    );

Map<String, dynamic> _$MiembroHogarToJson(
  _MiembroHogar instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'nombre': instance.nombre,
  'rol': instance.rol,
  'estado': instance.estado,
  'unidoEn': const TimestampConverter().toJson(instance.unidoEn),
  'retiradoEn': const NullableTimestampConverter().toJson(instance.retiradoEn),
};
