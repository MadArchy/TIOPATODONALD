// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferencias_avisos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PreferenciasAvisos {

 bool get alertasPresupuesto; bool get recordatorioDiario; bool get cuotas; bool get correcciones; bool get deudasInternas;
/// Create a copy of PreferenciasAvisos
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferenciasAvisosCopyWith<PreferenciasAvisos> get copyWith => _$PreferenciasAvisosCopyWithImpl<PreferenciasAvisos>(this as PreferenciasAvisos, _$identity);

  /// Serializes this PreferenciasAvisos to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PreferenciasAvisos;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferenciasAvisos&&(identical(other.alertasPresupuesto, _this.alertasPresupuesto) || other.alertasPresupuesto == _this.alertasPresupuesto)&&(identical(other.recordatorioDiario, _this.recordatorioDiario) || other.recordatorioDiario == _this.recordatorioDiario)&&(identical(other.cuotas, _this.cuotas) || other.cuotas == _this.cuotas)&&(identical(other.correcciones, _this.correcciones) || other.correcciones == _this.correcciones)&&(identical(other.deudasInternas, _this.deudasInternas) || other.deudasInternas == _this.deudasInternas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PreferenciasAvisos;
  return Object.hash(runtimeType,_this.alertasPresupuesto,_this.recordatorioDiario,_this.cuotas,_this.correcciones,_this.deudasInternas);
}

@override
String toString() {
  final _this = this as PreferenciasAvisos;
  return 'PreferenciasAvisos(alertasPresupuesto: ${_this.alertasPresupuesto}, recordatorioDiario: ${_this.recordatorioDiario}, cuotas: ${_this.cuotas}, correcciones: ${_this.correcciones}, deudasInternas: ${_this.deudasInternas})';
}


}

