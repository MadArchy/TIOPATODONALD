import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/firebase_init.dart';
import '../../core/indicadores.dart' show periodoAnteriorDe;
import '../../core/periodo.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/conectividad.dart';
import '../models/hogar.dart';
import '../models/invitacion_hogar.dart';
import '../models/miembro_hogar.dart';
import '../models/presupuesto.dart';
import '../models/resumen_periodo.dart';
import 'auth_repository.dart';

class HogarException implements Exception {
  const HogarException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato del repositorio de Hogar, Invitaciones por QR y Presupuesto inicial.
abstract class HogarRepository {
  Stream<Hogar?> observarHogar(String hogarId);
  Stream<List<MiembroHogar>> observarMiembrosActivos(String hogarId);
  Stream<InvitacionHogar?> observarInvitacionActiva(String hogarId);
  Stream<Presupuesto?> observarPresupuesto({
    required String hogarId,
    required String uid,
    required String periodoId,
  });

  Future<String> crearHogar({required String nombre});
  Future<InvitacionHogar> generarInvitacion({required String hogarId});
  Future<String> unirseConCodigo({
    required String hogarId,
    required String codigo,
  });
  Future<void> sacarMiembro({
    required String hogarId,
    required String miembroUid,
  });

  /// Guarda `usuarios/{uid}.diaInicioPeriodo` y `hogares/{h}/presupuestos/{uid}_{periodoId}`.
  Future<void> guardarPresupuestoYPeriodoInicial({
    required String uid,
    required String hogarId,
    required int montoPresupuesto,
    required int diaInicioPeriodo,
    required DateTime ahora,
  });

  /// Cambia el monto del presupuesto vigente vía Function (auditoría `cambioPresupuesto`).
  Future<void> cambiarPresupuesto({
    required String hogarId,
    required int monto,
  });

  /// Programa un nuevo día de inicio (`diaInicioPendiente`) o lo cancela (`null`).
  Future<void> guardarDiaInicioPendiente({
    required String uid,
    required int? diaInicioPendiente,
  });

  /// Marca umbrales de alerta ya mostrados en el presupuesto del período.
  Future<void> marcarAlertasEnviadas({
    required String hogarId,
    required String presupuestoId,
    required List<int> alertasEnviadas,
  });

  Stream<ResumenPeriodo?> observarResumen({
    required String hogarId,
    required String uid,
    required String periodoId,
  });

  Stream<List<Presupuesto>> observarPresupuestosHogar(String hogarId);
}

class FirebaseHogarRepository implements HogarRepository {
  FirebaseHogarRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    required this.conectividad,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ??
            FirebaseFunctions.instanceFor(region: kFirebaseRegion);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final ConectividadService conectividad;

  Future<void> _exigirInternet() async {
    final hayRed = await conectividad.tieneInternet();
    if (!hayRed) {
      throw const HogarException(kMensajeNecesitasInternet);
    }
  }

  HogarException _mapearError(Object error) {
    if (error is HogarException) {
      return error;
    }
    if (error is FirebaseFunctionsException) {
      if (error.code == 'unavailable' || error.code == 'deadline-exceeded') {
        return const HogarException(kMensajeNecesitasInternet);
      }
      final msg = (error.message ?? '').trim();
      if (msg.isNotEmpty) {
        return HogarException(msg);
      }
    }
    return const HogarException(
      'No pudimos completar la acción. Revisa tu conexión e intenta de nuevo.',
    );
  }

  @override
  Stream<Hogar?> observarHogar(String hogarId) {
    return _firestore.collection('hogares').doc(hogarId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Hogar.fromFirestore(snap);
    });
  }

  @override
  Stream<List<MiembroHogar>> observarMiembrosActivos(String hogarId) {
    return _firestore
        .collection('hogares')
        .doc(hogarId)
        .collection('miembros')
        .where('estado', isEqualTo: 'activo')
        .snapshots()
        .map((snap) {
      final lista = snap.docs.map(MiembroHogar.fromFirestore).toList();
      lista.sort((a, b) {
        if (a.rol == 'admin' && b.rol != 'admin') return -1;
        if (a.rol != 'admin' && b.rol == 'admin') return 1;
        return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      });
      return lista;
    });
  }

