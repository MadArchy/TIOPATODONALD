// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deuda_interna.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeudaInterna {

 String get id; String get acreedorUid; String get deudorUid; int get montoInicial; int get saldo; String get concepto; String get estado;@TimestampConverter() DateTime get creadaEn;
/// Create a copy of DeudaInterna
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeudaInternaCopyWith<DeudaInterna> get copyWith => _$DeudaInternaCopyWithImpl<DeudaInterna>(this as DeudaInterna, _$identity);

  /// Serializes this DeudaInterna to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeudaInterna;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeudaInterna&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.acreedorUid, _this.acreedorUid) || other.acreedorUid == _this.acreedorUid)&&(identical(other.deudorUid, _this.deudorUid) || other.deudorUid == _this.deudorUid)&&(identical(other.montoInicial, _this.montoInicial) || other.montoInicial == _this.montoInicial)&&(identical(other.saldo, _this.saldo) || other.saldo == _this.saldo)&&(identical(other.concepto, _this.concepto) || other.concepto == _this.concepto)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.creadaEn, _this.creadaEn) || other.creadaEn == _this.creadaEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeudaInterna;
  return Object.hash(runtimeType,_this.id,_this.acreedorUid,_this.deudorUid,_this.montoInicial,_this.saldo,_this.concepto,_this.estado,_this.creadaEn);
}

@override
String toString() {
  final _this = this as DeudaInterna;
  return 'DeudaInterna(id: ${_this.id}, acreedorUid: ${_this.acreedorUid}, deudorUid: ${_this.deudorUid}, montoInicial: ${_this.montoInicial}, saldo: ${_this.saldo}, concepto: ${_this.concepto}, estado: ${_this.estado}, creadaEn: ${_this.creadaEn})';
}


}

