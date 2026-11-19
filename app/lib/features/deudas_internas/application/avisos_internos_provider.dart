import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/deudas_internas.dart';
import '../../../data/models/deuda_interna.dart';
import '../../../data/models/pago_interno.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/deudas_internas_repository.dart';
import '../../../data/repositories/hogar_repository.dart';

/// Pagos no confirmados de deudas donde el usuario es acreedor (para avisos).
final pagosPendientesConfirmacionProvider =
    StreamProvider<List<({DeudaInterna deuda, PagoInterno pago})>>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final deudasAsync = ref.watch(deudasInternasHogarProvider);
  final deudas = deudasAsync.value ?? const <DeudaInterna>[];
  final uid = usuario?.uid;
  final hogarId = usuario?.hogarId;
  if (uid == null || hogarId == null || hogarId.isEmpty) {
    return Stream.value(const []);
  }

  final miasComoAcreedor = deudas
      .where((d) => d.acreedorUid == uid && d.estado == 'aceptada')
      .toList();
  if (miasComoAcreedor.isEmpty) {
    return Stream.value(const []);
  }

  final repo = ref.watch(deudasInternasRepositoryProvider);
  // Un stream por deuda; se re-evalúa cuando cambia la lista de deudas.
  final streams = miasComoAcreedor.map((deuda) {
    return repo.observarPagos(hogarId: hogarId, deudaId: deuda.id).map(
      (pagos) => pagos
          .where((p) => !p.confirmado)
          .map((p) => (deuda: deuda, pago: p))
          .toList(),
    );
  });

  return _combinarListas(streams);
});

Stream<List<T>> _combinarListas<T>(Iterable<Stream<List<T>>> streams) {
  final list = streams.toList();
  if (list.isEmpty) {
    return Stream.value(const []);
  }
  return Stream.multi((controller) {
    final latest = List<List<T>?>.filled(list.length, null);
    final subs = <dynamic>[];
    for (var i = 0; i < list.length; i++) {
      final index = i;
      subs.add(
        list[i].listen(
          (value) {
            latest[index] = value;
            if (latest.every((e) => e != null)) {
              controller.add([
                for (final parte in latest) ...parte!,
              ]);
            }
          },
          onError: controller.addError,
        ),
      );
    }
    controller.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };
  });
}

/// Bandeja in-app: pendientes de aceptar + pagos por confirmar.
final avisosInternosProvider = Provider<List<AvisoDeudaInterna>>((ref) {
  final uid = ref.watch(usuarioActualProvider).value?.uid;
  if (uid == null) return const [];

  final deudas = ref.watch(deudasInternasHogarProvider).value ?? const [];
  final miembros = ref.watch(miembrosHogarProvider).value ?? const [];
  final nombres = {for (final m in miembros) m.uid: m.nombre};

  final deudasTuple = deudas.map(
    (d) => (
      id: d.id,
      acreedorUid: d.acreedorUid,
      deudorUid: d.deudorUid,
      concepto: d.concepto,
      saldo: d.saldo,
      estado: d.estado,
      nombreContraparte: nombres[d.acreedorUid] ?? 'Alguien',
    ),
  );

  final pagosPend = ref.watch(pagosPendientesConfirmacionProvider).value ?? [];
  final pagosTuple = pagosPend.map(
    (e) => (
      deudaId: e.deuda.id,
      pagoId: e.pago.id,
      acreedorUid: e.deuda.acreedorUid,
      monto: e.pago.monto,
      confirmado: e.pago.confirmado,
      nombreDeudor: nombres[e.deuda.deudorUid] ?? 'Alguien',
    ),
  );

  return construirAvisosInternos(
    uid: uid,
    deudas: deudasTuple,
    pagos: pagosTuple,
  );
});
