import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gasto_fijo.freezed.dart';
part 'gasto_fijo.g.dart';

/// Modelo de `hogares/{h}/gastosFijos/{id}` (`docs/03_modelo_datos.md`).
@freezed
abstract class GastoFijo with _$GastoFijo {
  const factory GastoFijo({
    required String id,
    required String uid,
    required String nombre,
    required int monto,
    required String categoria,
    required int diaEsperado,
    @Default(true) bool activo,
  }) = _GastoFijo;

  factory GastoFijo.fromJson(Map<String, dynamic> json) =>
      _$GastoFijoFromJson(json);

  factory GastoFijo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return GastoFijo.fromJson(<String, dynamic>{
      ...data,
      'id': doc.id,
      'activo': data['activo'] ?? true,
    });
  }
}
