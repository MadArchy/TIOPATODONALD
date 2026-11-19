import 'dart:async';

import 'package:app/app.dart';
import 'package:app/core/errors/auth_failures.dart';
import 'package:app/data/models/preferencias_avisos.dart';
import 'package:app/data/models/usuario.dart';
import 'package:app/data/repositories/auth_repository.dart';
import 'package:app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository implements AuthRepository {
  final _uidController = StreamController<String?>.broadcast();
  final Map<String, Usuario> _usuarios = {};
  String? _uidActual;

  void emitirUid(String? uid) {
    _uidActual = uid;
    _uidController.add(uid);
  }

  @override
  Stream<String?> observarUidAutenticado() async* {
    yield _uidActual;
    yield* _uidController.stream;
  }

  @override
  Stream<Usuario?> observarUsuario(String uid) async* {
    yield _usuarios[uid];
  }

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    if (password.length < 8) {
      throw const AuthException('La contraseña debe tener al menos 8 caracteres.');
    }
    final usuario = Usuario(
      uid: 'uid-nuevo',
      nombre: nombre.trim(),
      email: email.trim().toLowerCase(),
      hogarId: null,
      diaInicioPeriodo: 1,
      creadoEn: DateTime(2026, 11, 18),
    );
    _usuarios[usuario.uid] = usuario;
    emitirUid(usuario.uid);
    return usuario;
  }

  @override
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final encontrado = _usuarios.values
        .where((u) => u.email == email.trim().toLowerCase())
        .firstOrNull;
    if (encontrado == null || password != 'secreto123') {
      throw const AuthException(
        'El correo o la contraseña no coinciden. Revisa e intenta de nuevo.',
      );
    }
    emitirUid(encontrado.uid);
  }

  @override
  Future<void> enviarCorreoRecuperacion({required String email}) async {
    final err = AuthValidators.validarCorreo(email);
    if (err != null) {
      throw AuthException(err);
    }
  }

  @override
  Future<void> cerrarSesion() async {
    emitirUid(null);
  }

  @override
  Future<void> registrarFcmToken({
    required String uid,
    required String token,
  }) async {}

  @override
  Future<void> quitarFcmToken({
    required String uid,
    required String token,
  }) async {}

  @override
  Future<void> guardarHoraRecordatorio({
    required String uid,
    required String? horaRecordatorio,
  }) async {}

  @override
  Future<void> guardarPreferenciasAvisos({
    required String uid,
    required PreferenciasAvisos preferencias,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({kOnboardingVistoKey: true});
  });

  testWidgets(
      'Flujo completo: Bienvenida -> Registro -> Sin Hogar -> Perfil -> Cerrar sesión',
      (tester) async {
    final fakeRepo = FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
          onboardingVistoProvider.overrideWith(_OnboardingVistoTrue.new),
        ],
        child: const PatoDonaldApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Arranca sin sesión en Bienvenida
    expect(find.text('Crear mi cuenta'), findsOneWidget);
    expect(find.text('Ya tengo cuenta'), findsOneWidget);

    // 2. Va a Registro
    await tester.tap(find.byKey(const Key('btn_ir_a_registro')));
    await tester.pumpAndSettle();

    // 3. Completa el formulario de registro
    await tester.enterText(
      find.byKey(const Key('input_registro_nombre')),
      'Daisy',
    );
    await tester.enterText(
      find.byKey(const Key('input_registro_correo')),
      'daisy@patodonald.co',
    );
    await tester.enterText(
      find.byKey(const Key('input_registro_password')),
      'secreto123',
    );
    await tester.tap(find.byKey(const Key('btn_submit_registro')));
    await tester.pumpAndSettle();

    // 4. Redirige a "Crea o únete a un hogar" porque hogarId == null
    expect(find.text('Crea o únete a un hogar'), findsOneWidget);
    expect(find.text('Hola, Daisy'), findsOneWidget);

    // 5. Abre perfil provisional y cierra sesión
    await tester.tap(find.byKey(const Key('btn_ir_a_perfil_desde_sin_hogar')));
    await tester.pumpAndSettle();

    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.text('daisy@patodonald.co'), findsOneWidget);

    await tester.tap(find.byKey(const Key('btn_cerrar_sesion')));
    await tester.pumpAndSettle();

    // 6. Vuelve a Bienvenida
    expect(find.text('Crear mi cuenta'), findsOneWidget);
  });
}

class _OnboardingVistoTrue extends OnboardingVisto {
  @override
  Future<bool> build() async => true;
}
