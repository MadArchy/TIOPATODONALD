import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_repository.dart';

/// Controlador de acciones de autenticación (registro, login, recuperación, logout).
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).registrar(
            nombre: nombre,
            email: email,
            password: password,
          );
    });
    return !state.hasError;
  }

  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).iniciarSesion(
            email: email,
            password: password,
          );
    });
    return !state.hasError;
  }

  Future<bool> enviarCorreoRecuperacion({
    required String email,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).enviarCorreoRecuperacion(
            email: email,
          );
    });
    return !state.hasError;
  }

  Future<bool> cerrarSesion() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).cerrarSesion();
    });
    return !state.hasError;
  }

  void limpiarError() {
    if (state.hasError) {
      state = const AsyncData(null);
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
