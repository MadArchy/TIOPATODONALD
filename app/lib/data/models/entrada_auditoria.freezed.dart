// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entrada_auditoria.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EntradaAuditoria {

 String get id; String? get movimientoId; String get accion; Map<String, dynamic> get antes; Map<String, dynamic> get despues; String get porUid; String? get aprobadoPor;@TimestampConverter() DateTime get fecha;
/// Create a copy of EntradaAuditoria
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntradaAuditoriaCopyWith<EntradaAuditoria> get copyWith => _$EntradaAuditoriaCopyWithImpl<EntradaAuditoria>(this as EntradaAuditoria, _$identity);

  /// Serializes this EntradaAuditoria to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EntradaAuditoria;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntradaAuditoria&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.movimientoId, _this.movimientoId) || other.movimientoId == _this.movimientoId)&&(identical(other.accion, _this.accion) || other.accion == _this.accion)&&const DeepCollectionEquality().equals(other.antes, _this.antes)&&const DeepCollectionEquality().equals(other.despues, _this.despues)&&(identical(other.porUid, _this.porUid) || other.porUid == _this.porUid)&&(identical(other.aprobadoPor, _this.aprobadoPor) || other.aprobadoPor == _this.aprobadoPor)&&(identical(other.fecha, _this.fecha) || other.fecha == _this.fecha));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EntradaAuditoria;
  return Object.hash(runtimeType,_this.id,_this.movimientoId,_this.accion,const DeepCollectionEquality().hash(_this.antes),const DeepCollectionEquality().hash(_this.despues),_this.porUid,_this.aprobadoPor,_this.fecha);
}

@override
String toString() {
  final _this = this as EntradaAuditoria;
  return 'EntradaAuditoria(id: ${_this.id}, movimientoId: ${_this.movimientoId}, accion: ${_this.accion}, antes: ${_this.antes}, despues: ${_this.despues}, porUid: ${_this.porUid}, aprobadoPor: ${_this.aprobadoPor}, fecha: ${_this.fecha})';
}


}

