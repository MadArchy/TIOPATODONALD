import 'package:cloud_firestore/cloud_firestore.dart';

import 'usuario.dart';

/// Modelo de `hogares/{h}/resumenes/{uid}_{periodoId}` (`docs/03_modelo_datos.md`).
class ResumenPeriodo {
  const ResumenPeriodo({
    required this.id,
    required this.uid,
    required this.periodoId,
    required this.gastado,
    required this.ingresos,
    required this.presupuesto,
    required this.semaforo,
    required this.porCategoria,
    required this.porcentajeReducible,
    required this.variacionVsAnterior,
    required this.creadoEn,
  });

  final String id;
  final String uid;
  final String periodoId;
  final int gastado;
  final int ingresos;
  final int presupuesto;
  final String semaforo; // 'verde' | 'rojo'
  final Map<String, int> porCategoria;
  final double porcentajeReducible;
  final Map<String, dynamic> variacionVsAnterior;
  final DateTime creadoEn;

  factory ResumenPeriodo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final porCatRaw = data['porCategoria'];
    final porCat = <String, int>{};
    if (porCatRaw is Map) {
      for (final e in porCatRaw.entries) {
        final v = e.value;
        if (v is int) {
          porCat[e.key.toString()] = v;
        } else if (v is num) {
          porCat[e.key.toString()] = v.toInt();
        }
      }
    }

    final varRaw = data['variacionVsAnterior'];
    final variacion = varRaw is Map
        ? Map<String, dynamic>.from(varRaw)
        : <String, dynamic>{};

    final creado = const TimestampConverter().fromJson(data['creadoEn']);

    // uid y periodoId suelen ir en el id: uid_YYYY-MM-DD
    final id = doc.id;
    String uid = (data['uid'] ?? '').toString();
    String periodoId = (data['periodoId'] ?? '').toString();
    if (uid.isEmpty || periodoId.isEmpty) {
      final idx = id.lastIndexOf('_');
      if (idx > 0 && idx + 1 < id.length) {
        uid = uid.isEmpty ? id.substring(0, idx) : uid;
        periodoId = periodoId.isEmpty ? id.substring(idx + 1) : periodoId;
      }
    }

    final reducibleRaw = data['porcentajeReducible'];
    final reducible = reducibleRaw is num ? reducibleRaw.toDouble() : 0.0;

    return ResumenPeriodo(
      id: id,
      uid: uid,
      periodoId: periodoId,
      gastado: (data['gastado'] as num?)?.toInt() ?? 0,
      ingresos: (data['ingresos'] as num?)?.toInt() ?? 0,
      presupuesto: (data['presupuesto'] as num?)?.toInt() ?? 0,
      semaforo: (data['semaforo'] ?? 'verde').toString(),
      porCategoria: porCat,
      porcentajeReducible: reducible,
      variacionVsAnterior: variacion,
      creadoEn: creado,
    );
  }
}
