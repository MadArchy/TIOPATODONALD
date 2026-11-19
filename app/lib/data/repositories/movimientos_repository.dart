import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/categorias.dart';
import '../../core/movimientos_validacion.dart';
import '../../core/periodo.dart';
import '../../core/utils/clock.dart';
import '../models/gasto_fijo.dart';
import '../models/movimiento.dart';
import '../services/cola_fotos_service.dart';
import 'auth_repository.dart';

class MovimientosException implements Exception {
  const MovimientosException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato del repositorio de movimientos y gastos fijos (Slice 3).
abstract class MovimientosRepository {
  Stream<List<Movimiento>> observarMovimientosPeriodo({
    required String hogarId,
    required String periodoId,
    String? soloUid,
    String? categoria,
  });

  Stream<Movimiento?> observarMovimiento({
    required String hogarId,
    required String movimientoId,
  });

  Stream<List<GastoFijo>> observarGastosFijos({
    required String hogarId,
    required String uid,
  });

  Future<String> crearMovimiento({
    required String hogarId,
    required String uid,
    required int diaInicioPeriodo,
    required String tipo,
    required int monto,
    required String? categoria,
    required DateTime fecha,
    required DateTime ahora,
    String nota,
    String origen,
    String? gastoFijoId,
    String? deudaId,
    File? fotoLocal,
  });

  Future<void> edicionMenor({
    required String hogarId,
    required Movimiento movimiento,
    required String uidActual,
    required int diaInicioPeriodo,
    required DateTime ahora,
    String? nota,
    String? categoria,
  });

  Future<String> crearGastoFijo({
    required String hogarId,
    required String uid,
    required String nombre,
    required int monto,
    required String categoria,
    required int diaEsperado,
  });

  Future<void> actualizarGastoFijo({
    required String hogarId,
    required GastoFijo gasto,
    required String nombre,
    required int monto,
    required String categoria,
    required int diaEsperado,
    required bool activo,
  });

  Future<void> eliminarGastoFijo({
    required String hogarId,
    required String gastoFijoId,
  });

  /// Sube fotos en cola y escribe `fotoPath` en Firestore.
  Future<void> sincronizarFotosPendientes(String hogarId);
}

class FirebaseMovimientosRepository implements MovimientosRepository {
  FirebaseMovimientosRepository({
    FirebaseFirestore? firestore,
    required this.colaFotos,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final ColaFotosService colaFotos;

  CollectionReference<Map<String, dynamic>> _movimientos(String hogarId) {
    return _firestore.collection('hogares').doc(hogarId).collection('movimientos');
  }

  CollectionReference<Map<String, dynamic>> _gastosFijos(String hogarId) {
    return _firestore.collection('hogares').doc(hogarId).collection('gastosFijos');
  }

  @override
  Stream<List<Movimiento>> observarMovimientosPeriodo({
    required String hogarId,
    required String periodoId,
    String? soloUid,
    String? categoria,
  }) {
    Query<Map<String, dynamic>> q = _movimientos(hogarId)
        .where('periodoId', isEqualTo: periodoId)
        .orderBy('fecha', descending: true);

    if (soloUid != null && soloUid.isNotEmpty) {
      q = _movimientos(hogarId)
          .where('uid', isEqualTo: soloUid)
          .where('periodoId', isEqualTo: periodoId)
          .orderBy('fecha', descending: true);
    }

    return q.snapshots().map((snap) {
      var lista = snap.docs.map(Movimiento.fromFirestore).toList();
      if (categoria != null && categoria.isNotEmpty) {
        lista = lista.where((m) => m.categoria == categoria).toList();
      }
      return lista;
    });
  }

  @override
  Stream<Movimiento?> observarMovimiento({
    required String hogarId,
    required String movimientoId,
  }) {
    return _movimientos(hogarId).doc(movimientoId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Movimiento.fromFirestore(snap);
    });
  }

  @override
  Stream<List<GastoFijo>> observarGastosFijos({
    required String hogarId,
    required String uid,
  }) {
    return _gastosFijos(hogarId)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final lista = snap.docs.map(GastoFijo.fromFirestore).toList();
      lista.sort((a, b) => a.diaEsperado.compareTo(b.diaEsperado));
      return lista;
    });
  }

  Future<File?> _comprimirFoto(File original) async {
    final dir = await getTemporaryDirectory();
    final dest = p.join(
      dir.path,
      'recibo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final result = await FlutterImageCompress.compressAndGetFile(
      original.absolute.path,
      dest,
      quality: 70,
      minWidth: 1280,
      minHeight: 1280,
    );
    if (result == null) return null;
    return File(result.path);
  }

