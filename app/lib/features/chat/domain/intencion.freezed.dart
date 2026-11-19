// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'intencion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Intencion {

 String get accion; String? get tipo; int? get monto; String? get categoria;/// Fecha propuesta `YYYY-MM-DD` (America/Bogota calendario).
 String? get fecha; String? get nota; String? get deudaId; String? get movimientoId; Map<String, dynamic>? get cambios; String? get motivo; String? get textoOriginal; double get confianza;
/// Create a copy of Intencion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntencionCopyWith<Intencion> get copyWith => _$IntencionCopyWithImpl<Intencion>(this as Intencion, _$identity);

  /// Serializes this Intencion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Intencion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Intencion&&(identical(other.accion, _this.accion) || other.accion == _this.accion)&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.monto, _this.monto) || other.monto == _this.monto)&&(identical(other.categoria, _this.categoria) || other.categoria == _this.categoria)&&(identical(other.fecha, _this.fecha) || other.fecha == _this.fecha)&&(identical(other.nota, _this.nota) || other.nota == _this.nota)&&(identical(other.deudaId, _this.deudaId) || other.deudaId == _this.deudaId)&&(identical(other.movimientoId, _this.movimientoId) || other.movimientoId == _this.movimientoId)&&const DeepCollectionEquality().equals(other.cambios, _this.cambios)&&(identical(other.motivo, _this.motivo) || other.motivo == _this.motivo)&&(identical(other.textoOriginal, _this.textoOriginal) || other.textoOriginal == _this.textoOriginal)&&(identical(other.confianza, _this.confianza) || other.confianza == _this.confianza));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Intencion;
  return Object.hash(runtimeType,_this.accion,_this.tipo,_this.monto,_this.categoria,_this.fecha,_this.nota,_this.deudaId,_this.movimientoId,const DeepCollectionEquality().hash(_this.cambios),_this.motivo,_this.textoOriginal,_this.confianza);
}

@override
String toString() {
  final _this = this as Intencion;
  return 'Intencion(accion: ${_this.accion}, tipo: ${_this.tipo}, monto: ${_this.monto}, categoria: ${_this.categoria}, fecha: ${_this.fecha}, nota: ${_this.nota}, deudaId: ${_this.deudaId}, movimientoId: ${_this.movimientoId}, cambios: ${_this.cambios}, motivo: ${_this.motivo}, textoOriginal: ${_this.textoOriginal}, confianza: ${_this.confianza})';
}


}