/// @nodoc
abstract mixin class $PreferenciasAvisosCopyWith<$Res>  {
  factory $PreferenciasAvisosCopyWith(PreferenciasAvisos value, $Res Function(PreferenciasAvisos) _then) = _$PreferenciasAvisosCopyWithImpl;
@useResult
$Res call({
 bool alertasPresupuesto, bool recordatorioDiario, bool cuotas, bool correcciones, bool deudasInternas
});




}
/// @nodoc
class _$PreferenciasAvisosCopyWithImpl<$Res>
    implements $PreferenciasAvisosCopyWith<$Res> {
  _$PreferenciasAvisosCopyWithImpl(this._self, this._then);

  final PreferenciasAvisos _self;
  final $Res Function(PreferenciasAvisos) _then;

/// Create a copy of PreferenciasAvisos
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? alertasPresupuesto = null,Object? recordatorioDiario = null,Object? cuotas = null,Object? correcciones = null,Object? deudasInternas = null,}) {
  return _then(PreferenciasAvisos(
alertasPresupuesto: null == alertasPresupuesto ? _self.alertasPresupuesto : alertasPresupuesto // ignore: cast_nullable_to_non_nullable
as bool,recordatorioDiario: null == recordatorioDiario ? _self.recordatorioDiario : recordatorioDiario // ignore: cast_nullable_to_non_nullable
as bool,cuotas: null == cuotas ? _self.cuotas : cuotas // ignore: cast_nullable_to_non_nullable
as bool,correcciones: null == correcciones ? _self.correcciones : correcciones // ignore: cast_nullable_to_non_nullable
as bool,deudasInternas: null == deudasInternas ? _self.deudasInternas : deudasInternas // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PreferenciasAvisos].
extension PreferenciasAvisosPatterns on PreferenciasAvisos {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreferenciasAvisos value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreferenciasAvisos() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreferenciasAvisos value)  $default,){
final _that = this;
switch (_that) {
case _PreferenciasAvisos():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreferenciasAvisos value)?  $default,){
final _that = this;
switch (_that) {
case _PreferenciasAvisos() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool alertasPresupuesto,  bool recordatorioDiario,  bool cuotas,  bool correcciones,  bool deudasInternas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreferenciasAvisos() when $default != null:
return $default(_that.alertasPresupuesto,_that.recordatorioDiario,_that.cuotas,_that.correcciones,_that.deudasInternas);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool alertasPresupuesto,  bool recordatorioDiario,  bool cuotas,  bool correcciones,  bool deudasInternas)  $default,) {final _that = this;
switch (_that) {
case _PreferenciasAvisos():
return $default(_that.alertasPresupuesto,_that.recordatorioDiario,_that.cuotas,_that.correcciones,_that.deudasInternas);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool alertasPresupuesto,  bool recordatorioDiario,  bool cuotas,  bool correcciones,  bool deudasInternas)?  $default,) {final _that = this;
switch (_that) {
case _PreferenciasAvisos() when $default != null:
return $default(_that.alertasPresupuesto,_that.recordatorioDiario,_that.cuotas,_that.correcciones,_that.deudasInternas);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PreferenciasAvisos implements PreferenciasAvisos {
  const _PreferenciasAvisos({this.alertasPresupuesto = true, this.recordatorioDiario = true, this.cuotas = true, this.correcciones = true, this.deudasInternas = true});
  factory _PreferenciasAvisos.fromJson(Map<String, dynamic> json) => _$PreferenciasAvisosFromJson(json);

@override@JsonKey() final  bool alertasPresupuesto;
@override@JsonKey() final  bool recordatorioDiario;
@override@JsonKey() final  bool cuotas;
@override@JsonKey() final  bool correcciones;
@override@JsonKey() final  bool deudasInternas;

/// Create a copy of PreferenciasAvisos
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreferenciasAvisosCopyWith<_PreferenciasAvisos> get copyWith => __$PreferenciasAvisosCopyWithImpl<_PreferenciasAvisos>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PreferenciasAvisosToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreferenciasAvisos&&(identical(other.alertasPresupuesto, alertasPresupuesto) || other.alertasPresupuesto == alertasPresupuesto)&&(identical(other.recordatorioDiario, recordatorioDiario) || other.recordatorioDiario == recordatorioDiario)&&(identical(other.cuotas, cuotas) || other.cuotas == cuotas)&&(identical(other.correcciones, correcciones) || other.correcciones == correcciones)&&(identical(other.deudasInternas, deudasInternas) || other.deudasInternas == deudasInternas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,alertasPresupuesto,recordatorioDiario,cuotas,correcciones,deudasInternas);
}

@override
String toString() {
    return 'PreferenciasAvisos(alertasPresupuesto: $alertasPresupuesto, recordatorioDiario: $recordatorioDiario, cuotas: $cuotas, correcciones: $correcciones, deudasInternas: $deudasInternas)';
}


}

/// @nodoc
abstract mixin class _$PreferenciasAvisosCopyWith<$Res> implements $PreferenciasAvisosCopyWith<$Res> {
  factory _$PreferenciasAvisosCopyWith(_PreferenciasAvisos value, $Res Function(_PreferenciasAvisos) _then) = __$PreferenciasAvisosCopyWithImpl;
@override @useResult
$Res call({
 bool alertasPresupuesto, bool recordatorioDiario, bool cuotas, bool correcciones, bool deudasInternas
});




}
/// @nodoc
class __$PreferenciasAvisosCopyWithImpl<$Res>
    implements _$PreferenciasAvisosCopyWith<$Res> {
  __$PreferenciasAvisosCopyWithImpl(this._self, this._then);

  final _PreferenciasAvisos _self;
  final $Res Function(_PreferenciasAvisos) _then;

/// Create a copy of PreferenciasAvisos
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? alertasPresupuesto = null,Object? recordatorioDiario = null,Object? cuotas = null,Object? correcciones = null,Object? deudasInternas = null,}) {
  return _then(_PreferenciasAvisos(
alertasPresupuesto: null == alertasPresupuesto ? _self.alertasPresupuesto : alertasPresupuesto // ignore: cast_nullable_to_non_nullable
as bool,recordatorioDiario: null == recordatorioDiario ? _self.recordatorioDiario : recordatorioDiario // ignore: cast_nullable_to_non_nullable
as bool,cuotas: null == cuotas ? _self.cuotas : cuotas // ignore: cast_nullable_to_non_nullable
as bool,correcciones: null == correcciones ? _self.correcciones : correcciones // ignore: cast_nullable_to_non_nullable
as bool,deudasInternas: null == deudasInternas ? _self.deudasInternas : deudasInternas // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
