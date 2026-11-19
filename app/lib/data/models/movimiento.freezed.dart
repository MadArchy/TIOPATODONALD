// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movimiento.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Movimiento {

 String get id; String get tipo; int get monto; String? get categoria; String? get deudaId; String? get gastoFijoId;@TimestampConverter() DateTime get fecha; String get periodoId; String get uid; String get nota; String? get fotoPath; String get origen; String get estado;@TimestampConverter() DateTime get creadoEn;@NullableTimestampConverter() DateTime? get editadoEn; bool get saldoAplicado;
/// Create a copy of Movimiento
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovimientoCopyWith<Movimiento> get copyWith => _$MovimientoCopyWithImpl<Movimiento>(this as Movimiento, _$identity);

  /// Serializes this Movimiento to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Movimiento;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Movimiento&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.monto, _this.monto) || other.monto == _this.monto)&&(identical(other.categoria, _this.categoria) || other.categoria == _this.categoria)&&(identical(other.deudaId, _this.deudaId) || other.deudaId == _this.deudaId)&&(identical(other.gastoFijoId, _this.gastoFijoId) || other.gastoFijoId == _this.gastoFijoId)&&(identical(other.fecha, _this.fecha) || other.fecha == _this.fecha)&&(identical(other.periodoId, _this.periodoId) || other.periodoId == _this.periodoId)&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.nota, _this.nota) || other.nota == _this.nota)&&(identical(other.fotoPath, _this.fotoPath) || other.fotoPath == _this.fotoPath)&&(identical(other.origen, _this.origen) || other.origen == _this.origen)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn)&&(identical(other.editadoEn, _this.editadoEn) || other.editadoEn == _this.editadoEn)&&(identical(other.saldoAplicado, _this.saldoAplicado) || other.saldoAplicado == _this.saldoAplicado));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Movimiento;
  return Object.hash(runtimeType,_this.id,_this.tipo,_this.monto,_this.categoria,_this.deudaId,_this.gastoFijoId,_this.fecha,_this.periodoId,_this.uid,_this.nota,_this.fotoPath,_this.origen,_this.estado,_this.creadoEn,_this.editadoEn,_this.saldoAplicado);
}

@override
String toString() {
  final _this = this as Movimiento;
  return 'Movimiento(id: ${_this.id}, tipo: ${_this.tipo}, monto: ${_this.monto}, categoria: ${_this.categoria}, deudaId: ${_this.deudaId}, gastoFijoId: ${_this.gastoFijoId}, fecha: ${_this.fecha}, periodoId: ${_this.periodoId}, uid: ${_this.uid}, nota: ${_this.nota}, fotoPath: ${_this.fotoPath}, origen: ${_this.origen}, estado: ${_this.estado}, creadoEn: ${_this.creadoEn}, editadoEn: ${_this.editadoEn}, saldoAplicado: ${_this.saldoAplicado})';
}


}

