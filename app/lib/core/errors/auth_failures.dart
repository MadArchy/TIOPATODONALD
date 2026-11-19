import 'package:firebase_auth/firebase_auth.dart';

/// Excepción de dominio con mensaje claro en español para mostrar en la UI.
class AuthException implements Exception {
  const AuthException(this.mensaje, {this.codigo});

  final String mensaje;
  final String? codigo;

  @override
  String toString() => mensaje;
}

/// Valida los campos de autenticación en el cliente antes de llamar a Firebase.
class AuthValidators {
  const AuthValidators._();

  static String? validarNombre(String? valor) {
    final limpio = valor?.trim() ?? '';
    if (limpio.isEmpty) {
      return 'Escribe tu nombre.';
    }
    if (limpio.length < 2) {
      return 'El nombre debe tener al menos 2 letras.';
    }
    return null;
  }

  static String? validarCorreo(String? valor) {
    final limpio = valor?.trim() ?? '';
    if (limpio.isEmpty) {
      return 'Escribe tu correo electrónico.';
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(limpio)) {
      return 'Escribe un correo válido (ejemplo: nombre@correo.com).';
    }
    return null;
  }

  static String? validarPassword(String? valor) {
    final texto = valor ?? '';
    if (texto.isEmpty) {
      return 'Escribe tu contraseña.';
    }
    if (texto.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    return null;
  }
}

/// Traduce códigos de error de FirebaseAuth a mensajes claros en español de Colombia
/// (prompts/slice-01-auth.md y .agents/rules/flutter.md).
AuthException mapearErrorFirebaseAuth(Object error) {
  if (error is AuthException) {
    return error;
  }
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return const AuthException(
          'Este correo ya tiene una cuenta. Intenta entrar o recuperar tu contraseña.',
          codigo: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthException(
          'La contraseña es muy débil. Usa al menos 8 caracteres.',
          codigo: 'weak-password',
        );
      case 'invalid-email':
        return const AuthException(
          'Escribe un correo válido (ejemplo: nombre@correo.com).',
          codigo: 'invalid-email',
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return const AuthException(
          'El correo o la contraseña no coinciden. Revisa e intenta de nuevo.',
          codigo: 'invalid-credential',
        );
      case 'network-request-failed':
        return const AuthException(
          'No hay conexión a internet. Revisa tu red e intenta de nuevo.',
          codigo: 'network-request-failed',
        );
      case 'too-many-requests':
        return const AuthException(
          'Demasiados intentos seguidos. Espera un momento antes de volver a intentar.',
          codigo: 'too-many-requests',
        );
      default:
        return AuthException(
          'No pudimos completar la operación (${error.code}). Intenta de nuevo.',
          codigo: error.code,
        );
    }
  }
  return const AuthException(
    'Ocurrió un problema inesperado. Revisa tu conexión e intenta de nuevo.',
  );
}
