// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitacion_hogar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvitacionHogar _$InvitacionHogarFromJson(Map<String, dynamic> json) =>
    _InvitacionHogar(
      id: json['id'] as String,
      hogarId: json['hogarId'] as String,
      codigo: json['codigo'] as String,
      creadaPor: json['creadaPor'] as String,
      creadaEn: const TimestampConverter().fromJson(json['creadaEn']),
      expiraEn: const TimestampConverter().fromJson(json['expiraEn']),
      activa: json['activa'] as bool? ?? true,
    );

Map<String, dynamic> _$InvitacionHogarToJson(_InvitacionHogar instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hogarId': instance.hogarId,
      'codigo': instance.codigo,
      'creadaPor': instance.creadaPor,
      'creadaEn': const TimestampConverter().toJson(instance.creadaEn),
      'expiraEn': const TimestampConverter().toJson(instance.expiraEn),
      'activa': instance.activa,
    };
