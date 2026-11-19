import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'usuario.dart';

part 'hogar.freezed.dart';
part 'hogar.g.dart';

/// Puerta de IA en `hogares/{hogarId}.ia` (`docs/03_modelo_datos.md` y `docs/05_ia.md`).
@freezed
abstract class ConfiguracionIaHogar with _$ConfiguracionIaHogar {
  const factory ConfiguracionIaHogar({
    @Default(false) bool activa,
    @Default('') String proveedor,
    @Default('') String modelo,
    @Default(0) int limiteMensual,
  }) = _ConfiguracionIaHogar;

  factory ConfiguracionIaHogar.fromJson(Map<String, dynamic> json) =>
      _$ConfiguracionIaHogarFromJson(json);
}

/// Modelo inmutable de `hogares/{hogarId}` (`docs/03_modelo_datos.md`).
@freezed
abstract class Hogar with _$Hogar {
  const factory Hogar({
    required String id,
    required String nombre,
    required String adminUid,
    @Default(ConfiguracionIaHogar()) ConfiguracionIaHogar ia,
    @TimestampConverter() required DateTime creadoEn,
  }) = _Hogar;

  factory Hogar.fromJson(Map<String, dynamic> json) => _$HogarFromJson(json);

  factory Hogar.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return Hogar.fromJson(<String, dynamic>{
      ...data,
      'id': doc.id,
    });
  }
}