/// @nodoc
abstract mixin class $MovimientoCopyWith<$Res>  {
  factory $MovimientoCopyWith(Movimiento value, $Res Function(Movimiento) _then) = _$MovimientoCopyWithImpl;
@useResult
$Res call({
 String id, String tipo, int monto, String? categoria, String? deudaId, String? gastoFijoId,@TimestampConverter() DateTime fecha, String periodoId, String uid, String nota, String? fotoPath, String origen, String estado,@TimestampConverter() DateTime creadoEn,@NullableTimestampConverter() DateTime? editadoEn, bool saldoAplicado
});




}
/// @nodoc
class _$MovimientoCopyWithImpl<$Res>
    implements $MovimientoCopyWith<$Res> {
  _$MovimientoCopyWithImpl(this._self, this._then);

  final Movimiento _self;
  final $Res Function(Movimiento) _then;

/// Create a copy of Movimiento
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tipo = null,Object? monto = null,Object? categoria = freezed,Object? deudaId = freezed,Object? gastoFijoId = freezed,Object? fecha = null,Object? periodoId = null,Object? uid = null,Object? nota = null,Object? fotoPath = freezed,Object? origen = null,Object? estado = null,Object? creadoEn = null,Object? editadoEn = freezed,Object? saldoAplicado = null,}) {
  return _then(Movimiento(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as int,categoria: freezed == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String?,deudaId: freezed == deudaId ? _self.deudaId : deudaId // ignore: cast_nullable_to_non_nullable
as String?,gastoFijoId: freezed == gastoFijoId ? _self.gastoFijoId : gastoFijoId // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,periodoId: null == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nota: null == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String,fotoPath: freezed == fotoPath ? _self.fotoPath : fotoPath // ignore: cast_nullable_to_non_nullable
as String?,origen: null == origen ? _self.origen : origen // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,editadoEn: freezed == editadoEn ? _self.editadoEn : editadoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,saldoAplicado: null == saldoAplicado ? _self.saldoAplicado : saldoAplicado // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Movimiento].
extension MovimientoPatterns on Movimiento {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Movimiento value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Movimiento() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Movimiento value)  $default,){
final _that = this;
switch (_that) {
case _Movimiento():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Movimiento value)?  $default,){
final _that = this;
switch (_that) {
case _Movimiento() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tipo,  int monto,  String? categoria,  String? deudaId,  String? gastoFijoId, @TimestampConverter()  DateTime fecha,  String periodoId,  String uid,  String nota,  String? fotoPath,  String origen,  String estado, @TimestampConverter()  DateTime creadoEn, @NullableTimestampConverter()  DateTime? editadoEn,  bool saldoAplicado)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Movimiento() when $default != null:
return $default(_that.id,_that.tipo,_that.monto,_that.categoria,_that.deudaId,_that.gastoFijoId,_that.fecha,_that.periodoId,_that.uid,_that.nota,_that.fotoPath,_that.origen,_that.estado,_that.creadoEn,_that.editadoEn,_that.saldoAplicado);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tipo,  int monto,  String? categoria,  String? deudaId,  String? gastoFijoId, @TimestampConverter()  DateTime fecha,  String periodoId,  String uid,  String nota,  String? fotoPath,  String origen,  String estado, @TimestampConverter()  DateTime creadoEn, @NullableTimestampConverter()  DateTime? editadoEn,  bool saldoAplicado)  $default,) {final _that = this;
switch (_that) {
case _Movimiento():
return $default(_that.id,_that.tipo,_that.monto,_that.categoria,_that.deudaId,_that.gastoFijoId,_that.fecha,_that.periodoId,_that.uid,_that.nota,_that.fotoPath,_that.origen,_that.estado,_that.creadoEn,_that.editadoEn,_that.saldoAplicado);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tipo,  int monto,  String? categoria,  String? deudaId,  String? gastoFijoId, @TimestampConverter()  DateTime fecha,  String periodoId,  String uid,  String nota,  String? fotoPath,  String origen,  String estado, @TimestampConverter()  DateTime creadoEn, @NullableTimestampConverter()  DateTime? editadoEn,  bool saldoAplicado)?  $default,) {final _that = this;
switch (_that) {
case _Movimiento() when $default != null:
return $default(_that.id,_that.tipo,_that.monto,_that.categoria,_that.deudaId,_that.gastoFijoId,_that.fecha,_that.periodoId,_that.uid,_that.nota,_that.fotoPath,_that.origen,_that.estado,_that.creadoEn,_that.editadoEn,_that.saldoAplicado);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Movimiento implements Movimiento {
  const _Movimiento({required this.id, required this.tipo, required this.monto, this.categoria, this.deudaId, this.gastoFijoId, @TimestampConverter() required this.fecha, required this.periodoId, required this.uid, this.nota = '', this.fotoPath, this.origen = 'formulario', this.estado = 'activo', @TimestampConverter() required this.creadoEn, @NullableTimestampConverter() this.editadoEn, this.saldoAplicado = false});
  factory _Movimiento.fromJson(Map<String, dynamic> json) => _$MovimientoFromJson(json);

@override final  String id;
@override final  String tipo;
@override final  int monto;
@override final  String? categoria;
@override final  String? deudaId;
@override final  String? gastoFijoId;
@override@TimestampConverter() final  DateTime fecha;
@override final  String periodoId;
@override final  String uid;
@override@JsonKey() final  String nota;
@override final  String? fotoPath;
@override@JsonKey() final  String origen;
@override@JsonKey() final  String estado;
@override@TimestampConverter() final  DateTime creadoEn;
@override@NullableTimestampConverter() final  DateTime? editadoEn;
@override@JsonKey() final  bool saldoAplicado;

/// Create a copy of Movimiento
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovimientoCopyWith<_Movimiento> get copyWith => __$MovimientoCopyWithImpl<_Movimiento>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovimientoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Movimiento&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.deudaId, deudaId) || other.deudaId == deudaId)&&(identical(other.gastoFijoId, gastoFijoId) || other.gastoFijoId == gastoFijoId)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.periodoId, periodoId) || other.periodoId == periodoId)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.fotoPath, fotoPath) || other.fotoPath == fotoPath)&&(identical(other.origen, origen) || other.origen == origen)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn)&&(identical(other.editadoEn, editadoEn) || other.editadoEn == editadoEn)&&(identical(other.saldoAplicado, saldoAplicado) || other.saldoAplicado == saldoAplicado));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,tipo,monto,categoria,deudaId,gastoFijoId,fecha,periodoId,uid,nota,fotoPath,origen,estado,creadoEn,editadoEn,saldoAplicado);
}

