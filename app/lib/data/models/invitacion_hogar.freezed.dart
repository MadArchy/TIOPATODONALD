// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitacion_hogar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvitacionHogar {

 String get id; String get hogarId; String get codigo; String get creadaPor;@TimestampConverter() DateTime get creadaEn;@TimestampConverter() DateTime get expiraEn; bool get activa;
/// Create a copy of InvitacionHogar
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitacionHogarCopyWith<InvitacionHogar> get copyWith => _$InvitacionHogarCopyWithImpl<InvitacionHogar>(this as InvitacionHogar, _$identity);

  /// Serializes this InvitacionHogar to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InvitacionHogar;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitacionHogar&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.hogarId, _this.hogarId) || other.hogarId == _this.hogarId)&&(identical(other.codigo, _this.codigo) || other.codigo == _this.codigo)&&(identical(other.creadaPor, _this.creadaPor) || other.creadaPor == _this.creadaPor)&&(identical(other.creadaEn, _this.creadaEn) || other.creadaEn == _this.creadaEn)&&(identical(other.expiraEn, _this.expiraEn) || other.expiraEn == _this.expiraEn)&&(identical(other.activa, _this.activa) || other.activa == _this.activa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InvitacionHogar;
  return Object.hash(runtimeType,_this.id,_this.hogarId,_this.codigo,_this.creadaPor,_this.creadaEn,_this.expiraEn,_this.activa);
}

@override
String toString() {
  final _this = this as InvitacionHogar;
  return 'InvitacionHogar(id: ${_this.id}, hogarId: ${_this.hogarId}, codigo: ${_this.codigo}, creadaPor: ${_this.creadaPor}, creadaEn: ${_this.creadaEn}, expiraEn: ${_this.expiraEn}, activa: ${_this.activa})';
}


}

