import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'usuario.dart';

part 'presupuesto.freezed.dart';
part 'presupuesto.g.dart';

/// Modelo inmutable de `hogares/{h}/presupuestos/{uid}_{periodoId}` (`docs/03_modelo_datos.md`).
@freezed
abstract class Presupuesto with _$Presupuesto {
  const factory Presupuesto({
    required String id,
    required String uid,
    required String periodoId,
    required int monto,
    @Default(<int>[]) List<int> alertasEnviadas,
    @TimestampConverter() required DateTime actualizadoEn,
  }) = _Presupuesto;

  factory Presupuesto.fromJson(Map<String, dynamic> json) =>
      _$PresupuestoFromJson(json);

  factory Presupuesto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return Presupuesto.fromJson(<String, dynamic>{
      ...data,
      'id': doc.id,
    });
  }
}
