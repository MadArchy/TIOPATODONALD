import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/firebase_init.dart';
import '../../core/utils/conectividad.dart';
import '../models/deuda_interna.dart';
import '../models/pago_interno.dart';
import 'auth_repository.dart';
import 'hogar_repository.dart';

class DeudasInternasException implements Exception {
  const DeudasInternasException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato del repositorio de deudas entre miembros (Slice 6).
abstract class DeudasInternasRepository {
  Stream<List<DeudaInterna>> observarDeudasInternas({
    required String hogarId,
    required String uid,
    required bool esAdmin,
  });

  Stream<List<PagoInterno>> observarPagos({
    required String hogarId,
    required String deudaId,
  });

  Future<String> crearDeudaInterna({
    required String hogarId,
    required String acreedorUid,
    required String deudorUid,
    required int monto,
    required String concepto,
  });

  Future<void> responderDeuda({
    required String hogarId,
    required String deudaId,
    required String deudorUid,
    required bool aceptar,
  });

  Future<String> registrarPago({
    required String hogarId,
    required String deudaId,
    required String deudorUid,
    required int monto,
    required DateTime fecha,
  });

  Future<({int saldo, String estado, bool yaConfirmado})> confirmarPago({
    required String hogarId,
    required String deudaInternaId,
    required String pagoId,
  });
}

class FirebaseDeudasInternasRepository implements DeudasInternasRepository {
  FirebaseDeudasInternasRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    required this.conectividad,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ??
            FirebaseFunctions.instanceFor(region: kFirebaseRegion);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final ConectividadService conectividad;

  CollectionReference<Map<String, dynamic>> _col(String hogarId) {
    return _firestore
        .collection('hogares')
        .doc(hogarId)
        .collection('deudasInternas');
  }

  Future<void> _exigirInternet() async {
    final ok = await conectividad.tieneInternet();
    if (!ok) {
      throw const DeudasInternasException(kMensajeNecesitasInternet);
    }
  }

  DeudasInternasException _mapearError(Object error) {
    if (error is DeudasInternasException) return error;
    if (error is FirebaseFunctionsException) {
      if (error.code == 'unavailable' || error.code == 'deadline-exceeded') {
        return const DeudasInternasException(kMensajeNecesitasInternet);
      }
      final msg = (error.message ?? '').trim();
      if (msg.isNotEmpty) return DeudasInternasException(msg);
    }
    return const DeudasInternasException(
      'No pudimos completar la acción. Revisa tu conexión e intenta de nuevo.',
    );
  }

  List<DeudaInterna> _ordenar(List<DeudaInterna> lista) {
    lista.sort((a, b) => b.creadaEn.compareTo(a.creadaEn));
    return lista;
  }

  @override
  Stream<List<DeudaInterna>> observarDeudasInternas({
    required String hogarId,
    required String uid,
    required bool esAdmin,
  }) {
    final col = _col(hogarId);
    // Admin lee todas; miembro solo las suyas (OR para pasar security rules).
    final query = esAdmin
        ? col
        : col.where(
            Filter.or(
              Filter('acreedorUid', isEqualTo: uid),
              Filter('deudorUid', isEqualTo: uid),
            ),
          );
    return query.snapshots().map((snap) {
      return _ordenar(snap.docs.map(DeudaInterna.fromFirestore).toList());
    });
  }

