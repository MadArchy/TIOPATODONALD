// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto_fijo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GastoFijo _$GastoFijoFromJson(Map<String, dynamic> json) => _GastoFijo(
  id: json['id'] as String,
  uid: json['uid'] as String,
  nombre: json['nombre'] as String,
  monto: (json['monto'] as num).toInt(),
  categoria: json['categoria'] as String,
  diaEsperado: (json['diaEsperado'] as num).toInt(),
  activo: json['activo'] as bool? ?? true,
);

Map<String, dynamic> _$GastoFijoToJson(_GastoFijo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'nombre': instance.nombre,
      'monto': instance.monto,
      'categoria': instance.categoria,
      'diaEsperado': instance.diaEsperado,
      'activo': instance.activo,
    };