/// @nodoc
abstract mixin class $IntencionCopyWith<$Res>  {
  factory $IntencionCopyWith(Intencion value, $Res Function(Intencion) _then) = _$IntencionCopyWithImpl;
@useResult
$Res call({
 String accion, String? tipo, int? monto, String? categoria, String? fecha, String? nota, String? deudaId, String? movimientoId, Map<String, dynamic>? cambios, String? motivo, String? textoOriginal, double confianza
});




}
/// @nodoc
class _$IntencionCopyWithImpl<$Res>
    implements $IntencionCopyWith<$Res> {
  _$IntencionCopyWithImpl(this._self, this._then);

  final Intencion _self;
  final $Res Function(Intencion) _then;

/// Create a copy of Intencion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accion = null,Object? tipo = freezed,Object? monto = freezed,Object? categoria = freezed,Object? fecha = freezed,Object? nota = freezed,Object? deudaId = freezed,Object? movimientoId = freezed,Object? cambios = freezed,Object? motivo = freezed,Object? textoOriginal = freezed,Object? confianza = null,}) {
  return _then(Intencion(
accion: null == accion ? _self.accion : accion // ignore: cast_nullable_to_non_nullable
as String,tipo: freezed == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String?,monto: freezed == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as int?,categoria: freezed == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String?,fecha: freezed == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,deudaId: freezed == deudaId ? _self.deudaId : deudaId // ignore: cast_nullable_to_non_nullable
as String?,movimientoId: freezed == movimientoId ? _self.movimientoId : movimientoId // ignore: cast_nullable_to_non_nullable
as String?,cambios: freezed == cambios ? _self.cambios : cambios // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,motivo: freezed == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as String?,textoOriginal: freezed == textoOriginal ? _self.textoOriginal : textoOriginal // ignore: cast_nullable_to_non_nullable
as String?,confianza: null == confianza ? _self.confianza : confianza // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Intencion].
extension IntencionPatterns on Intencion {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Intencion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Intencion() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Intencion value)  $default,){
final _that = this;
switch (_that) {
case _Intencion():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Intencion value)?  $default,){
final _that = this;
switch (_that) {
case _Intencion() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accion,  String? tipo,  int? monto,  String? categoria,  String? fecha,  String? nota,  String? deudaId,  String? movimientoId,  Map<String, dynamic>? cambios,  String? motivo,  String? textoOriginal,  double confianza)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Intencion() when $default != null:
return $default(_that.accion,_that.tipo,_that.monto,_that.categoria,_that.fecha,_that.nota,_that.deudaId,_that.movimientoId,_that.cambios,_that.motivo,_that.textoOriginal,_that.confianza);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accion,  String? tipo,  int? monto,  String? categoria,  String? fecha,  String? nota,  String? deudaId,  String? movimientoId,  Map<String, dynamic>? cambios,  String? motivo,  String? textoOriginal,  double confianza)  $default,) {final _that = this;
switch (_that) {
case _Intencion():
return $default(_that.accion,_that.tipo,_that.monto,_that.categoria,_that.fecha,_that.nota,_that.deudaId,_that.movimientoId,_that.cambios,_that.motivo,_that.textoOriginal,_that.confianza);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accion,  String? tipo,  int? monto,  String? categoria,  String? fecha,  String? nota,  String? deudaId,  String? movimientoId,  Map<String, dynamic>? cambios,  String? motivo,  String? textoOriginal,  double confianza)?  $default,) {final _that = this;
switch (_that) {
case _Intencion() when $default != null:
return $default(_that.accion,_that.tipo,_that.monto,_that.categoria,_that.fecha,_that.nota,_that.deudaId,_that.movimientoId,_that.cambios,_that.motivo,_that.textoOriginal,_that.confianza);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Intencion implements Intencion {
  const _Intencion({required this.accion, this.tipo, this.monto, this.categoria, this.fecha, this.nota, this.deudaId, this.movimientoId,  Map<String, dynamic>? cambios, this.motivo, this.textoOriginal, this.confianza = 0.0}): _cambios = cambios;
  factory _Intencion.fromJson(Map<String, dynamic> json) => _$IntencionFromJson(json);

@override final  String accion;
@override final  String? tipo;
@override final  int? monto;
@override final  String? categoria;
/// Fecha propuesta `YYYY-MM-DD` (America/Bogota calendario).
@override final  String? fecha;
@override final  String? nota;
@override final  String? deudaId;
@override final  String? movimientoId;
 final  Map<String, dynamic>? _cambios;
@override Map<String, dynamic>? get cambios {
  final value = _cambios;
  if (value == null) return null;
  if (_cambios is EqualUnmodifiableMapView) return _cambios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? motivo;
@override final  String? textoOriginal;
@override@JsonKey() final  double confianza;

/// Create a copy of Intencion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IntencionCopyWith<_Intencion> get copyWith => __$IntencionCopyWithImpl<_Intencion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IntencionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Intencion&&(identical(other.accion, accion) || other.accion == accion)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.deudaId, deudaId) || other.deudaId == deudaId)&&(identical(other.movimientoId, movimientoId) || other.movimientoId == movimientoId)&&const DeepCollectionEquality().equals(other.cambios, _cambios)&&(identical(other.motivo, motivo) || other.motivo == motivo)&&(identical(other.textoOriginal, textoOriginal) || other.textoOriginal == textoOriginal)&&(identical(other.confianza, confianza) || other.confianza == confianza));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accion,tipo,monto,categoria,fecha,nota,deudaId,movimientoId,const DeepCollectionEquality().hash(_cambios),motivo,textoOriginal,confianza);
}

@override
String toString() {
    return 'Intencion(accion: $accion, tipo: $tipo, monto: $monto, categoria: $categoria, fecha: $fecha, nota: $nota, deudaId: $deudaId, movimientoId: $movimientoId, cambios: $cambios, motivo: $motivo, textoOriginal: $textoOriginal, confianza: $confianza)';
}


}

/// @nodoc
abstract mixin class _$IntencionCopyWith<$Res> implements $IntencionCopyWith<$Res> {
  factory _$IntencionCopyWith(_Intencion value, $Res Function(_Intencion) _then) = __$IntencionCopyWithImpl;
@override @useResult
$Res call({
 String accion, String? tipo, int? monto, String? categoria, String? fecha, String? nota, String? deudaId, String? movimientoId, Map<String, dynamic>? cambios, String? motivo, String? textoOriginal, double confianza
});




}
/// @nodoc
class __$IntencionCopyWithImpl<$Res>
    implements _$IntencionCopyWith<$Res> {
  __$IntencionCopyWithImpl(this._self, this._then);

  final _Intencion _self;
  final $Res Function(_Intencion) _then;

/// Create a copy of Intencion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accion = null,Object? tipo = freezed,Object? monto = freezed,Object? categoria = freezed,Object? fecha = freezed,Object? nota = freezed,Object? deudaId = freezed,Object? movimientoId = freezed,Object? cambios = freezed,Object? motivo = freezed,Object? textoOriginal = freezed,Object? confianza = null,}) {
  return _then(_Intencion(
accion: null == accion ? _self.accion : accion // ignore: cast_nullable_to_non_nullable
as String,tipo: freezed == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String?,monto: freezed == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as int?,categoria: freezed == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String?,fecha: freezed == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,deudaId: freezed == deudaId ? _self.deudaId : deudaId // ignore: cast_nullable_to_non_nullable
as String?,movimientoId: freezed == movimientoId ? _self.movimientoId : movimientoId // ignore: cast_nullable_to_non_nullable
as String?,cambios: freezed == cambios ? _self._cambios : cambios // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,motivo: freezed == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as String?,textoOriginal: freezed == textoOriginal ? _self.textoOriginal : textoOriginal // ignore: cast_nullable_to_non_nullable
as String?,confianza: null == confianza ? _self.confianza : confianza // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
