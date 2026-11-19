// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'usuario.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Usuario {

 String get uid; String get nombre; String get email; String? get hogarId; int get diaInicioPeriodo; int? get diaInicioPendiente; String? get horaRecordatorio; List<String> get fcmTokens;@TimestampConverter() DateTime get creadoEn;
/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsuarioCopyWith<Usuario> get copyWith => _$UsuarioCopyWithImpl<Usuario>(this as Usuario, _$identity);

  /// Serializes this Usuario to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Usuario;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Usuario&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.hogarId, _this.hogarId) || other.hogarId == _this.hogarId)&&(identical(other.diaInicioPeriodo, _this.diaInicioPeriodo) || other.diaInicioPeriodo == _this.diaInicioPeriodo)&&(identical(other.diaInicioPendiente, _this.diaInicioPendiente) || other.diaInicioPendiente == _this.diaInicioPendiente)&&(identical(other.horaRecordatorio, _this.horaRecordatorio) || other.horaRecordatorio == _this.horaRecordatorio)&&const DeepCollectionEquality().equals(other.fcmTokens, _this.fcmTokens)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Usuario;
  return Object.hash(runtimeType,_this.uid,_this.nombre,_this.email,_this.hogarId,_this.diaInicioPeriodo,_this.diaInicioPendiente,_this.horaRecordatorio,const DeepCollectionEquality().hash(_this.fcmTokens),_this.creadoEn);
}

