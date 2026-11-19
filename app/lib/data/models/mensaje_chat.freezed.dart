// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mensaje_chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MensajeChat {

 String get id; String get rol; String get texto; Intencion? get intencion; String get estado;@TimestampConverter() DateTime get fecha;
/// Create a copy of MensajeChat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MensajeChatCopyWith<MensajeChat> get copyWith => _$MensajeChatCopyWithImpl<MensajeChat>(this as MensajeChat, _$identity);

  /// Serializes this MensajeChat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MensajeChat;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MensajeChat&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.rol, _this.rol) || other.rol == _this.rol)&&(identical(other.texto, _this.texto) || other.texto == _this.texto)&&(identical(other.intencion, _this.intencion) || other.intencion == _this.intencion)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.fecha, _this.fecha) || other.fecha == _this.fecha));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MensajeChat;
  return Object.hash(runtimeType,_this.id,_this.rol,_this.texto,_this.intencion,_this.estado,_this.fecha);
}

@override
String toString() {
  final _this = this as MensajeChat;
  return 'MensajeChat(id: ${_this.id}, rol: ${_this.rol}, texto: ${_this.texto}, intencion: ${_this.intencion}, estado: ${_this.estado}, fecha: ${_this.fecha})';
}


}

/// @nodoc
abstract mixin class $MensajeChatCopyWith<$Res>  {
  factory $MensajeChatCopyWith(MensajeChat value, $Res Function(MensajeChat) _then) = _$MensajeChatCopyWithImpl;
@useResult
$Res call({
 String id, String rol, String texto, Intencion? intencion, String estado,@TimestampConverter() DateTime fecha
});


$IntencionCopyWith<$Res>? get intencion;

}
/// @nodoc
class _$MensajeChatCopyWithImpl<$Res>
    implements $MensajeChatCopyWith<$Res> {
  _$MensajeChatCopyWithImpl(this._self, this._then);

  final MensajeChat _self;
  final $Res Function(MensajeChat) _then;

/// Create a copy of MensajeChat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rol = null,Object? texto = null,Object? intencion = freezed,Object? estado = null,Object? fecha = null,}) {
  return _then(MensajeChat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as String,texto: null == texto ? _self.texto : texto // ignore: cast_nullable_to_non_nullable
as String,intencion: freezed == intencion ? _self.intencion : intencion // ignore: cast_nullable_to_non_nullable
as Intencion?,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of MensajeChat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IntencionCopyWith<$Res>? get intencion {
    if (_self.intencion == null) {
    return null;
  }

  return $IntencionCopyWith<$Res>(_self.intencion!, (value) {
    return _then(_self.copyWith(intencion: value));
  });
}
}


/// Adds pattern-matching-related methods to [MensajeChat].
extension MensajeChatPatterns on MensajeChat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MensajeChat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MensajeChat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MensajeChat value)  $default,){
final _that = this;
switch (_that) {
case _MensajeChat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MensajeChat value)?  $default,){
final _that = this;
switch (_that) {
case _MensajeChat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rol,  String texto,  Intencion? intencion,  String estado, @TimestampConverter()  DateTime fecha)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MensajeChat() when $default != null:
return $default(_that.id,_that.rol,_that.texto,_that.intencion,_that.estado,_that.fecha);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rol,  String texto,  Intencion? intencion,  String estado, @TimestampConverter()  DateTime fecha)  $default,) {final _that = this;
switch (_that) {
case _MensajeChat():
return $default(_that.id,_that.rol,_that.texto,_that.intencion,_that.estado,_that.fecha);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rol,  String texto,  Intencion? intencion,  String estado, @TimestampConverter()  DateTime fecha)?  $default,) {final _that = this;
switch (_that) {
case _MensajeChat() when $default != null:
return $default(_that.id,_that.rol,_that.texto,_that.intencion,_that.estado,_that.fecha);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MensajeChat implements MensajeChat {
  const _MensajeChat({required this.id, required this.rol, required this.texto, this.intencion, this.estado = 'confirmado', @TimestampConverter() required this.fecha});
  factory _MensajeChat.fromJson(Map<String, dynamic> json) => _$MensajeChatFromJson(json);

@override final  String id;
@override final  String rol;
@override final  String texto;
@override final  Intencion? intencion;
@override@JsonKey() final  String estado;
@override@TimestampConverter() final  DateTime fecha;

/// Create a copy of MensajeChat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MensajeChatCopyWith<_MensajeChat> get copyWith => __$MensajeChatCopyWithImpl<_MensajeChat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MensajeChatToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MensajeChat&&(identical(other.id, id) || other.id == id)&&(identical(other.rol, rol) || other.rol == rol)&&(identical(other.texto, texto) || other.texto == texto)&&(identical(other.intencion, intencion) || other.intencion == intencion)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.fecha, fecha) || other.fecha == fecha));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,rol,texto,intencion,estado,fecha);
}

@override
String toString() {
    return 'MensajeChat(id: $id, rol: $rol, texto: $texto, intencion: $intencion, estado: $estado, fecha: $fecha)';
}


}

/// @nodoc
abstract mixin class _$MensajeChatCopyWith<$Res> implements $MensajeChatCopyWith<$Res> {
  factory _$MensajeChatCopyWith(_MensajeChat value, $Res Function(_MensajeChat) _then) = __$MensajeChatCopyWithImpl;
@override @useResult
$Res call({
 String id, String rol, String texto, Intencion? intencion, String estado,@TimestampConverter() DateTime fecha
});


@override $IntencionCopyWith<$Res>? get intencion;

}
/// @nodoc
class __$MensajeChatCopyWithImpl<$Res>
    implements _$MensajeChatCopyWith<$Res> {
  __$MensajeChatCopyWithImpl(this._self, this._then);

  final _MensajeChat _self;
  final $Res Function(_MensajeChat) _then;

/// Create a copy of MensajeChat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rol = null,Object? texto = null,Object? intencion = freezed,Object? estado = null,Object? fecha = null,}) {
  return _then(_MensajeChat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as String,texto: null == texto ? _self.texto : texto // ignore: cast_nullable_to_non_nullable
as String,intencion: freezed == intencion ? _self.intencion : intencion // ignore: cast_nullable_to_non_nullable
as Intencion?,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of MensajeChat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IntencionCopyWith<$Res>? get intencion {
    if (_self.intencion == null) {
    return null;
  }

  return $IntencionCopyWith<$Res>(_self.intencion!, (value) {
    return _then(_self.copyWith(intencion: value));
  });
}
}

// dart format on
