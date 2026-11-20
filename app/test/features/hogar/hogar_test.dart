import 'dart:async';

import 'package:app/app.dart';
import 'package:app/core/periodo.dart';
import 'package:app/core/utils/clock.dart';
import 'package:app/core/utils/conectividad.dart';
import 'package:app/core/utils/qr_invitacion.dart';
import 'package:app/data/models/hogar.dart';
import 'package:app/data/models/invitacion_hogar.dart';
import 'package:app/data/models/miembro_hogar.dart';
import 'package:app/data/models/preferencias_avisos.dart';
import 'package:app/data/models/presupuesto.dart';
import 'package:app/data/models/resumen_periodo.dart';
import 'package:app/data/models/usuario.dart';
import 'package:app/data/repositories/auth_repository.dart';
import 'package:app/data/repositories/hogar_repository.dart';
import 'package:app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeConectividadService implements ConectividadService {
  FakeConectividadService({this.conectado = true});

  bool conectado;
  final _ctrl = StreamController<bool>.broadcast();

  void cambiarEstado(bool nuevo) {
    conectado = nuevo;
    _ctrl.add(nuevo);
  }

  @override
  Future<bool> tieneInternet() async => conectado;

  @override
  Stream<bool> observarConectividad() async* {
    yield conectado;
    yield* _ctrl.stream;
  }
}

class FakeAuthRepoHogar implements AuthRepository {
  FakeAuthRepoHogar(this._usuarioInicial);

  Usuario? _usuarioInicial;
  final _usuarioCtrl = StreamController<Usuario?>.broadcast();

  void actualizarUsuario(Usuario? u) {
    _usuarioInicial = u;
    _usuarioCtrl.add(u);
  }

  @override
  Stream<String?> observarUidAutenticado() async* {
    yield _usuarioInicial?.uid;
  }

  @override
  Stream<Usuario?> observarUsuario(String uid) async* {
    yield _usuarioInicial;
    yield* _usuarioCtrl.stream;
  }

  @override
  Future<void> cerrarSesion() async {}

  @override
  Future<void> enviarCorreoRecuperacion({required String email}) async {}

  @override
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {}

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async =>
      _usuarioInicial!;

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

class FakeHogarRepository implements HogarRepository {
  FakeHogarRepository({required this.authRepo});

  final FakeAuthRepoHogar authRepo;
  final _hogarCtrl = StreamController<Hogar?>.broadcast();
  final _presupuestoCtrl = StreamController<Presupuesto?>.broadcast();
  Hogar? hogar;
  final List<MiembroHogar> miembros = [];
  InvitacionHogar? invitacionActiva;
  Presupuesto? ultimoPresupuestoGuardado;
  int? ultimoDiaInicioGuardado;

  @override
  Stream<Hogar?> observarHogar(String hogarId) async* {
    yield hogar;
    yield* _hogarCtrl.stream;
  }

  @override
  Stream<List<MiembroHogar>> observarMiembrosActivos(String hogarId) async* {
    yield List<MiembroHogar>.from(miembros);
  }

  @override
  Stream<InvitacionHogar?> observarInvitacionActiva(String hogarId) async* {
    yield invitacionActiva;
  }

  @override
  Stream<Presupuesto?> observarPresupuesto({
    required String hogarId,
    required String uid,
    required String periodoId,
  }) async* {
    yield ultimoPresupuestoGuardado;
    yield* _presupuestoCtrl.stream;
  }

  @override
  Future<String> crearHogar({required String nombre}) async {
    final ahora = DateTime(2026, 11, 18, 12, 0);
    hogar = Hogar(
      id: 'hogar-pato-1',
      nombre: nombre.trim(),
      adminUid: 'u1',
      creadoEn: ahora,
    );
    miembros
      ..clear()
      ..add(
        MiembroHogar(
          uid: 'u1',
          nombre: 'Donald',
          rol: 'admin',
          estado: 'activo',
          unidoEn: ahora,
        ),
      );
    authRepo.actualizarUsuario(
      authRepo._usuarioInicial?.copyWith(hogarId: 'hogar-pato-1'),
    );
    return 'hogar-pato-1';
  }

