// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hogar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConfiguracionIaHogar {

 bool get activa; String get proveedor; String get modelo; int get limiteMensual;
/// Create a copy of ConfiguracionIaHogar
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfiguracionIaHogarCopyWith<ConfiguracionIaHogar> get copyWith => _$ConfiguracionIaHogarCopyWithImpl<ConfiguracionIaHogar>(this as ConfiguracionIaHogar, _$identity);

  /// Serializes this ConfiguracionIaHogar to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConfiguracionIaHogar;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfiguracionIaHogar&&(identical(other.activa, _this.activa) || other.activa == _this.activa)&&(identical(other.proveedor, _this.proveedor) || other.proveedor == _this.proveedor)&&(identical(other.modelo, _this.modelo) || other.modelo == _this.modelo)&&(identical(other.limiteMensual, _this.limiteMensual) || other.limiteMensual == _this.limiteMensual));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConfiguracionIaHogar;
  return Object.hash(runtimeType,_this.activa,_this.proveedor,_this.modelo,_this.limiteMensual);
}

@override
String toString() {
  final _this = this as ConfiguracionIaHogar;
  return 'ConfiguracionIaHogar(activa: ${_this.activa}, proveedor: ${_this.proveedor}, modelo: ${_this.modelo}, limiteMensual: ${_this.limiteMensual})';
}


}

/// @nodoc
abstract mixin class $ConfiguracionIaHogarCopyWith<$Res>  {
  factory $ConfiguracionIaHogarCopyWith(ConfiguracionIaHogar value, $Res Function(ConfiguracionIaHogar) _then) = _$ConfiguracionIaHogarCopyWithImpl;
@useResult
$Res call({
 bool activa, String proveedor, String modelo, int limiteMensual
});




}
/// @nodoc
class _$ConfiguracionIaHogarCopyWithImpl<$Res>
    implements $ConfiguracionIaHogarCopyWith<$Res> {
  _$ConfiguracionIaHogarCopyWithImpl(this._self, this._then);

  final ConfiguracionIaHogar _self;
  final $Res Function(ConfiguracionIaHogar) _then;

/// Create a copy of ConfiguracionIaHogar
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activa = null,Object? proveedor = null,Object? modelo = null,Object? limiteMensual = null,}) {
  return _then(ConfiguracionIaHogar(
activa: null == activa ? _self.activa : activa // ignore: cast_nullable_to_non_nullable
as bool,proveedor: null == proveedor ? _self.proveedor : proveedor // ignore: cast_nullable_to_non_nullable
as String,modelo: null == modelo ? _self.modelo : modelo // ignore: cast_nullable_to_non_nullable
as String,limiteMensual: null == limiteMensual ? _self.limiteMensual : limiteMensual // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfiguracionIaHogar].
extension ConfiguracionIaHogarPatterns on ConfiguracionIaHogar {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfiguracionIaHogar value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfiguracionIaHogar() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfiguracionIaHogar value)  $default,){
final _that = this;
switch (_that) {
case _ConfiguracionIaHogar():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfiguracionIaHogar value)?  $default,){
final _that = this;
switch (_that) {
case _ConfiguracionIaHogar() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool activa,  String proveedor,  String modelo,  int limiteMensual)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfiguracionIaHogar() when $default != null:
return $default(_that.activa,_that.proveedor,_that.modelo,_that.limiteMensual);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool activa,  String proveedor,  String modelo,  int limiteMensual)  $default,) {final _that = this;
switch (_that) {
case _ConfiguracionIaHogar():
return $default(_that.activa,_that.proveedor,_that.modelo,_that.limiteMensual);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool activa,  String proveedor,  String modelo,  int limiteMensual)?  $default,) {final _that = this;
switch (_that) {
case _ConfiguracionIaHogar() when $default != null:
return $default(_that.activa,_that.proveedor,_that.modelo,_that.limiteMensual);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfiguracionIaHogar implements ConfiguracionIaHogar {
  const _ConfiguracionIaHogar({this.activa = false, this.proveedor = '', this.modelo = '', this.limiteMensual = 0});
  factory _ConfiguracionIaHogar.fromJson(Map<String, dynamic> json) => _$ConfiguracionIaHogarFromJson(json);

@override@JsonKey() final  bool activa;
@override@JsonKey() final  String proveedor;
@override@JsonKey() final  String modelo;
@override@JsonKey() final  int limiteMensual;

/// Create a copy of ConfiguracionIaHogar
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfiguracionIaHogarCopyWith<_ConfiguracionIaHogar> get copyWith => __$ConfiguracionIaHogarCopyWithImpl<_ConfiguracionIaHogar>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfiguracionIaHogarToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfiguracionIaHogar&&(identical(other.activa, activa) || other.activa == activa)&&(identical(other.proveedor, proveedor) || other.proveedor == proveedor)&&(identical(other.modelo, modelo) || other.modelo == modelo)&&(identical(other.limiteMensual, limiteMensual) || other.limiteMensual == limiteMensual));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,activa,proveedor,modelo,limiteMensual);
}

@override
String toString() {
    return 'ConfiguracionIaHogar(activa: $activa, proveedor: $proveedor, modelo: $modelo, limiteMensual: $limiteMensual)';
}


}

