import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chat/domain/intencion.dart';
import '../../features/chat/domain/interprete.dart';
import '../../features/chat/domain/interprete_reglas.dart';
import '../models/mensaje_chat.dart';
import 'auth_repository.dart';

class ChatException implements Exception {
  const ChatException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

abstract class ChatRepository {
  Stream<List<MensajeChat>> observarMensajes({
    required String hogarId,
    required String uid,
  });

  Future<String> guardarMensaje({
    required String hogarId,
    required String uid,
    required String rol,
    required String texto,
    Intencion? intencion,
    required String estado,
  });

  Future<void> actualizarEstadoMensaje({
    required String hogarId,
    required String uid,
    required String mensajeId,
    required String estado,
  });
}

class FirebaseChatRepository implements ChatRepository {
  FirebaseChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _mensajes(
    String hogarId,
    String uid,
  ) {
    return _firestore
        .collection('hogares')
        .doc(hogarId)
        .collection('chats')
        .doc(uid)
        .collection('mensajes');
  }

  @override
  Stream<List<MensajeChat>> observarMensajes({
    required String hogarId,
    required String uid,
  }) {
    return _mensajes(hogarId, uid)
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(MensajeChat.fromFirestore).toList());
  }

  @override
  Future<String> guardarMensaje({
    required String hogarId,
    required String uid,
    required String rol,
    required String texto,
    Intencion? intencion,
    required String estado,
  }) async {
    final ref = _mensajes(hogarId, uid).doc();
    // B1 (offline): no esperar confirmación del servidor; Firestore persiste en caché local.
    unawaited(
      ref.set(<String, dynamic>{
        'rol': rol,
        'texto': texto,
        'intencion': intencion?.toJson(),
        'estado': estado,
        'fecha': FieldValue.serverTimestamp(),
      }).catchError((Object e, StackTrace st) {
        debugPrint('Error sincronizando mensaje de chat: $e');
      }),
    );
    return ref.id;
  }

  @override
  Future<void> actualizarEstadoMensaje({
    required String hogarId,
    required String uid,
    required String mensajeId,
    required String estado,
  }) async {
    unawaited(
      _mensajes(hogarId, uid).doc(mensajeId).update(<String, dynamic>{
        'estado': estado,
      }).catchError((Object e, StackTrace st) {
        debugPrint('Error sincronizando estado de mensaje de chat: $e');
      }),
    );
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirebaseChatRepository();
});

final interpreteProvider = Provider<Interprete>((ref) {
  return const InterpreteReglas();
});

final mensajesChatProvider = StreamProvider<List<MensajeChat>>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final hogarId = usuario?.hogarId;
  final uid = usuario?.uid;
  if (hogarId == null || hogarId.isEmpty || uid == null) {
    return Stream.value(const <MensajeChat>[]);
  }
  return ref.watch(chatRepositoryProvider).observarMensajes(
        hogarId: hogarId,
        uid: uid,
      );
});