  @override
  Future<InvitacionHogar> generarInvitacion({required String hogarId}) async {
    final ahora = DateTime(2026, 11, 18, 12, 0);
    invitacionActiva = InvitacionHogar(
      id: 'inv-1',
      hogarId: hogarId,
      codigo: 'abcdef1234567890abcdef12',
      creadaPor: 'u1',
      creadaEn: ahora,
      expiraEn: ahora.add(const Duration(hours: 4)),
      activa: true,
    );
    return invitacionActiva!;
  }

  @override
  Future<String> unirseConCodigo({
    required String hogarId,
    required String codigo,
  }) async {
    authRepo.actualizarUsuario(
      authRepo._usuarioInicial?.copyWith(hogarId: hogarId),
    );
    return hogarId;
  }

  @override
  Future<void> sacarMiembro({
    required String hogarId,
    required String miembroUid,
  }) async {
    miembros.removeWhere((m) => m.uid == miembroUid);
  }

  @override
  Future<void> guardarPresupuestoYPeriodoInicial({
    required String uid,
    required String hogarId,
    required int montoPresupuesto,
    required int diaInicioPeriodo,
    required DateTime ahora,
  }) async {
    ultimoDiaInicioGuardado = diaInicioPeriodo;
    final p = periodoDe(ahora, diaInicioPeriodo);
    ultimoPresupuestoGuardado = Presupuesto(
      id: '${uid}_${p.periodoId}',
      uid: uid,
      periodoId: p.periodoId,
      monto: montoPresupuesto,
      actualizadoEn: ahora,
    );
    _presupuestoCtrl.add(ultimoPresupuestoGuardado);
    authRepo.actualizarUsuario(
      authRepo._usuarioInicial?.copyWith(diaInicioPeriodo: diaInicioPeriodo),
    );
  }

  @override
  Future<void> cambiarPresupuesto({
    required String hogarId,
    required int monto,
  }) async {
    final actual = ultimoPresupuestoGuardado;
    if (actual == null) return;
    ultimoPresupuestoGuardado = Presupuesto(
      id: actual.id,
      uid: actual.uid,
      periodoId: actual.periodoId,
      monto: monto,
      alertasEnviadas: actual.alertasEnviadas,
      actualizadoEn: DateTime(2026, 11, 18),
    );
    _presupuestoCtrl.add(ultimoPresupuestoGuardado);
  }

  @override
  Future<void> guardarDiaInicioPendiente({
    required String uid,
    required int? diaInicioPendiente,
  }) async {
    authRepo.actualizarUsuario(
      authRepo._usuarioInicial?.copyWith(
        diaInicioPendiente: diaInicioPendiente,
      ),
    );
  }

  @override
  Future<void> marcarAlertasEnviadas({
    required String hogarId,
    required String presupuestoId,
    required List<int> alertasEnviadas,
  }) async {
    final actual = ultimoPresupuestoGuardado;
    if (actual == null) return;
    ultimoPresupuestoGuardado = Presupuesto(
      id: actual.id,
      uid: actual.uid,
      periodoId: actual.periodoId,
      monto: actual.monto,
      alertasEnviadas: alertasEnviadas,
      actualizadoEn: actual.actualizadoEn,
    );
    _presupuestoCtrl.add(ultimoPresupuestoGuardado);
  }

  @override
  Stream<ResumenPeriodo?> observarResumen({
    required String hogarId,
    required String uid,
    required String periodoId,
  }) async* {
    yield null;
  }

  @override
  Stream<List<Presupuesto>> observarPresupuestosHogar(String hogarId) async* {
    yield ultimoPresupuestoGuardado == null
        ? const <Presupuesto>[]
        : <Presupuesto>[ultimoPresupuestoGuardado!];
  }
}

void main() {
  group('parseInvitacionQr (Deep link patodonald://unirse?h=..&c=..)', () {
    test('extrae hogarId y codigo de un deep link válido', () {
      final parsed = parseInvitacionQr(
        'patodonald://unirse?h=hogar-123&c=codigo9876543210',
      );
      expect(parsed, isNotNull);
      expect(parsed!.hogarId, 'hogar-123');
      expect(parsed.codigo, 'codigo9876543210');
      expect(
        parsed.toQrUrl(),
        'patodonald://unirse?h=hogar-123&c=codigo9876543210',
      );
    });

    test('devuelve null para URLs inválidas o sin parámetros requeridos', () {
      expect(parseInvitacionQr(''), isNull);
      expect(parseInvitacionQr('https://google.com'), isNull);
      expect(parseInvitacionQr('patodonald://unirse?h=soloHogar'), isNull);
    });
  });

  group('Flujos UI de Hogar, Presupuesto/Período y modo sin internet', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({kOnboardingVistoKey: true});
    });

