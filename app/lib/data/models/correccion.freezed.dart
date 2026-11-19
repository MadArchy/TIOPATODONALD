// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'correccion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Correccion {

 String get id; String get movimientoId; String get solicitanteUid; String get motivo; Map<String, dynamic> get cambios; String get estado; String? get resueltaPor;@NullableTimestampConverter() DateTime? get resueltaEn; String? get motivoRechazo;@TimestampConverter() DateTime get creadoEn;
/// Create a copy of Correccion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorreccionCopyWith<Correccion> get copyWith => _$CorreccionCopyWithImpl<Correccion>(this as Correccion, _$identity);

  /// Serializes this Correccion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Correccion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Correccion&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.movimientoId, _this.movimientoId) || other.movimientoId == _this.movimientoId)&&(identical(other.solicitanteUid, _this.solicitanteUid) || other.solicitanteUid == _this.solicitanteUid)&&(identical(other.motivo, _this.motivo) || other.motivo == _this.motivo)&&const DeepCollectionEquality().equals(other.cambios, _this.cambios)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.resueltaPor, _this.resueltaPor) || other.resueltaPor == _this.resueltaPor)&&(identical(other.resueltaEn, _this.resueltaEn) || other.resueltaEn == _this.resueltaEn)&&(identical(other.motivoRechazo, _this.motivoRechazo) || other.motivoRechazo == _this.motivoRechazo)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Correccion;
  return Object.hash(runtimeType,_this.id,_this.movimientoId,_this.solicitanteUid,_this.motivo,const DeepCollectionEquality().hash(_this.cambios),_this.estado,_this.resueltaPor,_this.resueltaEn,_this.motivoRechazo,_this.creadoEn);
}