/// @nodoc
abstract mixin class $EntradaAuditoriaCopyWith<$Res>  {
  factory $EntradaAuditoriaCopyWith(EntradaAuditoria value, $Res Function(EntradaAuditoria) _then) = _$EntradaAuditoriaCopyWithImpl;
@useResult
$Res call({
 String id, String? movimientoId, String accion, Map<String, dynamic> antes, Map<String, dynamic> despues, String porUid, String? aprobadoPor,@TimestampConverter() DateTime fecha
});




}
/// @nodoc
class _$EntradaAuditoriaCopyWithImpl<$Res>
    implements $EntradaAuditoriaCopyWith<$Res> {
  _$EntradaAuditoriaCopyWithImpl(this._self, this._then);

  final EntradaAuditoria _self;
  final $Res Function(EntradaAuditoria) _then;

/// Create a copy of EntradaAuditoria
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? movimientoId = freezed,Object? accion = null,Object? antes = null,Object? despues = null,Object? porUid = null,Object? aprobadoPor = freezed,Object? fecha = null,}) {
  return _then(EntradaAuditoria(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,movimientoId: freezed == movimientoId ? _self.movimientoId : movimientoId // ignore: cast_nullable_to_non_nullable
as String?,accion: null == accion ? _self.accion : accion // ignore: cast_nullable_to_non_nullable
as String,antes: null == antes ? _self.antes : antes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,despues: null == despues ? _self.despues : despues // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,porUid: null == porUid ? _self.porUid : porUid // ignore: cast_nullable_to_non_nullable
as String,aprobadoPor: freezed == aprobadoPor ? _self.aprobadoPor : aprobadoPor // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EntradaAuditoria].
extension EntradaAuditoriaPatterns on EntradaAuditoria {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntradaAuditoria value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntradaAuditoria() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntradaAuditoria value)  $default,){
final _that = this;
switch (_that) {
case _EntradaAuditoria():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntradaAuditoria value)?  $default,){
final _that = this;
switch (_that) {
case _EntradaAuditoria() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? movimientoId,  String accion,  Map<String, dynamic> antes,  Map<String, dynamic> despues,  String porUid,  String? aprobadoPor, @TimestampConverter()  DateTime fecha)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntradaAuditoria() when $default != null:
return $default(_that.id,_that.movimientoId,_that.accion,_that.antes,_that.despues,_that.porUid,_that.aprobadoPor,_that.fecha);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? movimientoId,  String accion,  Map<String, dynamic> antes,  Map<String, dynamic> despues,  String porUid,  String? aprobadoPor, @TimestampConverter()  DateTime fecha)  $default,) {final _that = this;
switch (_that) {
case _EntradaAuditoria():
return $default(_that.id,_that.movimientoId,_that.accion,_that.antes,_that.despues,_that.porUid,_that.aprobadoPor,_that.fecha);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? movimientoId,  String accion,  Map<String, dynamic> antes,  Map<String, dynamic> despues,  String porUid,  String? aprobadoPor, @TimestampConverter()  DateTime fecha)?  $default,) {final _that = this;
switch (_that) {
case _EntradaAuditoria() when $default != null:
return $default(_that.id,_that.movimientoId,_that.accion,_that.antes,_that.despues,_that.porUid,_that.aprobadoPor,_that.fecha);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntradaAuditoria implements EntradaAuditoria {
  const _EntradaAuditoria({required this.id, this.movimientoId, required this.accion,  Map<String, dynamic> antes = const <String, dynamic>{},  Map<String, dynamic> despues = const <String, dynamic>{}, required this.porUid, this.aprobadoPor, @TimestampConverter() required this.fecha}): _antes = antes,_despues = despues;
  factory _EntradaAuditoria.fromJson(Map<String, dynamic> json) => _$EntradaAuditoriaFromJson(json);

@override final  String id;
@override final  String? movimientoId;
@override final  String accion;
 final  Map<String, dynamic> _antes;
@override@JsonKey() Map<String, dynamic> get antes {
  if (_antes is EqualUnmodifiableMapView) return _antes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_antes);
}

 final  Map<String, dynamic> _despues;
@override@JsonKey() Map<String, dynamic> get despues {
  if (_despues is EqualUnmodifiableMapView) return _despues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_despues);
}

@override final  String porUid;
@override final  String? aprobadoPor;
@override@TimestampConverter() final  DateTime fecha;

/// Create a copy of EntradaAuditoria
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntradaAuditoriaCopyWith<_EntradaAuditoria> get copyWith => __$EntradaAuditoriaCopyWithImpl<_EntradaAuditoria>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntradaAuditoriaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntradaAuditoria&&(identical(other.id, id) || other.id == id)&&(identical(other.movimientoId, movimientoId) || other.movimientoId == movimientoId)&&(identical(other.accion, accion) || other.accion == accion)&&const DeepCollectionEquality().equals(other.antes, _antes)&&const DeepCollectionEquality().equals(other.despues, _despues)&&(identical(other.porUid, porUid) || other.porUid == porUid)&&(identical(other.aprobadoPor, aprobadoPor) || other.aprobadoPor == aprobadoPor)&&(identical(other.fecha, fecha) || other.fecha == fecha));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,movimientoId,accion,const DeepCollectionEquality().hash(_antes),const DeepCollectionEquality().hash(_despues),porUid,aprobadoPor,fecha);
}

@override
String toString() {
    return 'EntradaAuditoria(id: $id, movimientoId: $movimientoId, accion: $accion, antes: $antes, despues: $despues, porUid: $porUid, aprobadoPor: $aprobadoPor, fecha: $fecha)';
}


}

/// @nodoc
abstract mixin class _$EntradaAuditoriaCopyWith<$Res> implements $EntradaAuditoriaCopyWith<$Res> {
  factory _$EntradaAuditoriaCopyWith(_EntradaAuditoria value, $Res Function(_EntradaAuditoria) _then) = __$EntradaAuditoriaCopyWithImpl;
@override @useResult
$Res call({
 String id, String? movimientoId, String accion, Map<String, dynamic> antes, Map<String, dynamic> despues, String porUid, String? aprobadoPor,@TimestampConverter() DateTime fecha
});




}
/// @nodoc
class __$EntradaAuditoriaCopyWithImpl<$Res>
    implements _$EntradaAuditoriaCopyWith<$Res> {
  __$EntradaAuditoriaCopyWithImpl(this._self, this._then);

  final _EntradaAuditoria _self;
  final $Res Function(_EntradaAuditoria) _then;

/// Create a copy of EntradaAuditoria
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? movimientoId = freezed,Object? accion = null,Object? antes = null,Object? despues = null,Object? porUid = null,Object? aprobadoPor = freezed,Object? fecha = null,}) {
  return _then(_EntradaAuditoria(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,movimientoId: freezed == movimientoId ? _self.movimientoId : movimientoId // ignore: cast_nullable_to_non_nullable
as String?,accion: null == accion ? _self.accion : accion // ignore: cast_nullable_to_non_nullable
as String,antes: null == antes ? _self._antes : antes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,despues: null == despues ? _self._despues : despues // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,porUid: null == porUid ? _self.porUid : porUid // ignore: cast_nullable_to_non_nullable
as String,aprobadoPor: freezed == aprobadoPor ? _self.aprobadoPor : aprobadoPor // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