    testWidgets(
        'Sin internet: muestra "Necesitas internet para esto" y no abre formulario',
        (tester) async {
      final usuarioSinHogar = Usuario(
        uid: 'u1',
        nombre: 'Donald',
        email: 'donald@pato.co',
        hogarId: null,
        diaInicioPeriodo: 1,
        creadoEn: DateTime(2026, 11, 18),
      );
      final fakeAuth = FakeAuthRepoHogar(usuarioSinHogar);
      final fakeHogar = FakeHogarRepository(authRepo: fakeAuth);
      final fakeConectividad = FakeConectividadService(conectado: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
            hogarRepositoryProvider.overrideWithValue(fakeHogar),
            conectividadServiceProvider.overrideWithValue(fakeConectividad),
            onboardingVistoProvider.overrideWith(_OnboardingVistoTrue.new),
          ],
          child: const PatoDonaldApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Necesitas internet para esto'), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn_abrir_crear_hogar')));
      await tester.pumpAndSettle();

      // El formulario de crear hogar no se abre sin internet
      expect(find.byKey(const Key('input_nombre_hogar')), findsNothing);
    });

    testWidgets(
        'Crear hogar -> lleva a "Tu presupuesto y tu período" -> guarda monto y día -> va a Inicio y Miembros/QR',
        (tester) async {
      final ahoraFijo = DateTime(2026, 11, 18, 12, 0);
      final usuarioSinHogar = Usuario(
        uid: 'u1',
        nombre: 'Donald',
        email: 'donald@pato.co',
        hogarId: null,
        diaInicioPeriodo: 1,
        creadoEn: ahoraFijo,
      );
      final fakeAuth = FakeAuthRepoHogar(usuarioSinHogar);
      final fakeHogar = FakeHogarRepository(authRepo: fakeAuth);
      final fakeConectividad = FakeConectividadService(conectado: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clockProvider.overrideWithValue(FixedClock(ahoraFijo)),
            authRepositoryProvider.overrideWithValue(fakeAuth),
            hogarRepositoryProvider.overrideWithValue(fakeHogar),
            conectividadServiceProvider.overrideWithValue(fakeConectividad),
            onboardingVistoProvider.overrideWith(_OnboardingVistoTrue.new),
          ],
          child: const PatoDonaldApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Toca "Crear hogar" e ingresa "Familia Pato"
      await tester.tap(find.byKey(const Key('btn_abrir_crear_hogar')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('input_nombre_hogar')),
        'Familia Pato',
      );
      await tester.tap(find.byKey(const Key('btn_confirmar_crear_hogar')));
      await tester.pumpAndSettle();

      // 2. Llega a "Tu presupuesto y tu período"
      expect(find.text('Tu presupuesto y tu período'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('input_presupuesto_monto')),
        '3.500.000',
      );
      await tester.tap(
        find.byKey(const Key('btn_guardar_presupuesto_periodo')),
      );
      await tester.pumpAndSettle();

      expect(fakeHogar.ultimoPresupuestoGuardado?.monto, 3500000);
      expect(fakeHogar.ultimoPresupuestoGuardado?.periodoId, '2026-11-01');

      // 3. Llega a Inicio con barra inferior, entra a la pestaña "Hogar" y abre "Miembros y código QR"
      expect(find.text('Familia Pato'), findsWidgets);
      expect(find.byKey(const Key('barra_navegacion_inferior')), findsOneWidget);
      await tester.tap(find.text('Hogar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hogar_item_miembros_qr')));
      await tester.pumpAndSettle();

      expect(find.text('Invitar a un familiar con código QR'), findsOneWidget);
      await tester.tap(find.byKey(const Key('btn_invitar_qr')));
      await tester.pumpAndSettle();

      // Muestra el QR con cuenta regresiva de 4 horas y botón "Generar nuevo"
      expect(find.byKey(const Key('qr_image_view')), findsOneWidget);
      expect(find.text('Generar nuevo'), findsOneWidget);
    });
  });
}

class _OnboardingVistoTrue extends OnboardingVisto {
  @override
  Future<bool> build() async => true;
}
