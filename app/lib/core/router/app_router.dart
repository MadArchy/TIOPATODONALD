import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/usuario.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/hogar_repository.dart';
import '../../features/auth/presentation/bienvenida_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/perfil_provisional_screen.dart';
import '../../features/auth/presentation/recuperar_password_screen.dart';
import '../../features/auth/presentation/registro_screen.dart';
import '../../features/hogar/presentation/escanear_qr_screen.dart';
import '../../features/hogar/presentation/miembros_qr_screen.dart';
import '../../features/hogar/presentation/sin_hogar_screen.dart';
import '../../features/hogar/presentation/unirse_deeplink_screen.dart';
import '../../features/home/presentation/inicio_provisional_screen.dart';
import '../../features/presupuesto/presentation/configurar_presupuesto_periodo_screen.dart';

/// Función pura que evalúa la guarda de navegación:
/// - Sin sesión (`uid == null`) → `/bienvenida` (permitiendo `/login`, `/registro`, `/recuperar-password`)
/// - Con sesión y `hogarId == null` → `/sin-hogar` (permitiendo `/escanear-qr`, `/unirse`, `/perfil`)
/// - Con sesión, `hogarId != null` y sin presupuesto del período → `/configurar-periodo` (permitiendo `/miembros-qr`, `/perfil`)
/// - Con sesión, `hogarId != null` y con presupuesto → `/inicio` (permitiendo `/configurar-periodo`, `/miembros-qr`, `/unirse`, `/perfil`)
String? evaluarRedireccionRouter({
  required String ubicacionActual,
  required String? uid,
  required Usuario? usuario,
  required bool cargandoEstado,
  bool? tienePresupuestoVigente,
}) {
  if (cargandoEstado) {
    return null;
  }

  const rutasPublicas = <String>{
    '/bienvenida',
    '/login',
    '/registro',
    '/recuperar-password',
  };

  if (uid == null) {
    if (rutasPublicas.contains(ubicacionActual)) {
      return null;
    }
    return '/bienvenida';
  }

  // Rutas permitidas para cualquier usuario autenticado (con o sin hogar):
  if (ubicacionActual == '/perfil' || ubicacionActual == '/unirse') {
    return null;
  }

  final tieneHogar =
      usuario?.hogarId != null && usuario!.hogarId!.trim().isNotEmpty;

  if (!tieneHogar) {
    const rutasSinHogar = <String>{
      '/sin-hogar',
      '/escanear-qr',
    };
    if (rutasSinHogar.contains(ubicacionActual)) {
      return null;
    }
    return '/sin-hogar';
  }

  if (tienePresupuestoVigente == false) {
    if (ubicacionActual == '/configurar-periodo' ||
        ubicacionActual == '/miembros-qr') {
      return null;
    }
    return '/configurar-periodo';
  }

  const rutasConHogar = <String>{
    '/inicio',
    '/configurar-periodo',
    '/miembros-qr',
  };
  if (rutasConHogar.contains(ubicacionActual)) {
    return null;
  }
  return '/inicio';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final uidAsync = ref.watch(authUidProvider);
  final usuarioAsync = ref.watch(usuarioActualProvider);
  final presupuestoAsync = ref.watch(presupuestoVigenteProvider);

  return GoRouter(
    initialLocation: '/bienvenida',
    redirect: (context, state) {
      final tieneHogar = usuarioAsync.value?.hogarId != null &&
          usuarioAsync.value!.hogarId!.trim().isNotEmpty;
      final cargando = uidAsync.isLoading ||
          (uidAsync.value != null && usuarioAsync.isLoading) ||
          (tieneHogar && presupuestoAsync.isLoading);

      return evaluarRedireccionRouter(
        ubicacionActual: state.matchedLocation,
        uid: uidAsync.value,
        usuario: usuarioAsync.value,
        cargandoEstado: cargando,
        tienePresupuestoVigente:
            tieneHogar ? (presupuestoAsync.value != null) : null,
      );
    },
    routes: [
      GoRoute(
        path: '/bienvenida',
        name: 'bienvenida',
        builder: (context, state) => const BienvenidaScreen(),
      ),
      GoRoute(
        path: '/registro',
        name: 'registro',
        builder: (context, state) => const RegistroScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/recuperar-password',
        name: 'recuperar-password',
        builder: (context, state) => const RecuperarPasswordScreen(),
      ),
      GoRoute(
        path: '/sin-hogar',
        name: 'sin-hogar',
        builder: (context, state) => const SinHogarScreen(),
      ),
      GoRoute(
        path: '/escanear-qr',
        name: 'escanear-qr',
        builder: (context, state) => const EscanearQrScreen(),
      ),
      GoRoute(
        path: '/unirse',
        name: 'unirse',
        builder: (context, state) {
          final h = state.uri.queryParameters['h'] ?? '';
          final c = state.uri.queryParameters['c'] ?? '';
          return UnirseDeepLinkScreen(hogarId: h, codigo: c);
        },
      ),
      GoRoute(
        path: '/configurar-periodo',
        name: 'configurar-periodo',
        builder: (context, state) =>
            const ConfigurarPresupuestoPeriodoScreen(),
      ),
      GoRoute(
        path: '/miembros-qr',
        name: 'miembros-qr',
        builder: (context, state) => const MiembrosQrScreen(),
      ),
      GoRoute(
        path: '/inicio',
        name: 'inicio',
        builder: (context, state) => const InicioProvisionalScreen(),
      ),
      GoRoute(
        path: '/perfil',
        name: 'perfil',
        builder: (context, state) => const PerfilProvisionalScreen(),
      ),
    ],
  );
});