@override
String toString() {
  final _this = this as Correccion;
  return 'Correccion(id: ${_this.id}, movimientoId: ${_this.movimientoId}, solicitanteUid: ${_this.solicitanteUid}, motivo: ${_this.motivo}, cambios: ${_this.cambios}, estado: ${_this.estado}, resueltaPor: ${_this.resueltaPor}, resueltaEn: ${_this.resueltaEn}, motivoRechazo: ${_this.motivoRechazo}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $CorreccionCopyWith<$Res>  {
  factory $CorreccionCopyWith(Correccion value, $Res Function(Correccion) _then) = _$CorreccionCopyWithImpl;
@useResult
$Res call({
 String id, String movimientoId, String solicitanteUid, String motivo, Map<String, dynamic> cambios, String estado, String? resueltaPor,@NullableTimestampConverter() DateTime? resueltaEn, String? motivoRechazo,@TimestampConverter() DateTime creadoEn
});




}
/// @nodoc
class _$CorreccionCopyWithImpl<$Res>
    implements $CorreccionCopyWith<$Res> {
  _$CorreccionCopyWithImpl(this._self, this._then);

  final Correccion _self;
  final $Res Function(Correccion) _then;

/// Create a copy of Correccion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? movimientoId = null,Object? solicitanteUid = null,Object? motivo = null,Object? cambios = null,Object? estado = null,Object? resueltaPor = freezed,Object? resueltaEn = freezed,Object? motivoRechazo = freezed,Object? creadoEn = null,}) {
  return _then(Correccion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,movimientoId: null == movimientoId ? _self.movimientoId : movimientoId // ignore: cast_nullable_to_non_nullable
as String,solicitanteUid: null == solicitanteUid ? _self.solicitanteUid : solicitanteUid // ignore: cast_nullable_to_non_nullable
as String,motivo: null == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as String,cambios: null == cambios ? _self.cambios : cambios // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,resueltaPor: freezed == resueltaPor ? _self.resueltaPor : resueltaPor // ignore: cast_nullable_to_non_nullable
as String?,resueltaEn: freezed == resueltaEn ? _self.resueltaEn : resueltaEn // ignore: cast_nullable_to_non_nullable
as DateTime?,motivoRechazo: freezed == motivoRechazo ? _self.motivoRechazo : motivoRechazo // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Correccion].
extension CorreccionPatterns on Correccion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Correccion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Correccion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Correccion value)  $default,){
final _that = this;
switch (_that) {
case _Correccion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Correccion value)?  $default,){
final _that = this;
switch (_that) {
case _Correccion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String movimientoId,  String solicitanteUid,  String motivo,  Map<String, dynamic> cambios,  String estado,  String? resueltaPor, @NullableTimestampConverter()  DateTime? resueltaEn,  String? motivoRechazo, @TimestampConverter()  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Correccion() when $default != null:
return $default(_that.id,_that.movimientoId,_that.solicitanteUid,_that.motivo,_that.cambios,_that.estado,_that.resueltaPor,_that.resueltaEn,_that.motivoRechazo,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String movimientoId,  String solicitanteUid,  String motivo,  Map<String, dynamic> cambios,  String estado,  String? resueltaPor, @NullableTimestampConverter()  DateTime? resueltaEn,  String? motivoRechazo, @TimestampConverter()  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _Correccion():
return $default(_that.id,_that.movimientoId,_that.solicitanteUid,_that.motivo,_that.cambios,_that.estado,_that.resueltaPor,_that.resueltaEn,_that.motivoRechazo,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String movimientoId,  String solicitanteUid,  String motivo,  Map<String, dynamic> cambios,  String estado,  String? resueltaPor, @NullableTimestampConverter()  DateTime? resueltaEn,  String? motivoRechazo, @TimestampConverter()  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _Correccion() when $default != null:
return $default(_that.id,_that.movimientoId,_that.solicitanteUid,_that.motivo,_that.cambios,_that.estado,_that.resueltaPor,_that.resueltaEn,_that.motivoRechazo,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Correccion implements Correccion {
  const _Correccion({required this.id, required this.movimientoId, required this.solicitanteUid, required this.motivo,  Map<String, dynamic> cambios = const <String, dynamic>{}, this.estado = 'pendiente', this.resueltaPor, @NullableTimestampConverter() this.resueltaEn, this.motivoRechazo, @TimestampConverter() required this.creadoEn}): _cambios = cambios;
  factory _Correccion.fromJson(Map<String, dynamic> json) => _$CorreccionFromJson(json);

@override final  String id;
@override final  String movimientoId;
@override final  String solicitanteUid;
@override final  String motivo;
 final  Map<String, dynamic> _cambios;
@override@JsonKey() Map<String, dynamic> get cambios {
  if (_cambios is EqualUnmodifiableMapView) return _cambios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_cambios);
}

@override@JsonKey() final  String estado;
@override final  String? resueltaPor;
@override@NullableTimestampConverter() final  DateTime? resueltaEn;
@override final  String? motivoRechazo;
@override@TimestampConverter() final  DateTime creadoEn;

/// Create a copy of Correccion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorreccionCopyWith<_Correccion> get copyWith => __$CorreccionCopyWithImpl<_Correccion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CorreccionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Correccion&&(identical(other.id, id) || other.id == id)&&(identical(other.movimientoId, movimientoId) || other.movimientoId == movimientoId)&&(identical(other.solicitanteUid, solicitanteUid) || other.solicitanteUid == solicitanteUid)&&(identical(other.motivo, motivo) || other.motivo == motivo)&&const DeepCollectionEquality().equals(other.cambios, _cambios)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.resueltaPor, resueltaPor) || other.resueltaPor == resueltaPor)&&(identical(other.resueltaEn, resueltaEn) || other.resueltaEn == resueltaEn)&&(identical(other.motivoRechazo, motivoRechazo) || other.motivoRechazo == motivoRechazo)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,movimientoId,solicitanteUid,motivo,const DeepCollectionEquality().hash(_cambios),estado,resueltaPor,resueltaEn,motivoRechazo,creadoEn);
}

@override
String toString() {
    return 'Correccion(id: $id, movimientoId: $movimientoId, solicitanteUid: $solicitanteUid, motivo: $motivo, cambios: $cambios, estado: $estado, resueltaPor: $resueltaPor, resueltaEn: $resueltaEn, motivoRechazo: $motivoRechazo, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$CorreccionCopyWith<$Res> implements $CorreccionCopyWith<$Res> {
  factory _$CorreccionCopyWith(_Correccion value, $Res Function(_Correccion) _then) = __$CorreccionCopyWithImpl;
@override @useResult
$Res call({
 String id, String movimientoId, String solicitanteUid, String motivo, Map<String, dynamic> cambios, String estado, String? resueltaPor,@NullableTimestampConverter() DateTime? resueltaEn, String? motivoRechazo,@TimestampConverter() DateTime creadoEn
});




}
/// @nodoc
class __$CorreccionCopyWithImpl<$Res>
    implements _$CorreccionCopyWith<$Res> {
  __$CorreccionCopyWithImpl(this._self, this._then);

  final _Correccion _self;
  final $Res Function(_Correccion) _then;

/// Create a copy of Correccion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? movimientoId = null,Object? solicitanteUid = null,Object? motivo = null,Object? cambios = null,Object? estado = null,Object? resueltaPor = freezed,Object? resueltaEn = freezed,Object? motivoRechazo = freezed,Object? creadoEn = null,}) {
  return _then(_Correccion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,movimientoId: null == movimientoId ? _self.movimientoId : movimientoId // ignore: cast_nullable_to_non_nullable
as String,solicitanteUid: null == solicitanteUid ? _self.solicitanteUid : solicitanteUid // ignore: cast_nullable_to_non_nullable
as String,motivo: null == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as String,cambios: null == cambios ? _self._cambios : cambios // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,resueltaPor: freezed == resueltaPor ? _self.resueltaPor : resueltaPor // ignore: cast_nullable_to_non_nullable
as String?,resueltaEn: freezed == resueltaEn ? _self.resueltaEn : resueltaEn // ignore: cast_nullable_to_non_nullable
as DateTime?,motivoRechazo: freezed == motivoRechazo ? _self.motivoRechazo : motivoRechazo // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