  @override
  Stream<InvitacionHogar?> observarInvitacionActiva(String hogarId) {
    return _firestore
        .collection('hogares')
        .doc(hogarId)
        .collection('invitaciones')
        .where('activa', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return InvitacionHogar.fromFirestore(
        snap.docs.first,
        hogarId: hogarId,
      );
    });
  }

  @override
  Stream<Presupuesto?> observarPresupuesto({
    required String hogarId,
    required String uid,
    required String periodoId,
  }) {
    final docId = '${uid}_$periodoId';
    return _firestore
        .collection('hogares')
        .doc(hogarId)
        .collection('presupuestos')
        .doc(docId)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return Presupuesto.fromFirestore(snap);
    });
  }

  @override
  Future<String> crearHogar({required String nombre}) async {
    final nombreLimpio = nombre.trim();
    if (nombreLimpio.length < 2) {
      throw const HogarException(
        'Escribe un nombre para el hogar (mínimo 2 letras).',
      );
    }

    await _exigirInternet();

    try {
      final callable = _functions.httpsCallable('crearHogar');
      final res = await callable.call<Map<Object?, Object?>>(<String, dynamic>{
        'nombre': nombreLimpio,
      });
      final data = res.data;
      return (data['hogarId'] ?? '').toString();
    } catch (e) {
      throw _mapearError(e);
    }
  }

  @override
  Future<InvitacionHogar> generarInvitacion({required String hogarId}) async {
    await _exigirInternet();

    try {
      final callable = _functions.httpsCallable('generarInvitacion');
      final res = await callable.call<Map<Object?, Object?>>(<String, dynamic>{
        'hogarId': hogarId,
      });
      final data = res.data;
      final expiraIso = (data['expiraEnIso'] ?? '').toString();
      final expiraEn = DateTime.tryParse(expiraIso) ??
          DateTime.now().add(const Duration(hours: 4));

      return InvitacionHogar(
        id: (data['invitacionId'] ?? '').toString(),
        hogarId: hogarId,
        codigo: (data['codigo'] ?? '').toString(),
        creadaPor: '',
        creadaEn: DateTime.now(),
        expiraEn: expiraEn,
        activa: true,
      );
    } catch (e) {
      throw _mapearError(e);
    }
  }

  @override
  Future<String> unirseConCodigo({
    required String hogarId,
    required String codigo,
  }) async {
    await _exigirInternet();

    try {
      final callable = _functions.httpsCallable('unirseConCodigo');
      final res = await callable.call<Map<Object?, Object?>>(<String, dynamic>{
        'hogarId': hogarId.trim(),
        'codigo': codigo.trim(),
      });
      final data = res.data;
      return (data['hogarId'] ?? hogarId).toString();
    } catch (e) {
      throw _mapearError(e);
    }
  }

  @override
  Future<void> sacarMiembro({
    required String hogarId,
    required String miembroUid,
  }) async {
    await _exigirInternet();

    try {
      final callable = _functions.httpsCallable('sacarMiembro');
      await callable.call<Map<Object?, Object?>>(<String, dynamic>{
        'hogarId': hogarId,
        'miembroUid': miembroUid,
      });
    } catch (e) {
      throw _mapearError(e);
    }
  }

  @override
  Future<void> guardarPresupuestoYPeriodoInicial({
    required String uid,
    required String hogarId,
    required int montoPresupuesto,
    required int diaInicioPeriodo,
    required DateTime ahora,
  }) async {
    if (montoPresupuesto <= 0) {
      throw const HogarException('Escribe un presupuesto mayor a \$0.');
    }
    if (diaInicioPeriodo < 1 || diaInicioPeriodo > 28) {
      throw const HogarException('Elige un día de inicio entre 1 y 28.');
    }

    final periodo = periodoDe(ahora, diaInicioPeriodo);
    final presupuestoId = '${uid}_${periodo.periodoId}';

    final batch = _firestore.batch();
    final usuarioRef = _firestore.collection('usuarios').doc(uid);
    final presupuestoRef = _firestore
        .collection('hogares')
        .doc(hogarId)
        .collection('presupuestos')
        .doc(presupuestoId);

    batch.update(usuarioRef, <String, dynamic>{
      'diaInicioPeriodo': diaInicioPeriodo,
    });

    batch.set(
      presupuestoRef,
      <String, dynamic>{
        'uid': uid,
        'periodoId': periodo.periodoId,
        'monto': montoPresupuesto,
        'alertasEnviadas': <int>[],
        'actualizadoEn': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  @override
  Future<void> cambiarPresupuesto({
    required String hogarId,
    required int monto,
  }) async {
    if (monto <= 0) {
      throw const HogarException('Escribe un presupuesto mayor a \$0.');
    }
    await _exigirInternet();
    try {
      final callable = _functions.httpsCallable('cambiarPresupuesto');
      await callable.call<Map<Object?, Object?>>(<String, dynamic>{
        'hogarId': hogarId,
        'monto': monto,
      });
    } catch (e) {
      throw _mapearError(e);
    }
  }

  @override
  Future<void> guardarDiaInicioPendiente({
    required String uid,
    required int? diaInicioPendiente,
  }) async {
    if (diaInicioPendiente != null &&
        (diaInicioPendiente < 1 || diaInicioPendiente > 28)) {
      throw const HogarException('Elige un día de inicio entre 1 y 28.');
    }
    await _firestore.collection('usuarios').doc(uid).update(<String, dynamic>{
      'diaInicioPendiente': diaInicioPendiente,
    });
  }

  @override
  Future<void> marcarAlertasEnviadas({
    required String hogarId,
    required String presupuestoId,
    required List<int> alertasEnviadas,
  }) async {
    await _firestore
        .collection('hogares')
        .doc(hogarId)
        .collection('presupuestos')
        .doc(presupuestoId)
        .update(<String, dynamic>{
      'alertasEnviadas': alertasEnviadas,
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<ResumenPeriodo?> observarResumen({
    required String hogarId,
    required String uid,
    required String periodoId,
  }) {
    final docId = '${uid}_$periodoId';
    return _firestore
        .collection('hogares')
        .doc(hogarId)
        .collection('resumenes')
        .doc(docId)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return ResumenPeriodo.fromFirestore(snap);
    });
  }

  @override
  Stream<List<Presupuesto>> observarPresupuestosHogar(String hogarId) {
    return _firestore
        .collection('hogares')
        .doc(hogarId)
        .collection('presupuestos')
        .snapshots()
        .map((snap) => snap.docs.map(Presupuesto.fromFirestore).toList());
  }
}

final hogarRepositoryProvider = Provider<HogarRepository>((ref) {
  final conectividad = ref.watch(conectividadServiceProvider);
  return FirebaseHogarRepository(conectividad: conectividad);
});

final hogarActualProvider = StreamProvider<Hogar?>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final hogarId = usuario?.hogarId;
  if (hogarId == null || hogarId.isEmpty) {
    return Stream<Hogar?>.value(null);
  }
  return ref.watch(hogarRepositoryProvider).observarHogar(hogarId);
});

final miembrosHogarProvider = StreamProvider<List<MiembroHogar>>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final hogarId = usuario?.hogarId;
  if (hogarId == null || hogarId.isEmpty) {
    return Stream<List<MiembroHogar>>.value(const <MiembroHogar>[]);
  }
  return ref.watch(hogarRepositoryProvider).observarMiembrosActivos(hogarId);
});

