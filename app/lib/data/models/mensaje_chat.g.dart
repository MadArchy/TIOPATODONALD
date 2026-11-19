// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mensaje_chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MensajeChat _$MensajeChatFromJson(Map<String, dynamic> json) => _MensajeChat(
  id: json['id'] as String,
  rol: json['rol'] as String,
  texto: json['texto'] as String,
  intencion: json['intencion'] == null
      ? null
      : Intencion.fromJson(json['intencion'] as Map<String, dynamic>),
  estado: json['estado'] as String? ?? 'confirmado',
  fecha: const TimestampConverter().fromJson(json['fecha']),
);

Map<String, dynamic> _$MensajeChatToJson(_MensajeChat instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rol': instance.rol,
      'texto': instance.texto,
      'intencion': instance.intencion,
      'estado': instance.estado,
      'fecha': const TimestampConverter().toJson(instance.fecha),
    };
