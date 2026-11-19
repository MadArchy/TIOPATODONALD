// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'miembro_hogar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MiembroHogar {

 String get uid; String get nombre; String get rol; String get estado;@TimestampConverter() DateTime get unidoEn;@NullableTimestampConverter() DateTime? get retiradoEn;
/// Create a copy of MiembroHogar
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MiembroHogarCopyWith<MiembroHogar> get copyWith => _$MiembroHogarCopyWithImpl<MiembroHogar>(this as MiembroHogar, _$identity);

  /// Serializes this MiembroHogar to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MiembroHogar;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiembroHogar&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.rol, _this.rol) || other.rol == _this.rol)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.unidoEn, _this.unidoEn) || other.unidoEn == _this.unidoEn)&&(identical(other.retiradoEn, _this.retiradoEn) || other.retiradoEn == _this.retiradoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MiembroHogar;
  return Object.hash(runtimeType,_this.uid,_this.nombre,_this.rol,_this.estado,_this.unidoEn,_this.retiradoEn);
}

@override
String toString() {
  final _this = this as MiembroHogar;
  return 'MiembroHogar(uid: ${_this.uid}, nombre: ${_this.nombre}, rol: ${_this.rol}, estado: ${_this.estado}, unidoEn: ${_this.unidoEn}, retiradoEn: ${_this.retiradoEn})';
}


}

/// @nodoc
abstract mixin class $MiembroHogarCopyWith<$Res>  {
  factory $MiembroHogarCopyWith(MiembroHogar value, $Res Function(MiembroHogar) _then) = _$MiembroHogarCopyWithImpl;
@useResult
$Res call({
 String uid, String nombre, String rol, String estado,@TimestampConverter() DateTime unidoEn,@NullableTimestampConverter() DateTime? retiradoEn
});




}
/// @nodoc
class _$MiembroHogarCopyWithImpl<$Res>
    implements $MiembroHogarCopyWith<$Res> {
  _$MiembroHogarCopyWithImpl(this._self, this._then);

  final MiembroHogar _self;
  final $Res Function(MiembroHogar) _then;

/// Create a copy of MiembroHogar
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? nombre = null,Object? rol = null,Object? estado = null,Object? unidoEn = null,Object? retiradoEn = freezed,}) {
  return _then(MiembroHogar(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,unidoEn: null == unidoEn ? _self.unidoEn : unidoEn // ignore: cast_nullable_to_non_nullable
as DateTime,retiradoEn: freezed == retiradoEn ? _self.retiradoEn : retiradoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MiembroHogar].
extension MiembroHogarPatterns on MiembroHogar {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MiembroHogar value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MiembroHogar() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MiembroHogar value)  $default,){
final _that = this;
switch (_that) {
case _MiembroHogar():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MiembroHogar value)?  $default,){
final _that = this;
switch (_that) {
case _MiembroHogar() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String nombre,  String rol,  String estado, @TimestampConverter()  DateTime unidoEn, @NullableTimestampConverter()  DateTime? retiradoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MiembroHogar() when $default != null:
return $default(_that.uid,_that.nombre,_that.rol,_that.estado,_that.unidoEn,_that.retiradoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String nombre,  String rol,  String estado, @TimestampConverter()  DateTime unidoEn, @NullableTimestampConverter()  DateTime? retiradoEn)  $default,) {final _that = this;
switch (_that) {
case _MiembroHogar():
return $default(_that.uid,_that.nombre,_that.rol,_that.estado,_that.unidoEn,_that.retiradoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String nombre,  String rol,  String estado, @TimestampConverter()  DateTime unidoEn, @NullableTimestampConverter()  DateTime? retiradoEn)?  $default,) {final _that = this;
switch (_that) {
case _MiembroHogar() when $default != null:
return $default(_that.uid,_that.nombre,_that.rol,_that.estado,_that.unidoEn,_that.retiradoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MiembroHogar implements MiembroHogar {
  const _MiembroHogar({required this.uid, required this.nombre, this.rol = 'miembro', this.estado = 'activo', @TimestampConverter() required this.unidoEn, @NullableTimestampConverter() this.retiradoEn});
  factory _MiembroHogar.fromJson(Map<String, dynamic> json) => _$MiembroHogarFromJson(json);

@override final  String uid;
@override final  String nombre;
@override@JsonKey() final  String rol;
@override@JsonKey() final  String estado;
@override@TimestampConverter() final  DateTime unidoEn;
@override@NullableTimestampConverter() final  DateTime? retiradoEn;

/// Create a copy of MiembroHogar
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MiembroHogarCopyWith<_MiembroHogar> get copyWith => __$MiembroHogarCopyWithImpl<_MiembroHogar>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MiembroHogarToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MiembroHogar&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.rol, rol) || other.rol == rol)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.unidoEn, unidoEn) || other.unidoEn == unidoEn)&&(identical(other.retiradoEn, retiradoEn) || other.retiradoEn == retiradoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uid,nombre,rol,estado,unidoEn,retiradoEn);
}

@override
String toString() {
    return 'MiembroHogar(uid: $uid, nombre: $nombre, rol: $rol, estado: $estado, unidoEn: $unidoEn, retiradoEn: $retiradoEn)';
}


}

/// @nodoc
abstract mixin class _$MiembroHogarCopyWith<$Res> implements $MiembroHogarCopyWith<$Res> {
  factory _$MiembroHogarCopyWith(_MiembroHogar value, $Res Function(_MiembroHogar) _then) = __$MiembroHogarCopyWithImpl;
@override @useResult
$Res call({
 String uid, String nombre, String rol, String estado,@TimestampConverter() DateTime unidoEn,@NullableTimestampConverter() DateTime? retiradoEn
});




}
/// @nodoc
class __$MiembroHogarCopyWithImpl<$Res>
    implements _$MiembroHogarCopyWith<$Res> {
  __$MiembroHogarCopyWithImpl(this._self, this._then);

  final _MiembroHogar _self;
  final $Res Function(_MiembroHogar) _then;

/// Create a copy of MiembroHogar
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? nombre = null,Object? rol = null,Object? estado = null,Object? unidoEn = null,Object? retiradoEn = freezed,}) {
  return _then(_MiembroHogar(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,unidoEn: null == unidoEn ? _self.unidoEn : unidoEn // ignore: cast_nullable_to_non_nullable
as DateTime,retiradoEn: freezed == retiradoEn ? _self.retiradoEn : retiradoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