/// @nodoc
abstract mixin class $DeudaInternaCopyWith<$Res>  {
  factory $DeudaInternaCopyWith(DeudaInterna value, $Res Function(DeudaInterna) _then) = _$DeudaInternaCopyWithImpl;
@useResult
$Res call({
 String id, String acreedorUid, String deudorUid, int montoInicial, int saldo, String concepto, String estado,@TimestampConverter() DateTime creadaEn
});




}
/// @nodoc
class _$DeudaInternaCopyWithImpl<$Res>
    implements $DeudaInternaCopyWith<$Res> {
  _$DeudaInternaCopyWithImpl(this._self, this._then);

  final DeudaInterna _self;
  final $Res Function(DeudaInterna) _then;

/// Create a copy of DeudaInterna
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? acreedorUid = null,Object? deudorUid = null,Object? montoInicial = null,Object? saldo = null,Object? concepto = null,Object? estado = null,Object? creadaEn = null,}) {
  return _then(DeudaInterna(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,acreedorUid: null == acreedorUid ? _self.acreedorUid : acreedorUid // ignore: cast_nullable_to_non_nullable
as String,deudorUid: null == deudorUid ? _self.deudorUid : deudorUid // ignore: cast_nullable_to_non_nullable
as String,montoInicial: null == montoInicial ? _self.montoInicial : montoInicial // ignore: cast_nullable_to_non_nullable
as int,saldo: null == saldo ? _self.saldo : saldo // ignore: cast_nullable_to_non_nullable
as int,concepto: null == concepto ? _self.concepto : concepto // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,creadaEn: null == creadaEn ? _self.creadaEn : creadaEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DeudaInterna].
extension DeudaInternaPatterns on DeudaInterna {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeudaInterna value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeudaInterna() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeudaInterna value)  $default,){
final _that = this;
switch (_that) {
case _DeudaInterna():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeudaInterna value)?  $default,){
final _that = this;
switch (_that) {
case _DeudaInterna() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String acreedorUid,  String deudorUid,  int montoInicial,  int saldo,  String concepto,  String estado, @TimestampConverter()  DateTime creadaEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeudaInterna() when $default != null:
return $default(_that.id,_that.acreedorUid,_that.deudorUid,_that.montoInicial,_that.saldo,_that.concepto,_that.estado,_that.creadaEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String acreedorUid,  String deudorUid,  int montoInicial,  int saldo,  String concepto,  String estado, @TimestampConverter()  DateTime creadaEn)  $default,) {final _that = this;
switch (_that) {
case _DeudaInterna():
return $default(_that.id,_that.acreedorUid,_that.deudorUid,_that.montoInicial,_that.saldo,_that.concepto,_that.estado,_that.creadaEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String acreedorUid,  String deudorUid,  int montoInicial,  int saldo,  String concepto,  String estado, @TimestampConverter()  DateTime creadaEn)?  $default,) {final _that = this;
switch (_that) {
case _DeudaInterna() when $default != null:
return $default(_that.id,_that.acreedorUid,_that.deudorUid,_that.montoInicial,_that.saldo,_that.concepto,_that.estado,_that.creadaEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeudaInterna implements DeudaInterna {
  const _DeudaInterna({required this.id, required this.acreedorUid, required this.deudorUid, required this.montoInicial, required this.saldo, required this.concepto, this.estado = 'pendiente', @TimestampConverter() required this.creadaEn});
  factory _DeudaInterna.fromJson(Map<String, dynamic> json) => _$DeudaInternaFromJson(json);

@override final  String id;
@override final  String acreedorUid;
@override final  String deudorUid;
@override final  int montoInicial;
@override final  int saldo;
@override final  String concepto;
@override@JsonKey() final  String estado;
@override@TimestampConverter() final  DateTime creadaEn;

/// Create a copy of DeudaInterna
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeudaInternaCopyWith<_DeudaInterna> get copyWith => __$DeudaInternaCopyWithImpl<_DeudaInterna>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeudaInternaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeudaInterna&&(identical(other.id, id) || other.id == id)&&(identical(other.acreedorUid, acreedorUid) || other.acreedorUid == acreedorUid)&&(identical(other.deudorUid, deudorUid) || other.deudorUid == deudorUid)&&(identical(other.montoInicial, montoInicial) || other.montoInicial == montoInicial)&&(identical(other.saldo, saldo) || other.saldo == saldo)&&(identical(other.concepto, concepto) || other.concepto == concepto)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.creadaEn, creadaEn) || other.creadaEn == creadaEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,acreedorUid,deudorUid,montoInicial,saldo,concepto,estado,creadaEn);
}

@override
String toString() {
    return 'DeudaInterna(id: $id, acreedorUid: $acreedorUid, deudorUid: $deudorUid, montoInicial: $montoInicial, saldo: $saldo, concepto: $concepto, estado: $estado, creadaEn: $creadaEn)';
}


}

/// @nodoc
abstract mixin class _$DeudaInternaCopyWith<$Res> implements $DeudaInternaCopyWith<$Res> {
  factory _$DeudaInternaCopyWith(_DeudaInterna value, $Res Function(_DeudaInterna) _then) = __$DeudaInternaCopyWithImpl;
@override @useResult
$Res call({
 String id, String acreedorUid, String deudorUid, int montoInicial, int saldo, String concepto, String estado,@TimestampConverter() DateTime creadaEn
});




}
/// @nodoc
class __$DeudaInternaCopyWithImpl<$Res>
    implements _$DeudaInternaCopyWith<$Res> {
  __$DeudaInternaCopyWithImpl(this._self, this._then);

  final _DeudaInterna _self;
  final $Res Function(_DeudaInterna) _then;

/// Create a copy of DeudaInterna
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? acreedorUid = null,Object? deudorUid = null,Object? montoInicial = null,Object? saldo = null,Object? concepto = null,Object? estado = null,Object? creadaEn = null,}) {
  return _then(_DeudaInterna(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,acreedorUid: null == acreedorUid ? _self.acreedorUid : acreedorUid // ignore: cast_nullable_to_non_nullable
as String,deudorUid: null == deudorUid ? _self.deudorUid : deudorUid // ignore: cast_nullable_to_non_nullable
as String,montoInicial: null == montoInicial ? _self.montoInicial : montoInicial // ignore: cast_nullable_to_non_nullable
as int,saldo: null == saldo ? _self.saldo : saldo // ignore: cast_nullable_to_non_nullable
as int,concepto: null == concepto ? _self.concepto : concepto // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,creadaEn: null == creadaEn ? _self.creadaEn : creadaEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
