// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pago_interno.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PagoInterno {

 String get id; int get monto;@TimestampConverter() DateTime get fecha; String get registradoPor; bool get confirmado;@NullableTimestampConverter() DateTime? get confirmadoEn;
/// Create a copy of PagoInterno
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagoInternoCopyWith<PagoInterno> get copyWith => _$PagoInternoCopyWithImpl<PagoInterno>(this as PagoInterno, _$identity);

  /// Serializes this PagoInterno to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PagoInterno;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagoInterno&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.monto, _this.monto) || other.monto == _this.monto)&&(identical(other.fecha, _this.fecha) || other.fecha == _this.fecha)&&(identical(other.registradoPor, _this.registradoPor) || other.registradoPor == _this.registradoPor)&&(identical(other.confirmado, _this.confirmado) || other.confirmado == _this.confirmado)&&(identical(other.confirmadoEn, _this.confirmadoEn) || other.confirmadoEn == _this.confirmadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PagoInterno;
  return Object.hash(runtimeType,_this.id,_this.monto,_this.fecha,_this.registradoPor,_this.confirmado,_this.confirmadoEn);
}

@override
String toString() {
  final _this = this as PagoInterno;
  return 'PagoInterno(id: ${_this.id}, monto: ${_this.monto}, fecha: ${_this.fecha}, registradoPor: ${_this.registradoPor}, confirmado: ${_this.confirmado}, confirmadoEn: ${_this.confirmadoEn})';
}


}

/// @nodoc
abstract mixin class $PagoInternoCopyWith<$Res>  {
  factory $PagoInternoCopyWith(PagoInterno value, $Res Function(PagoInterno) _then) = _$PagoInternoCopyWithImpl;
@useResult
$Res call({
 String id, int monto,@TimestampConverter() DateTime fecha, String registradoPor, bool confirmado,@NullableTimestampConverter() DateTime? confirmadoEn
});




}
/// @nodoc
class _$PagoInternoCopyWithImpl<$Res>
    implements $PagoInternoCopyWith<$Res> {
  _$PagoInternoCopyWithImpl(this._self, this._then);

  final PagoInterno _self;
  final $Res Function(PagoInterno) _then;

/// Create a copy of PagoInterno
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? monto = null,Object? fecha = null,Object? registradoPor = null,Object? confirmado = null,Object? confirmadoEn = freezed,}) {
  return _then(PagoInterno(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as int,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,registradoPor: null == registradoPor ? _self.registradoPor : registradoPor // ignore: cast_nullable_to_non_nullable
as String,confirmado: null == confirmado ? _self.confirmado : confirmado // ignore: cast_nullable_to_non_nullable
as bool,confirmadoEn: freezed == confirmadoEn ? _self.confirmadoEn : confirmadoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PagoInterno].
extension PagoInternoPatterns on PagoInterno {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagoInterno value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagoInterno() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagoInterno value)  $default,){
final _that = this;
switch (_that) {
case _PagoInterno():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagoInterno value)?  $default,){
final _that = this;
switch (_that) {
case _PagoInterno() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int monto, @TimestampConverter()  DateTime fecha,  String registradoPor,  bool confirmado, @NullableTimestampConverter()  DateTime? confirmadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagoInterno() when $default != null:
return $default(_that.id,_that.monto,_that.fecha,_that.registradoPor,_that.confirmado,_that.confirmadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int monto, @TimestampConverter()  DateTime fecha,  String registradoPor,  bool confirmado, @NullableTimestampConverter()  DateTime? confirmadoEn)  $default,) {final _that = this;
switch (_that) {
case _PagoInterno():
return $default(_that.id,_that.monto,_that.fecha,_that.registradoPor,_that.confirmado,_that.confirmadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int monto, @TimestampConverter()  DateTime fecha,  String registradoPor,  bool confirmado, @NullableTimestampConverter()  DateTime? confirmadoEn)?  $default,) {final _that = this;
switch (_that) {
case _PagoInterno() when $default != null:
return $default(_that.id,_that.monto,_that.fecha,_that.registradoPor,_that.confirmado,_that.confirmadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagoInterno implements PagoInterno {
  const _PagoInterno({required this.id, required this.monto, @TimestampConverter() required this.fecha, required this.registradoPor, this.confirmado = false, @NullableTimestampConverter() this.confirmadoEn});
  factory _PagoInterno.fromJson(Map<String, dynamic> json) => _$PagoInternoFromJson(json);

@override final  String id;
@override final  int monto;
@override@TimestampConverter() final  DateTime fecha;
@override final  String registradoPor;
@override@JsonKey() final  bool confirmado;
@override@NullableTimestampConverter() final  DateTime? confirmadoEn;

/// Create a copy of PagoInterno
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagoInternoCopyWith<_PagoInterno> get copyWith => __$PagoInternoCopyWithImpl<_PagoInterno>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagoInternoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagoInterno&&(identical(other.id, id) || other.id == id)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.registradoPor, registradoPor) || other.registradoPor == registradoPor)&&(identical(other.confirmado, confirmado) || other.confirmado == confirmado)&&(identical(other.confirmadoEn, confirmadoEn) || other.confirmadoEn == confirmadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,monto,fecha,registradoPor,confirmado,confirmadoEn);
}

@override
String toString() {
    return 'PagoInterno(id: $id, monto: $monto, fecha: $fecha, registradoPor: $registradoPor, confirmado: $confirmado, confirmadoEn: $confirmadoEn)';
}


}

/// @nodoc
abstract mixin class _$PagoInternoCopyWith<$Res> implements $PagoInternoCopyWith<$Res> {
  factory _$PagoInternoCopyWith(_PagoInterno value, $Res Function(_PagoInterno) _then) = __$PagoInternoCopyWithImpl;
@override @useResult
$Res call({
 String id, int monto,@TimestampConverter() DateTime fecha, String registradoPor, bool confirmado,@NullableTimestampConverter() DateTime? confirmadoEn
});




}
/// @nodoc
class __$PagoInternoCopyWithImpl<$Res>
    implements _$PagoInternoCopyWith<$Res> {
  __$PagoInternoCopyWithImpl(this._self, this._then);

  final _PagoInterno _self;
  final $Res Function(_PagoInterno) _then;

/// Create a copy of PagoInterno
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? monto = null,Object? fecha = null,Object? registradoPor = null,Object? confirmado = null,Object? confirmadoEn = freezed,}) {
  return _then(_PagoInterno(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as int,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,registradoPor: null == registradoPor ? _self.registradoPor : registradoPor // ignore: cast_nullable_to_non_nullable
as String,confirmado: null == confirmado ? _self.confirmado : confirmado // ignore: cast_nullable_to_non_nullable
as bool,confirmadoEn: freezed == confirmadoEn ? _self.confirmadoEn : confirmadoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