/// @nodoc
abstract mixin class $InvitacionHogarCopyWith<$Res>  {
  factory $InvitacionHogarCopyWith(InvitacionHogar value, $Res Function(InvitacionHogar) _then) = _$InvitacionHogarCopyWithImpl;
@useResult
$Res call({
 String id, String hogarId, String codigo, String creadaPor,@TimestampConverter() DateTime creadaEn,@TimestampConverter() DateTime expiraEn, bool activa
});




}
/// @nodoc
class _$InvitacionHogarCopyWithImpl<$Res>
    implements $InvitacionHogarCopyWith<$Res> {
  _$InvitacionHogarCopyWithImpl(this._self, this._then);

  final InvitacionHogar _self;
  final $Res Function(InvitacionHogar) _then;

/// Create a copy of InvitacionHogar
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hogarId = null,Object? codigo = null,Object? creadaPor = null,Object? creadaEn = null,Object? expiraEn = null,Object? activa = null,}) {
  return _then(InvitacionHogar(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hogarId: null == hogarId ? _self.hogarId : hogarId // ignore: cast_nullable_to_non_nullable
as String,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,creadaPor: null == creadaPor ? _self.creadaPor : creadaPor // ignore: cast_nullable_to_non_nullable
as String,creadaEn: null == creadaEn ? _self.creadaEn : creadaEn // ignore: cast_nullable_to_non_nullable
as DateTime,expiraEn: null == expiraEn ? _self.expiraEn : expiraEn // ignore: cast_nullable_to_non_nullable
as DateTime,activa: null == activa ? _self.activa : activa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitacionHogar].
extension InvitacionHogarPatterns on InvitacionHogar {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitacionHogar value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitacionHogar() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitacionHogar value)  $default,){
final _that = this;
switch (_that) {
case _InvitacionHogar():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitacionHogar value)?  $default,){
final _that = this;
switch (_that) {
case _InvitacionHogar() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String hogarId,  String codigo,  String creadaPor, @TimestampConverter()  DateTime creadaEn, @TimestampConverter()  DateTime expiraEn,  bool activa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitacionHogar() when $default != null:
return $default(_that.id,_that.hogarId,_that.codigo,_that.creadaPor,_that.creadaEn,_that.expiraEn,_that.activa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String hogarId,  String codigo,  String creadaPor, @TimestampConverter()  DateTime creadaEn, @TimestampConverter()  DateTime expiraEn,  bool activa)  $default,) {final _that = this;
switch (_that) {
case _InvitacionHogar():
return $default(_that.id,_that.hogarId,_that.codigo,_that.creadaPor,_that.creadaEn,_that.expiraEn,_that.activa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String hogarId,  String codigo,  String creadaPor, @TimestampConverter()  DateTime creadaEn, @TimestampConverter()  DateTime expiraEn,  bool activa)?  $default,) {final _that = this;
switch (_that) {
case _InvitacionHogar() when $default != null:
return $default(_that.id,_that.hogarId,_that.codigo,_that.creadaPor,_that.creadaEn,_that.expiraEn,_that.activa);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvitacionHogar implements InvitacionHogar {
  const _InvitacionHogar({required this.id, required this.hogarId, required this.codigo, required this.creadaPor, @TimestampConverter() required this.creadaEn, @TimestampConverter() required this.expiraEn, this.activa = true});
  factory _InvitacionHogar.fromJson(Map<String, dynamic> json) => _$InvitacionHogarFromJson(json);

@override final  String id;
@override final  String hogarId;
@override final  String codigo;
@override final  String creadaPor;
@override@TimestampConverter() final  DateTime creadaEn;
@override@TimestampConverter() final  DateTime expiraEn;
@override@JsonKey() final  bool activa;

/// Create a copy of InvitacionHogar
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitacionHogarCopyWith<_InvitacionHogar> get copyWith => __$InvitacionHogarCopyWithImpl<_InvitacionHogar>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitacionHogarToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitacionHogar&&(identical(other.id, id) || other.id == id)&&(identical(other.hogarId, hogarId) || other.hogarId == hogarId)&&(identical(other.codigo, codigo) || other.codigo == codigo)&&(identical(other.creadaPor, creadaPor) || other.creadaPor == creadaPor)&&(identical(other.creadaEn, creadaEn) || other.creadaEn == creadaEn)&&(identical(other.expiraEn, expiraEn) || other.expiraEn == expiraEn)&&(identical(other.activa, activa) || other.activa == activa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,hogarId,codigo,creadaPor,creadaEn,expiraEn,activa);
}

@override
String toString() {
    return 'InvitacionHogar(id: $id, hogarId: $hogarId, codigo: $codigo, creadaPor: $creadaPor, creadaEn: $creadaEn, expiraEn: $expiraEn, activa: $activa)';
}


}

/// @nodoc
abstract mixin class _$InvitacionHogarCopyWith<$Res> implements $InvitacionHogarCopyWith<$Res> {
  factory _$InvitacionHogarCopyWith(_InvitacionHogar value, $Res Function(_InvitacionHogar) _then) = __$InvitacionHogarCopyWithImpl;
@override @useResult
$Res call({
 String id, String hogarId, String codigo, String creadaPor,@TimestampConverter() DateTime creadaEn,@TimestampConverter() DateTime expiraEn, bool activa
});




}
/// @nodoc
class __$InvitacionHogarCopyWithImpl<$Res>
    implements _$InvitacionHogarCopyWith<$Res> {
  __$InvitacionHogarCopyWithImpl(this._self, this._then);

  final _InvitacionHogar _self;
  final $Res Function(_InvitacionHogar) _then;

/// Create a copy of InvitacionHogar
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hogarId = null,Object? codigo = null,Object? creadaPor = null,Object? creadaEn = null,Object? expiraEn = null,Object? activa = null,}) {
  return _then(_InvitacionHogar(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hogarId: null == hogarId ? _self.hogarId : hogarId // ignore: cast_nullable_to_non_nullable
as String,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,creadaPor: null == creadaPor ? _self.creadaPor : creadaPor // ignore: cast_nullable_to_non_nullable
as String,creadaEn: null == creadaEn ? _self.creadaEn : creadaEn // ignore: cast_nullable_to_non_nullable
as DateTime,expiraEn: null == expiraEn ? _self.expiraEn : expiraEn // ignore: cast_nullable_to_non_nullable
as DateTime,activa: null == activa ? _self.activa : activa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
