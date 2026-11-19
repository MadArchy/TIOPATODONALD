import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../../../core/utils/qr_invitacion.dart';
import '../../../data/models/invitacion_hogar.dart';
import '../../../data/repositories/hogar_repository.dart';

class HogarController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<String?> crearHogar({required String nombre}) async {
    state = const AsyncLoading();
    String? hogarId;
    state = await AsyncValue.guard(() async {
      hogarId = await ref
          .read(hogarRepositoryProvider)
          .crearHogar(nombre: nombre);
    });
    return state.hasError ? null : hogarId;
  }

  Future<InvitacionHogar?> generarInvitacion({required String hogarId}) async {
    state = const AsyncLoading();
    InvitacionHogar? invitacion;
    state = await AsyncValue.guard(() async {
      invitacion = await ref
          .read(hogarRepositoryProvider)
          .generarInvitacion(hogarId: hogarId);
    });
    return state.hasError ? null : invitacion;
  }

  Future<bool> unirseConCodigo({
    required String hogarId,
    required String codigo,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(hogarRepositoryProvider).unirseConCodigo(
            hogarId: hogarId,
            codigo: codigo,
          );
    });
    return !state.hasError;
  }

  Future<bool> unirseDesdeQrRaw(String rawQr) async {
    final payload = parseInvitacionQr(rawQr);
    if (payload == null) {
      state = AsyncError(
        const HogarException(
          'El código QR no pertenece a una invitación de PATO DONALD.',
        ),
        StackTrace.current,
      );
      return false;
    }
    return unirseConCodigo(
      hogarId: payload.hogarId,
      codigo: payload.codigo,
    );
  }

  Future<bool> sacarMiembro({
    required String hogarId,
    required String miembroUid,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(hogarRepositoryProvider).sacarMiembro(
            hogarId: hogarId,
            miembroUid: miembroUid,
          );
    });
    return !state.hasError;
  }

  Future<bool> guardarPresupuestoYPeriodoInicial({
    required String uid,
    required String hogarId,
    required int montoPresupuesto,
    required int diaInicioPeriodo,
  }) async {
    state = const AsyncLoading();
    final ahora = ref.read(clockProvider).now();
    state = await AsyncValue.guard(() async {
      await ref
          .read(hogarRepositoryProvider)
          .guardarPresupuestoYPeriodoInicial(
            uid: uid,
            hogarId: hogarId,
            montoPresupuesto: montoPresupuesto,
            diaInicioPeriodo: diaInicioPeriodo,
            ahora: ahora,
          );
    });
    return !state.hasError;
  }

  Future<bool> cambiarPresupuesto({
    required String hogarId,
    required int monto,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(hogarRepositoryProvider).cambiarPresupuesto(
            hogarId: hogarId,
            monto: monto,
          );
    });
    return !state.hasError;
  }

  Future<bool> guardarDiaInicioPendiente({
    required String uid,
    required int? diaInicioPendiente,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(hogarRepositoryProvider).guardarDiaInicioPendiente(
            uid: uid,
            diaInicioPendiente: diaInicioPendiente,
          );
    });
    return !state.hasError;
  }

  void limpiarError() {
    if (state.hasError) {
      state = const AsyncData(null);
    }
  }
}

final hogarControllerProvider =
    AsyncNotifierProvider<HogarController, void>(HogarController.new);
