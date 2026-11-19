import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'usuario.dart';

part 'invitacion_hogar.freezed.dart';
part 'invitacion_hogar.g.dart';

/// Modelo inmutable de `hogares/{h}/invitaciones/{id}` (`docs/03_modelo_datos.md`).
@freezed
abstract class InvitacionHogar with _$InvitacionHogar {
  const factory InvitacionHogar({
    required String id,
    required String hogarId,
    required String codigo,
    required String creadaPor,
    @TimestampConverter() required DateTime creadaEn,
    @TimestampConverter() required DateTime expiraEn,
    @Default(true) bool activa,
  }) = _InvitacionHogar;

  factory InvitacionHogar.fromJson(Map<String, dynamic> json) =>
      _$InvitacionHogarFromJson(json);

  factory InvitacionHogar.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String hogarId,
  }) {
    final data = doc.data() ?? <String, dynamic>{};
    return InvitacionHogar.fromJson(<String, dynamic>{
      ...data,
      'id': doc.id,
      'hogarId': hogarId,
    });
  }
}

extension InvitacionHogarX on InvitacionHogar {
  String get qrUrl =>
      'patodonald://unirse?h=${Uri.encodeQueryComponent(hogarId)}&c=${Uri.encodeQueryComponent(codigo)}';

  bool estaVigente(DateTime ahora) => activa && ahora.isBefore(expiraEn);

  Duration tiempoRestante(DateTime ahora) {
    if (!estaVigente(ahora)) {
      return Duration.zero;
    }
    return expiraEn.difference(ahora);
  }
}