final invitacionActivaProvider = StreamProvider<InvitacionHogar?>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final hogar = ref.watch(hogarActualProvider).value;
  final hogarId = usuario?.hogarId;
  if (hogarId == null ||
      hogarId.isEmpty ||
      usuario == null ||
      hogar?.adminUid != usuario.uid) {
    return Stream<InvitacionHogar?>.value(null);
  }
  return ref.watch(hogarRepositoryProvider).observarInvitacionActiva(hogarId);
});

final presupuestoVigenteProvider = StreamProvider<Presupuesto?>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final hogarId = usuario?.hogarId;
  if (usuario == null || hogarId == null || hogarId.isEmpty) {
    return Stream<Presupuesto?>.value(null);
  }
  final ahora = ref.watch(clockProvider).now();
  final periodo = periodoDe(ahora, usuario.diaInicioPeriodo);
  return ref.watch(hogarRepositoryProvider).observarPresupuesto(
        hogarId: hogarId,
        uid: usuario.uid,
        periodoId: periodo.periodoId,
      );
});

final presupuestosHogarProvider = StreamProvider<List<Presupuesto>>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final hogarId = usuario?.hogarId;
  if (hogarId == null || hogarId.isEmpty) {
    return Stream<List<Presupuesto>>.value(const <Presupuesto>[]);
  }
  return ref.watch(hogarRepositoryProvider).observarPresupuestosHogar(hogarId);
});

/// Resumen del período anterior (para la tarjeta de cierre el día 1).
final resumenPeriodoAnteriorProvider = StreamProvider<ResumenPeriodo?>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final hogarId = usuario?.hogarId;
  if (usuario == null || hogarId == null || hogarId.isEmpty) {
    return Stream<ResumenPeriodo?>.value(null);
  }
  final ahora = ref.watch(clockProvider).now();
  final actual = periodoDe(ahora, usuario.diaInicioPeriodo);
  if (diasTranscurridos(actual, ahora) != 1) {
    return Stream<ResumenPeriodo?>.value(null);
  }
  final anterior = periodoAnteriorDe(actual);
  return ref.watch(hogarRepositoryProvider).observarResumen(
        hogarId: hogarId,
        uid: usuario.uid,
        periodoId: anterior.periodoId,
      );
});
