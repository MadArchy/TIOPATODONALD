import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/firebase_init.dart';
import '../../core/correcciones.dart';
import '../../core/utils/conectividad.dart';
import '../models/correccion.dart';
import '../models/entrada_auditoria.dart';
import '../models/movimiento.dart';
import 'auth_repository.dart';

class CorreccionesException implements Exception {
  const CorreccionesException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato del repositorio de correcciones (Slice 7).
abstract class CorreccionesRepository {
  Stream<List<Correccion>> observarPendientes(String hogarId);

  Stream<List<Correccion>> observarMisCorrecciones({
    required String hogarId,
    required String uid,
  });

  Stream<List<EntradaAuditoria>> observarAuditoriaMovimiento({
    required String hogarId,
    required String movimientoId,
  });

  Future<String> pedirCorreccion({
    required String hogarId,
    required Movimiento movimiento,
    required String solicitanteUid,
    required int diaInicioDueno,
    required DateTime ahora,
    required String motivo,
    required Map<String, dynamic> cambios,
  });

  Future<void> resolverCorreccion({
    required String hogarId,
    required String correccionId,
    required bool aprobar,
    String? motivoRechazo,
  });
}

class FirebaseCorreccionesRepository implements CorreccionesRepository {
  FirebaseCorreccionesRepository({
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
        .collection('correcciones');
  }

  Future<void> _exigirInternet() async {
    final ok = await conectividad.tieneInternet();
    if (!ok) {
      throw const CorreccionesException(kMensajeNecesitasInternet);
    }
  }

  CorreccionesException _mapearError(Object error) {
    if (error is CorreccionesException) return error;
    if (error is FirebaseFunctionsException) {
      if (error.code == 'unavailable' || error.code == 'deadline-exceeded') {
        return const CorreccionesException(kMensajeNecesitasInternet);
      }
      final msg = (error.message ?? '').trim();
      if (msg.isNotEmpty) return CorreccionesException(msg);
    }
    return const CorreccionesException(
      'No pudimos completar la acción. Revisa tu conexión e intenta de nuevo.',
    );
  }

  Map<String, dynamic> _serializarCambios(Map<String, dynamic> cambios) {
    final out = <String, dynamic>{};
    for (final e in cambios.entries) {
      final v = e.value;
      if (v is DateTime) {
        out[e.key] = Timestamp.fromDate(v);
      } else {
        out[e.key] = v;
      }
    }
    return out;
  }

  @override
  Stream<List<Correccion>> observarPendientes(String hogarId) {
    return _col(hogarId)
        .where('estado', isEqualTo: 'pendiente')
        .orderBy('creadoEn', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Correccion.fromFirestore).toList());
  }

  @override
  Stream<List<Correccion>> observarMisCorrecciones({
    required String hogarId,
    required String uid,
  }) {
    return _col(hogarId)
        .where('solicitanteUid', isEqualTo: uid)
        .orderBy('creadoEn', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Correccion.fromFirestore).toList());
  }

  @override
  Stream<List<EntradaAuditoria>> observarAuditoriaMovimiento({
    required String hogarId,
    required String movimientoId,
  }) {
    return _firestore
        .collection('hogares')
        .doc(hogarId)
        .collection('auditoria')
        .where('movimientoId', isEqualTo: movimientoId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(EntradaAuditoria.fromFirestore).toList());
  }

  @override
  Future<String> pedirCorreccion({
    required String hogarId,
    required Movimiento movimiento,
    required String solicitanteUid,
    required int diaInicioDueno,
    required DateTime ahora,
    required String motivo,
    required Map<String, dynamic> cambios,
  }) async {
    if (!dentroDePlazoCorreccion(
      periodoIdMovimiento: movimiento.periodoId,
      diaInicioDueno: diaInicioDueno,
      ahora: ahora,
    )) {
      throw const CorreccionesException(
        'Ya pasó el plazo para corregir este movimiento.',
      );
    }

    final validacion = validarCambiosCorreccion(
      cambios: cambios,
      tipoActual: movimiento.tipo,
      estadoActual: movimiento.estado,
      categoriaActual: movimiento.categoria,
      deudaIdActual: movimiento.deudaId,
      motivo: motivo,
    );
    if (!validacion.esValida) {
      throw CorreccionesException(
        validacion.mensaje ?? 'La corrección no es válida.',
      );
    }

    final docRef = _col(hogarId).doc();
    await docRef.set(<String, dynamic>{
      'movimientoId': movimiento.id,
      'solicitanteUid': solicitanteUid,
      'motivo': motivo.trim(),
      'cambios': _serializarCambios(cambios),
      'estado': 'pendiente',
      'resueltaPor': null,
      'resueltaEn': null,
      'motivoRechazo': null,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  @override
  Future<void> resolverCorreccion({
    required String hogarId,
    required String correccionId,
    required bool aprobar,
    String? motivoRechazo,
  }) async {
    await _exigirInternet();
    if (!aprobar && (motivoRechazo == null || motivoRechazo.trim().isEmpty)) {
      throw const CorreccionesException(
        'Escribe el motivo del rechazo.',
      );
    }
    try {
      final callable = _functions.httpsCallable('resolverCorreccion');
      await callable.call(<String, dynamic>{
        'hogarId': hogarId,
        'correccionId': correccionId,
        'aprobar': aprobar,
        if (!aprobar) 'motivoRechazo': motivoRechazo!.trim(),
      });
    } catch (e) {
      throw _mapearError(e);
    }
  }
}

final correccionesRepositoryProvider = Provider<CorreccionesRepository>((ref) {
  return FirebaseCorreccionesRepository(
    conectividad: ref.watch(conectividadServiceProvider),
  );
});

final correccionesPendientesProvider = StreamProvider<List<Correccion>>((ref) {
  final hogarId = ref.watch(usuarioActualProvider).value?.hogarId;
  if (hogarId == null || hogarId.isEmpty) {
    return Stream.value(const <Correccion>[]);
  }
  return ref.watch(correccionesRepositoryProvider).observarPendientes(hogarId);
});

final auditoriaMovimientoProvider =
    StreamProvider.family<List<EntradaAuditoria>, String>((ref, movimientoId) {
  final hogarId = ref.watch(usuarioActualProvider).value?.hogarId;
  if (hogarId == null || hogarId.isEmpty || movimientoId.isEmpty) {
    return Stream.value(const <EntradaAuditoria>[]);
  }
  return ref.watch(correccionesRepositoryProvider).observarAuditoriaMovimiento(
        hogarId: hogarId,
        movimientoId: movimientoId,
      );
});
