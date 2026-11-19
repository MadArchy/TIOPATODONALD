import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'usuario.dart';

part 'deuda_interna.freezed.dart';
part 'deuda_interna.g.dart';

/// Modelo de `hogares/{h}/deudasInternas/{id}` (`docs/03_modelo_datos.md`).
@freezed
abstract class DeudaInterna with _$DeudaInterna {
  const factory DeudaInterna({
    required String id,
    required String acreedorUid,
    required String deudorUid,
    required int montoInicial,
    required int saldo,
    required String concepto,
    @Default('pendiente') String estado,
    @TimestampConverter() required DateTime creadaEn,
  }) = _DeudaInterna;

  factory DeudaInterna.fromJson(Map<String, dynamic> json) =>
      _$DeudaInternaFromJson(json);

  factory DeudaInterna.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return DeudaInterna.fromJson(<String, dynamic>{
      ...data,
      'id': doc.id,
      'estado': data['estado'] ?? 'pendiente',
    });
  }
}
