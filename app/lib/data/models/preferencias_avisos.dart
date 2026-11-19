import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferencias_avisos.freezed.dart';
part 'preferencias_avisos.g.dart';

/// Preferencias de push por tipo (`usuarios.preferenciasAvisos`).
@freezed
abstract class PreferenciasAvisos with _$PreferenciasAvisos {
  const factory PreferenciasAvisos({
    @Default(true) bool alertasPresupuesto,
    @Default(true) bool recordatorioDiario,
    @Default(true) bool cuotas,
    @Default(true) bool correcciones,
    @Default(true) bool deudasInternas,
  }) = _PreferenciasAvisos;

  factory PreferenciasAvisos.fromJson(Map<String, dynamic> json) =>
      _$PreferenciasAvisosFromJson(json);
}
