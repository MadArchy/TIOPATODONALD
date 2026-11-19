import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../features/chat/domain/intencion.dart';
import 'usuario.dart';

part 'mensaje_chat.freezed.dart';
part 'mensaje_chat.g.dart';

/// `hogares/{h}/chats/{uid}/mensajes/{id}` (`docs/03_modelo_datos.md`).
@freezed
abstract class MensajeChat with _$MensajeChat {
  const factory MensajeChat({
    required String id,
    required String rol,
    required String texto,
    Intencion? intencion,
    @Default('confirmado') String estado,
    @TimestampConverter() required DateTime fecha,
  }) = _MensajeChat;

  factory MensajeChat.fromJson(Map<String, dynamic> json) =>
      _$MensajeChatFromJson(json);

  factory MensajeChat.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    Intencion? intencion;
    final raw = data['intencion'];
    if (raw is Map) {
      intencion = Intencion.fromJson(Map<String, dynamic>.from(raw));
    }
    return MensajeChat(
      id: doc.id,
      rol: (data['rol'] as String?) ?? 'app',
      texto: (data['texto'] as String?) ?? '',
      intencion: intencion,
      estado: (data['estado'] as String?) ?? 'confirmado',
      fecha: const TimestampConverter().fromJson(data['fecha']),
    );
  }
}
