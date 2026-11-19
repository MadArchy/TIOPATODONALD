// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferencias_avisos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PreferenciasAvisos _$PreferenciasAvisosFromJson(Map<String, dynamic> json) =>
    _PreferenciasAvisos(
      alertasPresupuesto: json['alertasPresupuesto'] as bool? ?? true,
      recordatorioDiario: json['recordatorioDiario'] as bool? ?? true,
      cuotas: json['cuotas'] as bool? ?? true,
      correcciones: json['correcciones'] as bool? ?? true,
      deudasInternas: json['deudasInternas'] as bool? ?? true,
    );

Map<String, dynamic> _$PreferenciasAvisosToJson(_PreferenciasAvisos instance) =>
    <String, dynamic>{
      'alertasPresupuesto': instance.alertasPresupuesto,
      'recordatorioDiario': instance.recordatorioDiario,
      'cuotas': instance.cuotas,
      'correcciones': instance.correcciones,
      'deudasInternas': instance.deudasInternas,
    };