  @override
  Future<String> crearMovimiento({
    required String hogarId,
    required String uid,
    required int diaInicioPeriodo,
    required String tipo,
    required int monto,
    required String? categoria,
    required DateTime fecha,
    required DateTime ahora,
    String nota = '',
    String origen = 'formulario',
    String? gastoFijoId,
    String? deudaId,
    File? fotoLocal,
  }) async {
    final periodo = periodoDe(fecha, diaInicioPeriodo);
    final validacion = validarCreacionMovimiento(
      tipo: tipo,
      monto: monto,
      categoria: categoria,
      fecha: fecha,
      ahora: ahora,
      diaInicioPeriodo: diaInicioPeriodo,
      periodoId: periodo.periodoId,
      deudaId: deudaId,
      nota: nota,
    );
    if (!validacion.esValido) {
      throw MovimientosException(validacion.mensaje!);
    }

    final docRef = _movimientos(hogarId).doc();
    final data = <String, dynamic>{
      'tipo': tipo,
      'monto': monto,
      'categoria': categoria,
      'deudaId': deudaId,
      'gastoFijoId': gastoFijoId,
      'fecha': Timestamp.fromDate(fecha),
      'periodoId': periodo.periodoId,
      'uid': uid,
      'nota': nota.trim(),
      'fotoPath': null,
      'origen': origen,
      'estado': 'activo',
      'creadoEn': FieldValue.serverTimestamp(),
      'editadoEn': null,
      'saldoAplicado': false,
    };

    await docRef.set(data);

    if (fotoLocal != null) {
      final comprimida = await _comprimirFoto(fotoLocal) ?? fotoLocal;
      final storagePath = await colaFotos.subirOEncolar(
        hogarId: hogarId,
        movimientoId: docRef.id,
        archivoComprimido: comprimida,
      );
      if (storagePath != null) {
        await docRef.update(<String, dynamic>{'fotoPath': storagePath});
      }
    }

    return docRef.id;
  }

  @override
  Future<void> edicionMenor({
    required String hogarId,
    required Movimiento movimiento,
    required String uidActual,
    required int diaInicioPeriodo,
    required DateTime ahora,
    String? nota,
    String? categoria,
  }) async {
    if (movimiento.estado != 'activo') {
      throw const MovimientosException(
        'Este movimiento ya no se puede editar.',
      );
    }
    if (!puedeEdicionMenor(
      autorUid: movimiento.uid,
      uidActual: uidActual,
      creadoEn: movimiento.creadoEn,
      ahora: ahora,
      diaInicioPeriodo: diaInicioPeriodo,
      periodoIdMovimiento: movimiento.periodoId,
    )) {
      throw const MovimientosException(
        'Solo puedes cambiar la nota o la categoría dentro de las primeras 24 horas.',
      );
    }

    final updates = <String, dynamic>{
      'editadoEn': FieldValue.serverTimestamp(),
    };

    if (nota != null) {
      final limpia = nota.trim();
      if (limpia.length > 200) {
        throw const MovimientosException(
          'La nota puede tener máximo 200 caracteres.',
        );
      }
      updates['nota'] = limpia;
    }

    if (categoria != null) {
      if (movimiento.tipo != 'gasto') {
        throw const MovimientosException(
          'Solo puedes cambiar la categoría de un gasto.',
        );
      }
      if (!CategoriasGasto.esValida(categoria)) {
        throw const MovimientosException('Categoría de gasto no válida.');
      }
      updates['categoria'] = categoria;
    }

    await _movimientos(hogarId).doc(movimiento.id).update(updates);
  }

  @override
  Future<String> crearGastoFijo({
    required String hogarId,
    required String uid,
    required String nombre,
    required int monto,
    required String categoria,
    required int diaEsperado,
  }) async {
    final nombreLimpio = nombre.trim();
    if (nombreLimpio.isEmpty) {
      throw const MovimientosException('Escribe un nombre para el gasto fijo.');
    }
    if (monto <= 0) {
      throw const MovimientosException('Escribe un monto mayor a \$0.');
    }
    if (!CategoriasGasto.esValida(categoria)) {
      throw const MovimientosException('Elige una categoría de gasto.');
    }
    if (diaEsperado < 1 || diaEsperado > 31) {
      throw const MovimientosException('El día esperado debe estar entre 1 y 31.');
    }

    final docRef = _gastosFijos(hogarId).doc();
    await docRef.set(<String, dynamic>{
      'uid': uid,
      'nombre': nombreLimpio,
      'monto': monto,
      'categoria': categoria,
      'diaEsperado': diaEsperado,
      'activo': true,
    });
    return docRef.id;
  }

