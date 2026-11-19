// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hogar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConfiguracionIaHogar _$ConfiguracionIaHogarFromJson(
  Map<String, dynamic> json,
) => _ConfiguracionIaHogar(
  activa: json['activa'] as bool? ?? false,
  proveedor: json['proveedor'] as String? ?? '',
  modelo: json['modelo'] as String? ?? '',
  limiteMensual: (json['limiteMensual'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ConfiguracionIaHogarToJson(
  _ConfiguracionIaHogar instance,
) => <String, dynamic>{
  'activa': instance.activa,
  'proveedor': instance.proveedor,
  'modelo': instance.modelo,
  'limiteMensual': instance.limiteMensual,
};

_Hogar _$HogarFromJson(Map<String, dynamic> json) => _Hogar(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  adminUid: json['adminUid'] as String,
  ia: json['ia'] == null
      ? const ConfiguracionIaHogar()
      : ConfiguracionIaHogar.fromJson(json['ia'] as Map<String, dynamic>),
  creadoEn: const TimestampConverter().fromJson(json['creadoEn']),
);

Map<String, dynamic> _$HogarToJson(_Hogar instance) => <String, dynamic>{
  'id': instance.id,
  'nombre': instance.nombre,
  'adminUid': instance.adminUid,
  'ia': instance.ia,
  'creadoEn': const TimestampConverter().toJson(instance.creadoEn),
};