@override
String toString() {
    return 'Movimiento(id: $id, tipo: $tipo, monto: $monto, categoria: $categoria, deudaId: $deudaId, gastoFijoId: $gastoFijoId, fecha: $fecha, periodoId: $periodoId, uid: $uid, nota: $nota, fotoPath: $fotoPath, origen: $origen, estado: $estado, creadoEn: $creadoEn, editadoEn: $editadoEn, saldoAplicado: $saldoAplicado)';
}


}

/// @nodoc
abstract mixin class _$MovimientoCopyWith<$Res> implements $MovimientoCopyWith<$Res> {
  factory _$MovimientoCopyWith(_Movimiento value, $Res Function(_Movimiento) _then) = __$MovimientoCopyWithImpl;
@override @useResult
$Res call({
 String id, String tipo, int monto, String? categoria, String? deudaId, String? gastoFijoId,@TimestampConverter() DateTime fecha, String periodoId, String uid, String nota, String? fotoPath, String origen, String estado,@TimestampConverter() DateTime creadoEn,@NullableTimestampConverter() DateTime? editadoEn, bool saldoAplicado
});




}
/// @nodoc
class __$MovimientoCopyWithImpl<$Res>
    implements _$MovimientoCopyWith<$Res> {
  __$MovimientoCopyWithImpl(this._self, this._then);

  final _Movimiento _self;
  final $Res Function(_Movimiento) _then;

/// Create a copy of Movimiento
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tipo = null,Object? monto = null,Object? categoria = freezed,Object? deudaId = freezed,Object? gastoFijoId = freezed,Object? fecha = null,Object? periodoId = null,Object? uid = null,Object? nota = null,Object? fotoPath = freezed,Object? origen = null,Object? estado = null,Object? creadoEn = null,Object? editadoEn = freezed,Object? saldoAplicado = null,}) {
  return _then(_Movimiento(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as int,categoria: freezed == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String?,deudaId: freezed == deudaId ? _self.deudaId : deudaId // ignore: cast_nullable_to_non_nullable
as String?,gastoFijoId: freezed == gastoFijoId ? _self.gastoFijoId : gastoFijoId // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,periodoId: null == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nota: null == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String,fotoPath: freezed == fotoPath ? _self.fotoPath : fotoPath // ignore: cast_nullable_to_non_nullable
as String?,origen: null == origen ? _self.origen : origen // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,editadoEn: freezed == editadoEn ? _self.editadoEn : editadoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,saldoAplicado: null == saldoAplicado ? _self.saldoAplicado : saldoAplicado // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
