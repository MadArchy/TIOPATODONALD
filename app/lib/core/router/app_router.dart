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
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/correcciones/presentation/correcciones_admin_screen.dart';
import '../../features/deudas/presentation/deudas_screen.dart';
import '../../features/deudas_internas/presentation/detalle_deuda_interna_screen.dart';
import '../../features/home/presentation/dashboard_admin_screen.dart';
import '../../features/home/presentation/desglose_miembro_screen.dart';
import '../../features/home/presentation/inicio_screen.dart';
import '../../features/movimientos/presentation/detalle_movimiento_screen.dart';
import '../../features/movimientos/presentation/gastos_fijos_screen.dart';
import '../../features/movimientos/presentation/historial_movimientos_screen.dart';
import '../../features/presupuesto/presentation/configurar_presupuesto_periodo_screen.dart';

/// Función pura que evalúa la guarda de navegación:
/// - Sin sesión (`uid == null`) → `/bienvenida` (permitiendo `/login`, `/registro`, `/recuperar-password`)
/// - Con sesión y `hogarId == null` → `/sin-hogar` (permitiendo `/escanear-qr`, `/unirse`, `/perfil`)
/// - Con sesión, `hogarId != null` y sin presupuesto del período → `/configurar-periodo` (permitiendo `/miembros-qr`, `/perfil`)
/// - Con sesión, `hogarId != null` y con presupuesto → `/inicio` (permitiendo
///   `/configurar-periodo`, `/miembros-qr`, `/unirse`, `/perfil`, `/historial`,
///   `/movimiento/:id`, `/gastos-fijos`, `/deudas`, `/deudas-internas/:id`,
///   `/dashboard-admin`, `/desglose-miembro/:uid`, `/correcciones`)
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
    '/historial',
    '/gastos-fijos',
    '/deudas',
    '/dashboard-admin',
    '/correcciones',
    '/chat',
  };
  if (rutasConHogar.contains(ubicacionActual) ||
      ubicacionActual.startsWith('/movimiento/') ||
      ubicacionActual.startsWith('/deudas-internas/') ||
      ubicacionActual.startsWith('/desglose-miembro/')) {
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
        builder: (context, state) => const InicioScreen(),
      ),
      GoRoute(
        path: '/dashboard-admin',
        name: 'dashboard-admin',
        builder: (context, state) => const DashboardAdminScreen(),
      ),
      GoRoute(
        path: '/correcciones',
        name: 'correcciones',
        builder: (context, state) => const CorreccionesAdminScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/desglose-miembro/:uid',
        name: 'desglose-miembro',
        builder: (context, state) => DesgloseMiembroScreen(
          miembroUid: state.pathParameters['uid'] ?? '',
        ),
      ),
      GoRoute(
        path: '/historial',
        name: 'historial',
        builder: (context, state) => const HistorialMovimientosScreen(),
      ),
      GoRoute(
        path: '/movimiento/:id',
        name: 'movimiento',
        builder: (context, state) => DetalleMovimientoScreen(
          movimientoId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/gastos-fijos',
        name: 'gastos-fijos',
        builder: (context, state) => const GastosFijosScreen(),
      ),
      GoRoute(
        path: '/deudas',
        name: 'deudas',
        builder: (context, state) => const DeudasScreen(),
      ),
      GoRoute(
        path: '/deudas-internas/:id',
        name: 'deuda-interna',
        builder: (context, state) => DetalleDeudaInternaScreen(
          deudaId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/perfil',
        name: 'perfil',
        builder: (context, state) => const PerfilProvisionalScreen(),
      ),
    ],
  );
});