  @override
  Stream<List<PagoInterno>> observarPagos({
    required String hogarId,
    required String deudaId,
  }) {
    return _col(hogarId)
        .doc(deudaId)
        .collection('pagos')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PagoInterno.fromFirestore).toList());
  }

  @override
  Future<String> crearDeudaInterna({
    required String hogarId,
    required String acreedorUid,
    required String deudorUid,
    required int monto,
    required String concepto,
  }) async {
    if (acreedorUid == deudorUid) {
      throw const DeudasInternasException(
        'No puedes cobrarte a ti mismo.',
      );
    }
    if (monto <= 0) {
      throw const DeudasInternasException('El monto debe ser mayor a \$0.');
    }
    final conceptoTrim = concepto.trim();
    if (conceptoTrim.isEmpty) {
      throw const DeudasInternasException('Escribe un concepto.');
    }

    final docRef = _col(hogarId).doc();
    await docRef.set(<String, dynamic>{
      'acreedorUid': acreedorUid,
      'deudorUid': deudorUid,
      'montoInicial': monto,
      'saldo': monto,
      'concepto': conceptoTrim,
      'estado': 'pendiente',
      'creadaEn': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  @override
  Future<void> responderDeuda({
    required String hogarId,
    required String deudaId,
    required String deudorUid,
    required bool aceptar,
  }) async {
    final ref = _col(hogarId).doc(deudaId);
    final snap = await ref.get();
    if (!snap.exists) {
      throw const DeudasInternasException('No encontramos esa deuda.');
    }
    final data = snap.data()!;
    if (data['deudorUid'] != deudorUid) {
      throw const DeudasInternasException(
        'Solo quien debe puede aceptar o rechazar.',
      );
    }
    if (data['estado'] != 'pendiente') {
      throw const DeudasInternasException(
        'Esta deuda ya fue respondida.',
      );
    }
    await ref.update(<String, dynamic>{
      'estado': aceptar ? 'aceptada' : 'rechazada',
    });
  }

  @override
  Future<String> registrarPago({
    required String hogarId,
    required String deudaId,
    required String deudorUid,
    required int monto,
    required DateTime fecha,
  }) async {
    if (monto <= 0) {
      throw const DeudasInternasException('El monto debe ser mayor a \$0.');
    }

    final deudaRef = _col(hogarId).doc(deudaId);
    final deudaSnap = await deudaRef.get();
    if (!deudaSnap.exists) {
      throw const DeudasInternasException('No encontramos esa deuda.');
    }
    final deuda = deudaSnap.data()!;
    if (deuda['deudorUid'] != deudorUid) {
      throw const DeudasInternasException(
        'Solo quien debe puede registrar un pago.',
      );
    }
    if (deuda['estado'] != 'aceptada') {
      throw const DeudasInternasException(
        'Solo puedes pagar deudas aceptadas.',
      );
    }

    final pagoRef = deudaRef.collection('pagos').doc();
    await pagoRef.set(<String, dynamic>{
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
      'registradoPor': deudorUid,
      'confirmado': false,
      'confirmadoEn': null,
    });
    return pagoRef.id;
  }

  @override
  Future<({int saldo, String estado, bool yaConfirmado})> confirmarPago({
    required String hogarId,
    required String deudaInternaId,
    required String pagoId,
  }) async {
    await _exigirInternet();
    try {
      final callable = _functions.httpsCallable('confirmarPagoInterno');
      final result = await callable.call(<String, dynamic>{
        'hogarId': hogarId,
        'deudaInternaId': deudaInternaId,
        'pagoId': pagoId,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return (
        saldo: (data['saldo'] as num?)?.toInt() ?? 0,
        estado: (data['estado'] as String?) ?? 'aceptada',
        yaConfirmado: data['yaConfirmado'] == true,
      );
    } catch (e) {
      throw _mapearError(e);
    }
  }
}

final deudasInternasRepositoryProvider =
    Provider<DeudasInternasRepository>((ref) {
  return FirebaseDeudasInternasRepository(
    conectividad: ref.watch(conectividadServiceProvider),
  );
});

final deudasInternasHogarProvider =
    StreamProvider<List<DeudaInterna>>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final hogar = ref.watch(hogarActualProvider).value;
  final hogarId = usuario?.hogarId;
  final uid = usuario?.uid;
  if (hogarId == null || hogarId.isEmpty || uid == null) {
    return Stream.value(const <DeudaInterna>[]);
  }
  final esAdmin = hogar != null && hogar.adminUid == uid;
  return ref.watch(deudasInternasRepositoryProvider).observarDeudasInternas(
        hogarId: hogarId,
        uid: uid,
        esAdmin: esAdmin,
      );
});

final pagosInternosProvider =
    StreamProvider.family<List<PagoInterno>, String>((ref, deudaId) {
  final hogarId = ref.watch(usuarioActualProvider).value?.hogarId;
  if (hogarId == null || hogarId.isEmpty || deudaId.isEmpty) {
    return Stream.value(const <PagoInterno>[]);
  }
  return ref.watch(deudasInternasRepositoryProvider).observarPagos(
        hogarId: hogarId,
        deudaId: deudaId,
      );
});
