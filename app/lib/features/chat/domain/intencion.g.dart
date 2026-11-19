// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intencion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Intencion _$IntencionFromJson(Map<String, dynamic> json) => _Intencion(
  accion: json['accion'] as String,
  tipo: json['tipo'] as String?,
  monto: (json['monto'] as num?)?.toInt(),
  categoria: json['categoria'] as String?,
  fecha: json['fecha'] as String?,
  nota: json['nota'] as String?,
  deudaId: json['deudaId'] as String?,
  movimientoId: json['movimientoId'] as String?,
  cambios: json['cambios'] as Map<String, dynamic>?,
  motivo: json['motivo'] as String?,
  textoOriginal: json['textoOriginal'] as String?,
  confianza: (json['confianza'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$IntencionToJson(_Intencion instance) =>
    <String, dynamic>{
      'accion': instance.accion,
      'tipo': instance.tipo,
      'monto': instance.monto,
      'categoria': instance.categoria,
      'fecha': instance.fecha,
      'nota': instance.nota,
      'deudaId': instance.deudaId,
      'movimientoId': instance.movimientoId,
      'cambios': instance.cambios,
      'motivo': instance.motivo,
      'textoOriginal': instance.textoOriginal,
      'confianza': instance.confianza,
    };
