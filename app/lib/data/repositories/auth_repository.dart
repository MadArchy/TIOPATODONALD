import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/auth_failures.dart';
import '../models/preferencias_avisos.dart';
import '../models/usuario.dart';

/// Contrato del repositorio de autenticación y perfil de usuario (`usuarios/{uid}`).
abstract class AuthRepository {
  /// Stream de cambios de sesión (uid actual o `null` si no hay sesión).
  Stream<String?> observarUidAutenticado();

  /// Stream del documento `usuarios/{uid}` del usuario autenticado.
  Stream<Usuario?> observarUsuario(String uid);

  /// Registra una cuenta con correo y contraseña y crea `usuarios/{uid}`
  /// con `diaInicioPeriodo: 1` y `hogarId: null`.
  Future<Usuario> registrar({
    required String nombre,
    required String email,
    required String password,
  });

  /// Inicia sesión con correo y contraseña.
  Future<void> iniciarSesion({
    required String email,
    required String password,
  });

  /// Envía el correo de recuperación de contraseña.
  Future<void> enviarCorreoRecuperacion({
    required String email,
  });

  /// Cierra la sesión actual.
  Future<void> cerrarSesion();

  /// Agrega un token FCM (idempotente con arrayUnion).
  Future<void> registrarFcmToken({
    required String uid,
    required String token,
  });

  /// Quita un token FCM.
  Future<void> quitarFcmToken({
    required String uid,
    required String token,
  });

  /// Guarda la hora del recordatorio diario (`HH:mm` o null para apagar).
  Future<void> guardarHoraRecordatorio({
    required String uid,
    required String? horaRecordatorio,
  });

  /// Actualiza preferencias de avisos push.
  Future<void> guardarPreferenciasAvisos({
    required String uid,
    required PreferenciasAvisos preferencias,
  });
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usuariosRef =>
      _firestore.collection('usuarios');

  @override
  Stream<String?> observarUidAutenticado() {
    return _auth.authStateChanges().map((User? user) => user?.uid);
  }

  @override
  Stream<Usuario?> observarUsuario(String uid) {
    return _usuariosRef.doc(uid).snapshots().map((snap) {
      if (!snap.exists) {
        return null;
      }
      return Usuario.fromFirestore(snap);
    });
  }

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final nombreLimpio = nombre.trim();
    final emailLimpio = email.trim().toLowerCase();

    final errorNombre = AuthValidators.validarNombre(nombreLimpio);
    if (errorNombre != null) {
      throw AuthException(errorNombre);
    }
    final errorCorreo = AuthValidators.validarCorreo(emailLimpio);
    if (errorCorreo != null) {
      throw AuthException(errorCorreo);
    }
    final errorPassword = AuthValidators.validarPassword(password);
    if (errorPassword != null) {
      throw AuthException(errorPassword);
    }

    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: emailLimpio,
        password: password,
      );

      final user = credencial.user;
      if (user == null) {
        throw const AuthException('No se pudo crear tu cuenta. Intenta de nuevo.');
      }

      await user.updateDisplayName(nombreLimpio);

      final ahora = DateTime.now();
      final datosDoc = <String, dynamic>{
        'nombre': nombreLimpio,
        'email': emailLimpio,
        'hogarId': null,
        'diaInicioPeriodo': 1,
        'diaInicioPendiente': null,
        'horaRecordatorio': null,
        'fcmTokens': <String>[],
        'preferenciasAvisos': <String, dynamic>{
          'alertasPresupuesto': true,
          'recordatorioDiario': true,
          'cuotas': true,
          'correcciones': true,
          'deudasInternas': true,
        },
        'creadoEn': FieldValue.serverTimestamp(),
      };

      await _usuariosRef.doc(user.uid).set(datosDoc);

      return Usuario(
        uid: user.uid,
        nombre: nombreLimpio,
        email: emailLimpio,
        hogarId: null,
        diaInicioPeriodo: 1,
        creadoEn: ahora,
      );
    } catch (e) {
      throw mapearErrorFirebaseAuth(e);
    }
  }

  @override
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final emailLimpio = email.trim().toLowerCase();

    final errorCorreo = AuthValidators.validarCorreo(emailLimpio);
    if (errorCorreo != null) {
      throw AuthException(errorCorreo);
    }
    if (password.isEmpty) {
      throw const AuthException('Escribe tu contraseña.');
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailLimpio,
        password: password,
      );
    } catch (e) {
      throw mapearErrorFirebaseAuth(e);
    }
  }

  @override
  Future<void> enviarCorreoRecuperacion({
    required String email,
  }) async {
    final emailLimpio = email.trim().toLowerCase();
    final errorCorreo = AuthValidators.validarCorreo(emailLimpio);
    if (errorCorreo != null) {
      throw AuthException(errorCorreo);
    }

    try {
      await _auth.sendPasswordResetEmail(email: emailLimpio);
    } catch (e) {
      throw mapearErrorFirebaseAuth(e);
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw mapearErrorFirebaseAuth(e);
    }
  }

  @override
  Future<void> registrarFcmToken({
    required String uid,
    required String token,
  }) async {
    final t = token.trim();
    if (t.isEmpty) return;
    await _usuariosRef.doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion(<String>[t]),
    });
  }

  @override
  Future<void> quitarFcmToken({
    required String uid,
    required String token,
  }) async {
    final t = token.trim();
    if (t.isEmpty) return;
    await _usuariosRef.doc(uid).update({
      'fcmTokens': FieldValue.arrayRemove(<String>[t]),
    });
  }

  @override
  Future<void> guardarHoraRecordatorio({
    required String uid,
    required String? horaRecordatorio,
  }) async {
    await _usuariosRef.doc(uid).update({
      'horaRecordatorio': horaRecordatorio,
    });
  }

  @override
  Future<void> guardarPreferenciasAvisos({
    required String uid,
    required PreferenciasAvisos preferencias,
  }) async {
    await _usuariosRef.doc(uid).update({
      'preferenciasAvisos': preferencias.toJson(),
    });
  }
}

/// Provider del repositorio de autenticación (sobreescribible en tests).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// StreamProvider con el UID autenticado actual (`null` si no hay sesión).
final authUidProvider = StreamProvider<String?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.observarUidAutenticado();
});

/// StreamProvider con el documento `usuarios/{uid}` del usuario autenticado.
final usuarioActualProvider = StreamProvider<Usuario?>((ref) {
  final uidAsync = ref.watch(authUidProvider);
  final uid = uidAsync.value;
  if (uid == null) {
    return Stream<Usuario?>.value(null);
  }
  final repo = ref.watch(authRepositoryProvider);
  return repo.observarUsuario(uid);
});
