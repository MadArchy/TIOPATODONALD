import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';

/// Registra el token FCM del dispositivo en `usuarios/{uid}.fcmTokens`.
/// En web/Chrome, sin Firebase o sin permiso falla en silencio (piloto = Android).
///
/// Usa `getToken` / `onTokenRefresh` porque el Admin SDK envía con
/// registration tokens (`sendEachForMulticast`), no con FID de `register()`.
class FcmService {
  FcmService({
    required AuthRepository authRepository,
    FirebaseMessaging? messaging,
  })  : _auth = authRepository,
        _messagingOverride = messaging;

  final AuthRepository _auth;
  final FirebaseMessaging? _messagingOverride;
  StreamSubscription<String>? _tokenSub;
  String? _uidActual;
  String? _tokenActual;

  FirebaseMessaging? get _messaging {
    if (_messagingOverride != null) return _messagingOverride;
    if (Firebase.apps.isEmpty) return null;
    return FirebaseMessaging.instance;
  }

  Future<void> iniciarParaUid(String uid) async {
    if (_uidActual == uid && _tokenActual != null) return;
    await detener();
    _uidActual = uid;

    final messaging = _messaging;
    if (messaging == null) {
      debugPrint('FCM: Firebase no inicializado; se omite el token.');
      return;
    }

    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('FCM: permiso denegado');
        return;
      }

      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _tokenActual = token;
        await _auth.registrarFcmToken(uid: uid, token: token);
      }

      // ignore: deprecated_member_use
      _tokenSub = messaging.onTokenRefresh.listen((nuevo) async {
        final anterior = _tokenActual;
        _tokenActual = nuevo;
        if (anterior != null && anterior != nuevo) {
          await _auth.quitarFcmToken(uid: uid, token: anterior);
        }
        await _auth.registrarFcmToken(uid: uid, token: nuevo);
      });
    } catch (e, st) {
      debugPrint('FCM: no se pudo registrar token: $e\n$st');
    }
  }

  Future<void> detener() async {
    await _tokenSub?.cancel();
    _tokenSub = null;
    final uid = _uidActual;
    final token = _tokenActual;
    _uidActual = null;
    _tokenActual = null;
    if (uid != null && token != null) {
      try {
        await _auth.quitarFcmToken(uid: uid, token: token);
      } catch (_) {
        // Sesión ya cerrada o sin red: no bloquear logout.
      }
    }
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) {
  final service = FcmService(authRepository: ref.watch(authRepositoryProvider));
  ref.onDispose(() {
    unawaited(service.detener());
  });
  return service;
});

/// Mantiene el token FCM alineado con la sesión.
final fcmBootstrapProvider = Provider<void>((ref) {
  final service = ref.watch(fcmServiceProvider);
  ref.listen<AsyncValue<String?>>(authUidProvider, (prev, next) {
    final uid = next.value;
    if (uid == null) {
      unawaited(service.detener());
    } else {
      unawaited(service.iniciarParaUid(uid));
    }
  }, fireImmediately: true);
});
