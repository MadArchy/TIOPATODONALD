// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presupuesto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Presupuesto {

 String get id; String get uid; String get periodoId; int get monto; List<int> get alertasEnviadas;@TimestampConverter() DateTime get actualizadoEn;
/// Create a copy of Presupuesto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresupuestoCopyWith<Presupuesto> get copyWith => _$PresupuestoCopyWithImpl<Presupuesto>(this as Presupuesto, _$identity);

  /// Serializes this Presupuesto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Presupuesto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Presupuesto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.periodoId, _this.periodoId) || other.periodoId == _this.periodoId)&&(identical(other.monto, _this.monto) || other.monto == _this.monto)&&const DeepCollectionEquality().equals(other.alertasEnviadas, _this.alertasEnviadas)&&(identical(other.actualizadoEn, _this.actualizadoEn) || other.actualizadoEn == _this.actualizadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Presupuesto;
  return Object.hash(runtimeType,_this.id,_this.uid,_this.periodoId,_this.monto,const DeepCollectionEquality().hash(_this.alertasEnviadas),_this.actualizadoEn);
}

@override
String toString() {
  final _this = this as Presupuesto;
  return 'Presupuesto(id: ${_this.id}, uid: ${_this.uid}, periodoId: ${_this.periodoId}, monto: ${_this.monto}, alertasEnviadas: ${_this.alertasEnviadas}, actualizadoEn: ${_this.actualizadoEn})';
}


}

/// @nodoc
abstract mixin class $PresupuestoCopyWith<$Res>  {
  factory $PresupuestoCopyWith(Presupuesto value, $Res Function(Presupuesto) _then) = _$PresupuestoCopyWithImpl;
@useResult
$Res call({
 String id, String uid, String periodoId, int monto, List<int> alertasEnviadas,@TimestampConverter() DateTime actualizadoEn
});




}
/// @nodoc
class _$PresupuestoCopyWithImpl<$Res>
    implements $PresupuestoCopyWith<$Res> {
  _$PresupuestoCopyWithImpl(this._self, this._then);

  final Presupuesto _self;
  final $Res Function(Presupuesto) _then;

/// Create a copy of Presupuesto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uid = null,Object? periodoId = null,Object? monto = null,Object? alertasEnviadas = null,Object? actualizadoEn = null,}) {
  return _then(Presupuesto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,periodoId: null == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as int,alertasEnviadas: null == alertasEnviadas ? _self.alertasEnviadas : alertasEnviadas // ignore: cast_nullable_to_non_nullable
as List<int>,actualizadoEn: null == actualizadoEn ? _self.actualizadoEn : actualizadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Presupuesto].
extension PresupuestoPatterns on Presupuesto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Presupuesto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Presupuesto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Presupuesto value)  $default,){
final _that = this;
switch (_that) {
case _Presupuesto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Presupuesto value)?  $default,){
final _that = this;
switch (_that) {
case _Presupuesto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String uid,  String periodoId,  int monto,  List<int> alertasEnviadas, @TimestampConverter()  DateTime actualizadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Presupuesto() when $default != null:
return $default(_that.id,_that.uid,_that.periodoId,_that.monto,_that.alertasEnviadas,_that.actualizadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String uid,  String periodoId,  int monto,  List<int> alertasEnviadas, @TimestampConverter()  DateTime actualizadoEn)  $default,) {final _that = this;
switch (_that) {
case _Presupuesto():
return $default(_that.id,_that.uid,_that.periodoId,_that.monto,_that.alertasEnviadas,_that.actualizadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String uid,  String periodoId,  int monto,  List<int> alertasEnviadas, @TimestampConverter()  DateTime actualizadoEn)?  $default,) {final _that = this;
switch (_that) {
case _Presupuesto() when $default != null:
return $default(_that.id,_that.uid,_that.periodoId,_that.monto,_that.alertasEnviadas,_that.actualizadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Presupuesto implements Presupuesto {
  const _Presupuesto({required this.id, required this.uid, required this.periodoId, required this.monto,  List<int> alertasEnviadas = const <int>[], @TimestampConverter() required this.actualizadoEn}): _alertasEnviadas = alertasEnviadas;
  factory _Presupuesto.fromJson(Map<String, dynamic> json) => _$PresupuestoFromJson(json);

@override final  String id;
@override final  String uid;
@override final  String periodoId;
@override final  int monto;
 final  List<int> _alertasEnviadas;
@override@JsonKey() List<int> get alertasEnviadas {
  if (_alertasEnviadas is EqualUnmodifiableListView) return _alertasEnviadas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alertasEnviadas);
}

@override@TimestampConverter() final  DateTime actualizadoEn;

/// Create a copy of Presupuesto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresupuestoCopyWith<_Presupuesto> get copyWith => __$PresupuestoCopyWithImpl<_Presupuesto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresupuestoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Presupuesto&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.periodoId, periodoId) || other.periodoId == periodoId)&&(identical(other.monto, monto) || other.monto == monto)&&const DeepCollectionEquality().equals(other.alertasEnviadas, _alertasEnviadas)&&(identical(other.actualizadoEn, actualizadoEn) || other.actualizadoEn == actualizadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,uid,periodoId,monto,const DeepCollectionEquality().hash(_alertasEnviadas),actualizadoEn);
}

@override
String toString() {
    return 'Presupuesto(id: $id, uid: $uid, periodoId: $periodoId, monto: $monto, alertasEnviadas: $alertasEnviadas, actualizadoEn: $actualizadoEn)';
}


}

/// @nodoc
abstract mixin class _$PresupuestoCopyWith<$Res> implements $PresupuestoCopyWith<$Res> {
  factory _$PresupuestoCopyWith(_Presupuesto value, $Res Function(_Presupuesto) _then) = __$PresupuestoCopyWithImpl;
@override @useResult
$Res call({
 String id, String uid, String periodoId, int monto, List<int> alertasEnviadas,@TimestampConverter() DateTime actualizadoEn
});




}
/// @nodoc
class __$PresupuestoCopyWithImpl<$Res>
    implements _$PresupuestoCopyWith<$Res> {
  __$PresupuestoCopyWithImpl(this._self, this._then);

  final _Presupuesto _self;
  final $Res Function(_Presupuesto) _then;

/// Create a copy of Presupuesto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uid = null,Object? periodoId = null,Object? monto = null,Object? alertasEnviadas = null,Object? actualizadoEn = null,}) {
  return _then(_Presupuesto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,periodoId: null == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as int,alertasEnviadas: null == alertasEnviadas ? _self._alertasEnviadas : alertasEnviadas // ignore: cast_nullable_to_non_nullable
as List<int>,actualizadoEn: null == actualizadoEn ? _self.actualizadoEn : actualizadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
