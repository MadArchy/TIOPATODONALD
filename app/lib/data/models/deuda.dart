import 'package:cloud_firestore/cloud_firestore.dart';

import 'usuario.dart';

/// Modelo de `hogares/{h}/deudas/{id}` (`docs/03_modelo_datos.md`).
class Deuda {
  const Deuda({
    required this.id,
    required this.entidad,
    required this.saldoInicial,
    required this.saldoActual,
    required this.cuotaMensual,
    required this.diaPago,
    this.numeroCuotas,
    this.estado = 'activa',
    required this.creadaEn,
  });

  final String id;
  final String entidad;
  final int saldoInicial;
  final int saldoActual;
  final int cuotaMensual;
  final int diaPago;
  final int? numeroCuotas;
  final String estado; // activa | pagada | desactivada
  final DateTime creadaEn;

  factory Deuda.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final creada = const TimestampConverter().fromJson(data['creadaEn']);
    final numCuotas = data['numeroCuotas'];
    return Deuda(
      id: doc.id,
      entidad: (data['entidad'] ?? '').toString(),
      saldoInicial: (data['saldoInicial'] as num?)?.toInt() ?? 0,
      saldoActual: (data['saldoActual'] as num?)?.toInt() ?? 0,
      cuotaMensual: (data['cuotaMensual'] as num?)?.toInt() ?? 0,
      diaPago: (data['diaPago'] as num?)?.toInt() ?? 1,
      numeroCuotas: numCuotas == null ? null : (numCuotas as num).toInt(),
      estado: (data['estado'] ?? 'activa').toString(),
      creadaEn: creada,
    );
  }
}
