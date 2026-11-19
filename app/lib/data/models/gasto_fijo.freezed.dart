// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gasto_fijo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GastoFijo {

 String get id; String get uid; String get nombre; int get monto; String get categoria; int get diaEsperado; bool get activo;
/// Create a copy of GastoFijo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GastoFijoCopyWith<GastoFijo> get copyWith => _$GastoFijoCopyWithImpl<GastoFijo>(this as GastoFijo, _$identity);

  /// Serializes this GastoFijo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GastoFijo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GastoFijo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.monto, _this.monto) || other.monto == _this.monto)&&(identical(other.categoria, _this.categoria) || other.categoria == _this.categoria)&&(identical(other.diaEsperado, _this.diaEsperado) || other.diaEsperado == _this.diaEsperado)&&(identical(other.activo, _this.activo) || other.activo == _this.activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GastoFijo;
  return Object.hash(runtimeType,_this.id,_this.uid,_this.nombre,_this.monto,_this.categoria,_this.diaEsperado,_this.activo);
}

@override
String toString() {
  final _this = this as GastoFijo;
  return 'GastoFijo(id: ${_this.id}, uid: ${_this.uid}, nombre: ${_this.nombre}, monto: ${_this.monto}, categoria: ${_this.categoria}, diaEsperado: ${_this.diaEsperado}, activo: ${_this.activo})';
}


}

/// @nodoc
abstract mixin class $GastoFijoCopyWith<$Res>  {
  factory $GastoFijoCopyWith(GastoFijo value, $Res Function(GastoFijo) _then) = _$GastoFijoCopyWithImpl;
@useResult
$Res call({
 String id, String uid, String nombre, int monto, String categoria, int diaEsperado, bool activo
});




}
/// @nodoc
class _$GastoFijoCopyWithImpl<$Res>
    implements $GastoFijoCopyWith<$Res> {
  _$GastoFijoCopyWithImpl(this._self, this._then);

  final GastoFijo _self;
  final $Res Function(GastoFijo) _then;

/// Create a copy of GastoFijo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uid = null,Object? nombre = null,Object? monto = null,Object? categoria = null,Object? diaEsperado = null,Object? activo = null,}) {
  return _then(GastoFijo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as int,categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String,diaEsperado: null == diaEsperado ? _self.diaEsperado : diaEsperado // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GastoFijo].
extension GastoFijoPatterns on GastoFijo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GastoFijo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GastoFijo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GastoFijo value)  $default,){
final _that = this;
switch (_that) {
case _GastoFijo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GastoFijo value)?  $default,){
final _that = this;
switch (_that) {
case _GastoFijo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String uid,  String nombre,  int monto,  String categoria,  int diaEsperado,  bool activo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GastoFijo() when $default != null:
return $default(_that.id,_that.uid,_that.nombre,_that.monto,_that.categoria,_that.diaEsperado,_that.activo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String uid,  String nombre,  int monto,  String categoria,  int diaEsperado,  bool activo)  $default,) {final _that = this;
switch (_that) {
case _GastoFijo():
return $default(_that.id,_that.uid,_that.nombre,_that.monto,_that.categoria,_that.diaEsperado,_that.activo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String uid,  String nombre,  int monto,  String categoria,  int diaEsperado,  bool activo)?  $default,) {final _that = this;
switch (_that) {
case _GastoFijo() when $default != null:
return $default(_that.id,_that.uid,_that.nombre,_that.monto,_that.categoria,_that.diaEsperado,_that.activo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GastoFijo implements GastoFijo {
  const _GastoFijo({required this.id, required this.uid, required this.nombre, required this.monto, required this.categoria, required this.diaEsperado, this.activo = true});
  factory _GastoFijo.fromJson(Map<String, dynamic> json) => _$GastoFijoFromJson(json);

@override final  String id;
@override final  String uid;
@override final  String nombre;
@override final  int monto;
@override final  String categoria;
@override final  int diaEsperado;
@override@JsonKey() final  bool activo;

/// Create a copy of GastoFijo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GastoFijoCopyWith<_GastoFijo> get copyWith => __$GastoFijoCopyWithImpl<_GastoFijo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GastoFijoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GastoFijo&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.diaEsperado, diaEsperado) || other.diaEsperado == diaEsperado)&&(identical(other.activo, activo) || other.activo == activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,uid,nombre,monto,categoria,diaEsperado,activo);
}

@override
String toString() {
    return 'GastoFijo(id: $id, uid: $uid, nombre: $nombre, monto: $monto, categoria: $categoria, diaEsperado: $diaEsperado, activo: $activo)';
}


}

/// @nodoc
abstract mixin class _$GastoFijoCopyWith<$Res> implements $GastoFijoCopyWith<$Res> {
  factory _$GastoFijoCopyWith(_GastoFijo value, $Res Function(_GastoFijo) _then) = __$GastoFijoCopyWithImpl;
@override @useResult
$Res call({
 String id, String uid, String nombre, int monto, String categoria, int diaEsperado, bool activo
});




}
/// @nodoc
class __$GastoFijoCopyWithImpl<$Res>
    implements _$GastoFijoCopyWith<$Res> {
  __$GastoFijoCopyWithImpl(this._self, this._then);

  final _GastoFijo _self;
  final $Res Function(_GastoFijo) _then;

/// Create a copy of GastoFijo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uid = null,Object? nombre = null,Object? monto = null,Object? categoria = null,Object? diaEsperado = null,Object? activo = null,}) {
  return _then(_GastoFijo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as int,categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String,diaEsperado: null == diaEsperado ? _self.diaEsperado : diaEsperado // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