/// @nodoc
abstract mixin class _$ConfiguracionIaHogarCopyWith<$Res> implements $ConfiguracionIaHogarCopyWith<$Res> {
  factory _$ConfiguracionIaHogarCopyWith(_ConfiguracionIaHogar value, $Res Function(_ConfiguracionIaHogar) _then) = __$ConfiguracionIaHogarCopyWithImpl;
@override @useResult
$Res call({
 bool activa, String proveedor, String modelo, int limiteMensual
});




}
/// @nodoc
class __$ConfiguracionIaHogarCopyWithImpl<$Res>
    implements _$ConfiguracionIaHogarCopyWith<$Res> {
  __$ConfiguracionIaHogarCopyWithImpl(this._self, this._then);

  final _ConfiguracionIaHogar _self;
  final $Res Function(_ConfiguracionIaHogar) _then;

/// Create a copy of ConfiguracionIaHogar
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activa = null,Object? proveedor = null,Object? modelo = null,Object? limiteMensual = null,}) {
  return _then(_ConfiguracionIaHogar(
activa: null == activa ? _self.activa : activa // ignore: cast_nullable_to_non_nullable
as bool,proveedor: null == proveedor ? _self.proveedor : proveedor // ignore: cast_nullable_to_non_nullable
as String,modelo: null == modelo ? _self.modelo : modelo // ignore: cast_nullable_to_non_nullable
as String,limiteMensual: null == limiteMensual ? _self.limiteMensual : limiteMensual // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Hogar {

 String get id; String get nombre; String get adminUid; ConfiguracionIaHogar get ia;@TimestampConverter() DateTime get creadoEn;
/// Create a copy of Hogar
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HogarCopyWith<Hogar> get copyWith => _$HogarCopyWithImpl<Hogar>(this as Hogar, _$identity);

  /// Serializes this Hogar to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Hogar;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Hogar&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.adminUid, _this.adminUid) || other.adminUid == _this.adminUid)&&(identical(other.ia, _this.ia) || other.ia == _this.ia)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Hogar;
  return Object.hash(runtimeType,_this.id,_this.nombre,_this.adminUid,_this.ia,_this.creadoEn);
}

@override
String toString() {
  final _this = this as Hogar;
  return 'Hogar(id: ${_this.id}, nombre: ${_this.nombre}, adminUid: ${_this.adminUid}, ia: ${_this.ia}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $HogarCopyWith<$Res>  {
  factory $HogarCopyWith(Hogar value, $Res Function(Hogar) _then) = _$HogarCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, String adminUid, ConfiguracionIaHogar ia,@TimestampConverter() DateTime creadoEn
});


$ConfiguracionIaHogarCopyWith<$Res> get ia;

}
/// @nodoc
class _$HogarCopyWithImpl<$Res>
    implements $HogarCopyWith<$Res> {
  _$HogarCopyWithImpl(this._self, this._then);

  final Hogar _self;
  final $Res Function(Hogar) _then;

/// Create a copy of Hogar
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? adminUid = null,Object? ia = null,Object? creadoEn = null,}) {
  return _then(Hogar(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,adminUid: null == adminUid ? _self.adminUid : adminUid // ignore: cast_nullable_to_non_nullable
as String,ia: null == ia ? _self.ia : ia // ignore: cast_nullable_to_non_nullable
as ConfiguracionIaHogar,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Hogar
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfiguracionIaHogarCopyWith<$Res> get ia {
  
  return $ConfiguracionIaHogarCopyWith<$Res>(_self.ia, (value) {
    return _then(_self.copyWith(ia: value));
  });
}
}


/// Adds pattern-matching-related methods to [Hogar].
extension HogarPatterns on Hogar {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Hogar value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Hogar() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Hogar value)  $default,){
final _that = this;
switch (_that) {
case _Hogar():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Hogar value)?  $default,){
final _that = this;
switch (_that) {
case _Hogar() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  String adminUid,  ConfiguracionIaHogar ia, @TimestampConverter()  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Hogar() when $default != null:
return $default(_that.id,_that.nombre,_that.adminUid,_that.ia,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  String adminUid,  ConfiguracionIaHogar ia, @TimestampConverter()  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _Hogar():
return $default(_that.id,_that.nombre,_that.adminUid,_that.ia,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  String adminUid,  ConfiguracionIaHogar ia, @TimestampConverter()  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _Hogar() when $default != null:
return $default(_that.id,_that.nombre,_that.adminUid,_that.ia,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Hogar implements Hogar {
  const _Hogar({required this.id, required this.nombre, required this.adminUid, this.ia = const ConfiguracionIaHogar(), @TimestampConverter() required this.creadoEn});
  factory _Hogar.fromJson(Map<String, dynamic> json) => _$HogarFromJson(json);

@override final  String id;
@override final  String nombre;
@override final  String adminUid;
@override@JsonKey() final  ConfiguracionIaHogar ia;
@override@TimestampConverter() final  DateTime creadoEn;

/// Create a copy of Hogar
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HogarCopyWith<_Hogar> get copyWith => __$HogarCopyWithImpl<_Hogar>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HogarToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hogar&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.adminUid, adminUid) || other.adminUid == adminUid)&&(identical(other.ia, ia) || other.ia == ia)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nombre,adminUid,ia,creadoEn);
}

@override
String toString() {
    return 'Hogar(id: $id, nombre: $nombre, adminUid: $adminUid, ia: $ia, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$HogarCopyWith<$Res> implements $HogarCopyWith<$Res> {
  factory _$HogarCopyWith(_Hogar value, $Res Function(_Hogar) _then) = __$HogarCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, String adminUid, ConfiguracionIaHogar ia,@TimestampConverter() DateTime creadoEn
});


@override $ConfiguracionIaHogarCopyWith<$Res> get ia;

}
/// @nodoc
class __$HogarCopyWithImpl<$Res>
    implements _$HogarCopyWith<$Res> {
  __$HogarCopyWithImpl(this._self, this._then);

  final _Hogar _self;
  final $Res Function(_Hogar) _then;

/// Create a copy of Hogar
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? adminUid = null,Object? ia = null,Object? creadoEn = null,}) {
  return _then(_Hogar(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,adminUid: null == adminUid ? _self.adminUid : adminUid // ignore: cast_nullable_to_non_nullable
as String,ia: null == ia ? _self.ia : ia // ignore: cast_nullable_to_non_nullable
as ConfiguracionIaHogar,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Hogar
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfiguracionIaHogarCopyWith<$Res> get ia {
  
  return $ConfiguracionIaHogarCopyWith<$Res>(_self.ia, (value) {
    return _then(_self.copyWith(ia: value));
  });
}
}

// dart format on
