import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/usuario.dart';
import '../../data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bienvenida_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/perfil_provisional_screen.dart';
import '../../features/auth/presentation/recuperar_password_screen.dart';
import '../../features/auth/presentation/registro_screen.dart';
import '../../features/hogar/presentation/sin_hogar_screen.dart';
import '../../features/home/presentation/inicio_provisional_screen.dart';

/// Función pura que evalúa la guarda de navegación del Slice 1:
/// - Sin sesión (`uid == null`) → `/bienvenida` (permitiendo `/login`, `/registro`, `/recuperar-password`)
/// - Con sesión y `hogarId == null` → `/sin-hogar` (permitiendo `/perfil`)
/// - Con sesión y `hogarId != null` → `/inicio` (permitiendo `/perfil`)
String? evaluarRedireccionRouter({
  required String ubicacionActual,
  required String? uid,
  required Usuario? usuario,
  required bool cargandoEstado,
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

  // Usuario con sesión activa:
  if (ubicacionActual == '/perfil') {
    return null;
  }

  final tieneHogar =
      usuario?.hogarId != null && usuario!.hogarId!.trim().isNotEmpty;

  if (!tieneHogar) {
    if (ubicacionActual == '/sin-hogar') {
      return null;
    }
    return '/sin-hogar';
  }

  if (ubicacionActual == '/inicio') {
    return null;
  }
  return '/inicio';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final uidAsync = ref.watch(authUidProvider);
  final usuarioAsync = ref.watch(usuarioActualProvider);

  return GoRouter(
    initialLocation: '/bienvenida',
    redirect: (context, state) {
      final cargando = uidAsync.isLoading ||
          (uidAsync.value != null && usuarioAsync.isLoading);
      return evaluarRedireccionRouter(
        ubicacionActual: state.matchedLocation,
        uid: uidAsync.value,
        usuario: usuarioAsync.value,
        cargandoEstado: cargando,
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