@override
String toString() {
  final _this = this as Usuario;
  return 'Usuario(uid: ${_this.uid}, nombre: ${_this.nombre}, email: ${_this.email}, hogarId: ${_this.hogarId}, diaInicioPeriodo: ${_this.diaInicioPeriodo}, diaInicioPendiente: ${_this.diaInicioPendiente}, horaRecordatorio: ${_this.horaRecordatorio}, fcmTokens: ${_this.fcmTokens}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $UsuarioCopyWith<$Res>  {
  factory $UsuarioCopyWith(Usuario value, $Res Function(Usuario) _then) = _$UsuarioCopyWithImpl;
@useResult
$Res call({
 String uid, String nombre, String email, String? hogarId, int diaInicioPeriodo, int? diaInicioPendiente, String? horaRecordatorio, List<String> fcmTokens,@TimestampConverter() DateTime creadoEn
});




}
/// @nodoc
class _$UsuarioCopyWithImpl<$Res>
    implements $UsuarioCopyWith<$Res> {
  _$UsuarioCopyWithImpl(this._self, this._then);

  final Usuario _self;
  final $Res Function(Usuario) _then;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? nombre = null,Object? email = null,Object? hogarId = freezed,Object? diaInicioPeriodo = null,Object? diaInicioPendiente = freezed,Object? horaRecordatorio = freezed,Object? fcmTokens = null,Object? creadoEn = null,}) {
  return _then(Usuario(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,hogarId: freezed == hogarId ? _self.hogarId : hogarId // ignore: cast_nullable_to_non_nullable
as String?,diaInicioPeriodo: null == diaInicioPeriodo ? _self.diaInicioPeriodo : diaInicioPeriodo // ignore: cast_nullable_to_non_nullable
as int,diaInicioPendiente: freezed == diaInicioPendiente ? _self.diaInicioPendiente : diaInicioPendiente // ignore: cast_nullable_to_non_nullable
as int?,horaRecordatorio: freezed == horaRecordatorio ? _self.horaRecordatorio : horaRecordatorio // ignore: cast_nullable_to_non_nullable
as String?,fcmTokens: null == fcmTokens ? _self.fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Usuario].
extension UsuarioPatterns on Usuario {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Usuario value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Usuario() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Usuario value)  $default,){
final _that = this;
switch (_that) {
case _Usuario():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Usuario value)?  $default,){
final _that = this;
switch (_that) {
case _Usuario() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String nombre,  String email,  String? hogarId,  int diaInicioPeriodo,  int? diaInicioPendiente,  String? horaRecordatorio,  List<String> fcmTokens, @TimestampConverter()  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Usuario() when $default != null:
return $default(_that.uid,_that.nombre,_that.email,_that.hogarId,_that.diaInicioPeriodo,_that.diaInicioPendiente,_that.horaRecordatorio,_that.fcmTokens,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String nombre,  String email,  String? hogarId,  int diaInicioPeriodo,  int? diaInicioPendiente,  String? horaRecordatorio,  List<String> fcmTokens, @TimestampConverter()  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _Usuario():
return $default(_that.uid,_that.nombre,_that.email,_that.hogarId,_that.diaInicioPeriodo,_that.diaInicioPendiente,_that.horaRecordatorio,_that.fcmTokens,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String nombre,  String email,  String? hogarId,  int diaInicioPeriodo,  int? diaInicioPendiente,  String? horaRecordatorio,  List<String> fcmTokens, @TimestampConverter()  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _Usuario() when $default != null:
return $default(_that.uid,_that.nombre,_that.email,_that.hogarId,_that.diaInicioPeriodo,_that.diaInicioPendiente,_that.horaRecordatorio,_that.fcmTokens,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Usuario implements Usuario {
  const _Usuario({required this.uid, required this.nombre, required this.email, this.hogarId, this.diaInicioPeriodo = 1, this.diaInicioPendiente, this.horaRecordatorio,  List<String> fcmTokens = const <String>[], @TimestampConverter() required this.creadoEn}): _fcmTokens = fcmTokens;
  factory _Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);

@override final  String uid;
@override final  String nombre;
@override final  String email;
@override final  String? hogarId;
@override@JsonKey() final  int diaInicioPeriodo;
@override final  int? diaInicioPendiente;
@override final  String? horaRecordatorio;
 final  List<String> _fcmTokens;
@override@JsonKey() List<String> get fcmTokens {
  if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fcmTokens);
}

@override@TimestampConverter() final  DateTime creadoEn;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsuarioCopyWith<_Usuario> get copyWith => __$UsuarioCopyWithImpl<_Usuario>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsuarioToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Usuario&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.email, email) || other.email == email)&&(identical(other.hogarId, hogarId) || other.hogarId == hogarId)&&(identical(other.diaInicioPeriodo, diaInicioPeriodo) || other.diaInicioPeriodo == diaInicioPeriodo)&&(identical(other.diaInicioPendiente, diaInicioPendiente) || other.diaInicioPendiente == diaInicioPendiente)&&(identical(other.horaRecordatorio, horaRecordatorio) || other.horaRecordatorio == horaRecordatorio)&&const DeepCollectionEquality().equals(other.fcmTokens, _fcmTokens)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uid,nombre,email,hogarId,diaInicioPeriodo,diaInicioPendiente,horaRecordatorio,const DeepCollectionEquality().hash(_fcmTokens),creadoEn);
}

@override
String toString() {
    return 'Usuario(uid: $uid, nombre: $nombre, email: $email, hogarId: $hogarId, diaInicioPeriodo: $diaInicioPeriodo, diaInicioPendiente: $diaInicioPendiente, horaRecordatorio: $horaRecordatorio, fcmTokens: $fcmTokens, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$UsuarioCopyWith<$Res> implements $UsuarioCopyWith<$Res> {
  factory _$UsuarioCopyWith(_Usuario value, $Res Function(_Usuario) _then) = __$UsuarioCopyWithImpl;
@override @useResult
$Res call({
 String uid, String nombre, String email, String? hogarId, int diaInicioPeriodo, int? diaInicioPendiente, String? horaRecordatorio, List<String> fcmTokens,@TimestampConverter() DateTime creadoEn
});




}
/// @nodoc
class __$UsuarioCopyWithImpl<$Res>
    implements _$UsuarioCopyWith<$Res> {
  __$UsuarioCopyWithImpl(this._self, this._then);

  final _Usuario _self;
  final $Res Function(_Usuario) _then;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? nombre = null,Object? email = null,Object? hogarId = freezed,Object? diaInicioPeriodo = null,Object? diaInicioPendiente = freezed,Object? horaRecordatorio = freezed,Object? fcmTokens = null,Object? creadoEn = null,}) {
  return _then(_Usuario(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,hogarId: freezed == hogarId ? _self.hogarId : hogarId // ignore: cast_nullable_to_non_nullable
as String?,diaInicioPeriodo: null == diaInicioPeriodo ? _self.diaInicioPeriodo : diaInicioPeriodo // ignore: cast_nullable_to_non_nullable
as int,diaInicioPendiente: freezed == diaInicioPendiente ? _self.diaInicioPendiente : diaInicioPendiente // ignore: cast_nullable_to_non_nullable
as int?,horaRecordatorio: freezed == horaRecordatorio ? _self.horaRecordatorio : horaRecordatorio // ignore: cast_nullable_to_non_nullable
as String?,fcmTokens: null == fcmTokens ? _self._fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
