import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'usuario.dart';

part 'entrada_auditoria.freezed.dart';
part 'entrada_auditoria.g.dart';

/// Modelo de `hogares/{h}/auditoria/{id}` (`docs/03_modelo_datos.md`).
@freezed
abstract class EntradaAuditoria with _$EntradaAuditoria {
  const factory EntradaAuditoria({
    required String id,
    String? movimientoId,
    required String accion,
    @Default(<String, dynamic>{}) Map<String, dynamic> antes,
    @Default(<String, dynamic>{}) Map<String, dynamic> despues,
    required String porUid,
    String? aprobadoPor,
    @TimestampConverter() required DateTime fecha,
  }) = _EntradaAuditoria;

  factory EntradaAuditoria.fromJson(Map<String, dynamic> json) =>
      _$EntradaAuditoriaFromJson(json);

  factory EntradaAuditoria.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    Map<String, dynamic> mapa(Object? raw) {
      if (raw is Map) return Map<String, dynamic>.from(raw);
      return <String, dynamic>{};
    }

    return EntradaAuditoria.fromJson(<String, dynamic>{
      ...data,
      'id': doc.id,
      'antes': mapa(data['antes']),
      'despues': mapa(data['despues']),
      'accion': data['accion'] ?? 'correccion',
      'porUid': data['porUid'] ?? '',
    });
  }
}
