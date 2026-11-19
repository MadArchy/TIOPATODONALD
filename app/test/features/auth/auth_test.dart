import 'package:app/core/errors/auth_failures.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/data/models/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators', () {
    test('valida nombre no vacío y mínimo 2 letras', () {
      expect(AuthValidators.validarNombre(''), isNotNull);
      expect(AuthValidators.validarNombre('A'), isNotNull);
      expect(AuthValidators.validarNombre('Ana'), isNull);
    });

    test('valida formato de correo electrónico', () {
      expect(AuthValidators.validarCorreo(''), isNotNull);
      expect(AuthValidators.validarCorreo('correo-invalido'), isNotNull);
      expect(AuthValidators.validarCorreo('familia@patodonald.co'), isNull);
    });

    test('valida contraseña de mínimo 8 caracteres', () {
      expect(AuthValidators.validarPassword(''), isNotNull);
      expect(AuthValidators.validarPassword('1234567'), isNotNull);
      expect(AuthValidators.validarPassword('12345678'), isNull);
    });
  });

  group('mapearErrorFirebaseAuth', () {
    test('traduce códigos comunes de FirebaseAuth a español claro', () {
      final yaRegistrado = mapearErrorFirebaseAuth(
        FirebaseAuthException(code: 'email-already-in-use'),
      );
      expect(yaRegistrado.mensaje, contains('ya tiene una cuenta'));

      final debil = mapearErrorFirebaseAuth(
        FirebaseAuthException(code: 'weak-password'),
      );
      expect(debil.mensaje, contains('8 caracteres'));

      final credenciales = mapearErrorFirebaseAuth(
        FirebaseAuthException(code: 'invalid-credential'),
      );
      expect(
        credenciales.mensaje,
        contains('correo o la contraseña no coinciden'),
      );

      final sinRed = mapearErrorFirebaseAuth(
        FirebaseAuthException(code: 'network-request-failed'),
      );
      expect(sinRed.mensaje, contains('No hay conexión a internet'));
    });
  });

  group('evaluarRedireccionRouter (guardas del Router)', () {
    test('sin onboarding visto redirige a /onboarding', () {
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/bienvenida',
          uid: null,
          usuario: null,
          cargandoEstado: false,
          onboardingVisto: false,
        ),
        '/onboarding',
      );
    });

    final usuarioSinHogar = Usuario(
      uid: 'u1',
      nombre: 'Donald',
      email: 'donald@pato.co',
      hogarId: null,
      diaInicioPeriodo: 1,
      creadoEn: DateTime(2026, 11, 18),
    );

    final usuarioConHogar = usuarioSinHogar.copyWith(hogarId: 'hogar-123');

    test('sin sesión redirige a /bienvenida salvo rutas públicas', () {
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/inicio',
          uid: null,
          usuario: null,
          cargandoEstado: false,
        ),
        '/bienvenida',
      );
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/login',
          uid: null,
          usuario: null,
          cargandoEstado: false,
        ),
        isNull,
      );
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/registro',
          uid: null,
          usuario: null,
          cargandoEstado: false,
        ),
        isNull,
      );
    });

    test('con sesión y hogarId == null redirige a /sin-hogar (permite /perfil)', () {
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/bienvenida',
          uid: 'u1',
          usuario: usuarioSinHogar,
          cargandoEstado: false,
        ),
        '/sin-hogar',
      );
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/inicio',
          uid: 'u1',
          usuario: usuarioSinHogar,
          cargandoEstado: false,
        ),
        '/sin-hogar',
      );
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/perfil',
          uid: 'u1',
          usuario: usuarioSinHogar,
          cargandoEstado: false,
        ),
        isNull,
      );
    });

    test('con sesión y hogarId != null redirige a /inicio (permite /perfil)', () {
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/sin-hogar',
          uid: 'u1',
          usuario: usuarioConHogar,
          cargandoEstado: false,
        ),
        '/inicio',
      );
      expect(
        evaluarRedireccionRouter(
          ubicacionActual: '/perfil',
          uid: 'u1',
          usuario: usuarioConHogar,
          cargandoEstado: false,
        ),
        isNull,
      );
    });
  });
}
