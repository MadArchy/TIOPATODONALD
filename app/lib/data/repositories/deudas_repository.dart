import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/conectividad.dart';
import '../models/deuda.dart';
import 'auth_repository.dart';

class DeudasException implements Exception {
  const DeudasException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato del repositorio de deudas externas (Slice 5).
abstract class DeudasRepository {
  Stream<List<Deuda>> observarDeudas({required String hogarId});

  Future<String> crearDeuda({
    required String hogarId,
    required String entidad,
    required int saldoInicial,
    required int cuotaMensual,
    required int diaPago,
    int? numeroCuotas,
  });

  Future<void> actualizarDeuda({
    required String hogarId,
    required Deuda deuda,
    required String entidad,
    required int cuotaMensual,
    required int diaPago,
    int? numeroCuotas,
  });

  Future<void> desactivarDeuda({
    required String hogarId,
    required String deudaId,
  });
}

class FirebaseDeudasRepository implements DeudasRepository {
  FirebaseDeudasRepository({
    FirebaseFirestore? firestore,
    required this.conectividad,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final ConectividadService conectividad;

  CollectionReference<Map<String, dynamic>> _deudas(String hogarId) {
    return _firestore.collection('hogares').doc(hogarId).collection('deudas');
  }

  Future<void> _exigirInternet() async {
    final ok = await conectividad.tieneInternet();
    if (!ok) {
      throw const DeudasException(kMensajeNecesitasInternet);
    }
  }

  void _validarCampos({
    required String entidad,
    required int cuotaMensual,
    required int diaPago,
    int? saldoInicial,
    int? numeroCuotas,
  }) {
    if (entidad.trim().isEmpty) {
      throw const DeudasException('Escribe el nombre de la entidad (banco, etc.).');
    }
    if (cuotaMensual <= 0) {
      throw const DeudasException('La cuota mensual debe ser mayor a \$0.');
    }
    if (diaPago < 1 || diaPago > 31) {
      throw const DeudasException('El día de pago debe estar entre 1 y 31.');
    }
    if (saldoInicial != null && saldoInicial <= 0) {
      throw const DeudasException('El saldo inicial debe ser mayor a \$0.');
    }
    if (numeroCuotas != null && numeroCuotas <= 0) {
      throw const DeudasException('El número de cuotas debe ser mayor a 0.');
    }
  }

  @override
  Stream<List<Deuda>> observarDeudas({required String hogarId}) {
    return _deudas(hogarId).snapshots().map((snap) {
      final lista = snap.docs.map(Deuda.fromFirestore).toList();
      lista.sort((a, b) => a.entidad.toLowerCase().compareTo(b.entidad.toLowerCase()));
      return lista;
    });
  }

  @override
  Future<String> crearDeuda({
    required String hogarId,
    required String entidad,
    required int saldoInicial,
    required int cuotaMensual,
    required int diaPago,
    int? numeroCuotas,
  }) async {
    await _exigirInternet();
    _validarCampos(
      entidad: entidad,
      cuotaMensual: cuotaMensual,
      diaPago: diaPago,
      saldoInicial: saldoInicial,
      numeroCuotas: numeroCuotas,
    );

    final docRef = _deudas(hogarId).doc();
    await docRef.set(<String, dynamic>{
      'entidad': entidad.trim(),
      'saldoInicial': saldoInicial,
      'saldoActual': saldoInicial,
      'cuotaMensual': cuotaMensual,
      'diaPago': diaPago,
      'numeroCuotas': numeroCuotas,
      'estado': 'activa',
      'creadaEn': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  @override
  Future<void> actualizarDeuda({
    required String hogarId,
    required Deuda deuda,
    required String entidad,
    required int cuotaMensual,
    required int diaPago,
    int? numeroCuotas,
  }) async {
    await _exigirInternet();
    if (deuda.estado != 'activa') {
      throw const DeudasException('Solo puedes editar deudas activas.');
    }
    _validarCampos(
      entidad: entidad,
      cuotaMensual: cuotaMensual,
      diaPago: diaPago,
      numeroCuotas: numeroCuotas,
    );

    // No tocar saldoActual ni saldoInicial (docs/04_seguridad_y_functions.md).
    await _deudas(hogarId).doc(deuda.id).update(<String, dynamic>{
      'entidad': entidad.trim(),
      'cuotaMensual': cuotaMensual,
      'diaPago': diaPago,
      'numeroCuotas': numeroCuotas,
    });
  }

  @override
  Future<void> desactivarDeuda({
    required String hogarId,
    required String deudaId,
  }) async {
    await _exigirInternet();
    await _deudas(hogarId).doc(deudaId).update(<String, dynamic>{
      'estado': 'desactivada',
    });
  }
}

final deudasRepositoryProvider = Provider<DeudasRepository>((ref) {
  return FirebaseDeudasRepository(
    conectividad: ref.watch(conectividadServiceProvider),
  );
});

final deudasHogarProvider = StreamProvider<List<Deuda>>((ref) {
  final hogarId = ref.watch(usuarioActualProvider).value?.hogarId;
  if (hogarId == null || hogarId.isEmpty) {
    return Stream.value(const <Deuda>[]);
  }
  return ref.watch(deudasRepositoryProvider).observarDeudas(hogarId: hogarId);
});

final deudasActivasProvider = Provider<List<Deuda>>((ref) {
  final todas = ref.watch(deudasHogarProvider).value ?? const <Deuda>[];
  return todas.where((d) => d.estado == 'activa').toList();
});