  @override
  Future<void> actualizarGastoFijo({
    required String hogarId,
    required GastoFijo gasto,
    required String nombre,
    required int monto,
    required String categoria,
    required int diaEsperado,
    required bool activo,
  }) async {
    final nombreLimpio = nombre.trim();
    if (nombreLimpio.isEmpty) {
      throw const MovimientosException('Escribe un nombre para el gasto fijo.');
    }
    if (monto <= 0) {
      throw const MovimientosException('Escribe un monto mayor a \$0.');
    }
    if (!CategoriasGasto.esValida(categoria)) {
      throw const MovimientosException('Elige una categoría de gasto.');
    }
    if (diaEsperado < 1 || diaEsperado > 31) {
      throw const MovimientosException('El día esperado debe estar entre 1 y 31.');
    }

    await _gastosFijos(hogarId).doc(gasto.id).update(<String, dynamic>{
      'nombre': nombreLimpio,
      'monto': monto,
      'categoria': categoria,
      'diaEsperado': diaEsperado,
      'activo': activo,
      'uid': gasto.uid,
    });
  }

  @override
  Future<void> eliminarGastoFijo({
    required String hogarId,
    required String gastoFijoId,
  }) async {
    await _gastosFijos(hogarId).doc(gastoFijoId).delete();
  }

  @override
  Future<void> sincronizarFotosPendientes(String hogarId) async {
    final subidas = await colaFotos.procesarPendientes();
    for (final item in subidas) {
      if (item.hogarId != hogarId) continue;
      try {
        await _movimientos(hogarId).doc(item.movimientoId).update(
          <String, dynamic>{'fotoPath': item.storagePath},
        );
      } catch (_) {
        // El movimiento puede no existir aún offline; se reintentará.
      }
    }
  }
}

final movimientosRepositoryProvider = Provider<MovimientosRepository>((ref) {
  final cola = ref.watch(colaFotosServiceProvider);
  return FirebaseMovimientosRepository(colaFotos: cola);
});

final movimientosPeriodoProvider =
    StreamProvider.family<List<Movimiento>, ({String periodoId, String? uid, String? categoria})>(
  (ref, args) {
    final usuario = ref.watch(usuarioActualProvider).value;
    final hogarId = usuario?.hogarId;
    if (hogarId == null || hogarId.isEmpty) {
      return Stream<List<Movimiento>>.value(const <Movimiento>[]);
    }
    return ref.watch(movimientosRepositoryProvider).observarMovimientosPeriodo(
          hogarId: hogarId,
          periodoId: args.periodoId,
          soloUid: args.uid,
          categoria: args.categoria,
        );
  },
);

final movimientoPorIdProvider =
    StreamProvider.family<Movimiento?, String>((ref, movimientoId) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final hogarId = usuario?.hogarId;
  if (hogarId == null || hogarId.isEmpty || movimientoId.isEmpty) {
    return Stream<Movimiento?>.value(null);
  }
  return ref.watch(movimientosRepositoryProvider).observarMovimiento(
        hogarId: hogarId,
        movimientoId: movimientoId,
      );
});

final gastosFijosPropiosProvider = StreamProvider<List<GastoFijo>>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final hogarId = usuario?.hogarId;
  if (usuario == null || hogarId == null || hogarId.isEmpty) {
    return Stream<List<GastoFijo>>.value(const <GastoFijo>[]);
  }
  return ref.watch(movimientosRepositoryProvider).observarGastosFijos(
        hogarId: hogarId,
        uid: usuario.uid,
      );
});

/// Gastos fijos del usuario que tocan hoy y aún no tienen movimiento en el período.
final gastosFijosPendientesHoyProvider = Provider<List<GastoFijo>>((ref) {
  final usuario = ref.watch(usuarioActualProvider).value;
  final gastos = ref.watch(gastosFijosPropiosProvider).value ?? const <GastoFijo>[];
  if (usuario == null) return const <GastoFijo>[];

  final ahora = ref.watch(clockProvider).now();
  final periodo = periodoDe(ahora, usuario.diaInicioPeriodo);
  final movimientos = ref
          .watch(
            movimientosPeriodoProvider((
              periodoId: periodo.periodoId,
              uid: usuario.uid,
              categoria: null,
            )),
          )
          .value ??
      const <Movimiento>[];

  final yaRegistrados = movimientos
      .where((m) => m.gastoFijoId != null && m.estado == 'activo')
      .map((m) => m.gastoFijoId!)
      .toSet();

  return gastos.where((g) {
    if (!g.activo) return false;
    if (!esDiaEsperadoGastoFijo(ahora: ahora, diaEsperado: g.diaEsperado)) {
      return false;
    }
    return !yaRegistrados.contains(g.id);
  }).toList();
});
