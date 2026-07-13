// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coach_tool_call.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoachToolCall {

 String get name; Map<String, Object?> get arguments;
/// Create a copy of CoachToolCall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachToolCallCopyWith<CoachToolCall> get copyWith => _$CoachToolCallCopyWithImpl<CoachToolCall>(this as CoachToolCall, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachToolCall&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.arguments, arguments));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(arguments));

@override
String toString() {
  return 'CoachToolCall(name: $name, arguments: $arguments)';
}


}

/// @nodoc
abstract mixin class $CoachToolCallCopyWith<$Res>  {
  factory $CoachToolCallCopyWith(CoachToolCall value, $Res Function(CoachToolCall) _then) = _$CoachToolCallCopyWithImpl;
@useResult
$Res call({
 String name, Map<String, Object?> arguments
});




}
/// @nodoc
class _$CoachToolCallCopyWithImpl<$Res>
    implements $CoachToolCallCopyWith<$Res> {
  _$CoachToolCallCopyWithImpl(this._self, this._then);

  final CoachToolCall _self;
  final $Res Function(CoachToolCall) _then;

/// Create a copy of CoachToolCall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? arguments = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self.arguments : arguments // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachToolCall].
extension CoachToolCallPatterns on CoachToolCall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachToolCall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachToolCall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachToolCall value)  $default,){
final _that = this;
switch (_that) {
case _CoachToolCall():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachToolCall value)?  $default,){
final _that = this;
switch (_that) {
case _CoachToolCall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  Map<String, Object?> arguments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachToolCall() when $default != null:
return $default(_that.name,_that.arguments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  Map<String, Object?> arguments)  $default,) {final _that = this;
switch (_that) {
case _CoachToolCall():
return $default(_that.name,_that.arguments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  Map<String, Object?> arguments)?  $default,) {final _that = this;
switch (_that) {
case _CoachToolCall() when $default != null:
return $default(_that.name,_that.arguments);case _:
  return null;

}
}

}

/// @nodoc


class _CoachToolCall implements CoachToolCall {
  const _CoachToolCall({required this.name, final  Map<String, Object?> arguments = const <String, Object?>{}}): _arguments = arguments;
  

@override final  String name;
 final  Map<String, Object?> _arguments;
@override@JsonKey() Map<String, Object?> get arguments {
  if (_arguments is EqualUnmodifiableMapView) return _arguments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_arguments);
}


/// Create a copy of CoachToolCall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachToolCallCopyWith<_CoachToolCall> get copyWith => __$CoachToolCallCopyWithImpl<_CoachToolCall>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachToolCall&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._arguments, _arguments));
}


@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_arguments));

@override
String toString() {
  return 'CoachToolCall(name: $name, arguments: $arguments)';
}


}

/// @nodoc
abstract mixin class _$CoachToolCallCopyWith<$Res> implements $CoachToolCallCopyWith<$Res> {
  factory _$CoachToolCallCopyWith(_CoachToolCall value, $Res Function(_CoachToolCall) _then) = __$CoachToolCallCopyWithImpl;
@override @useResult
$Res call({
 String name, Map<String, Object?> arguments
});




}
/// @nodoc
class __$CoachToolCallCopyWithImpl<$Res>
    implements _$CoachToolCallCopyWith<$Res> {
  __$CoachToolCallCopyWithImpl(this._self, this._then);

  final _CoachToolCall _self;
  final $Res Function(_CoachToolCall) _then;

/// Create a copy of CoachToolCall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? arguments = null,}) {
  return _then(_CoachToolCall(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self._arguments : arguments // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

/// @nodoc
mixin _$CoachToolResult {

 CoachToolCall get toolCall; bool get isError; String get promptSummary; String get displayLabel;
/// Create a copy of CoachToolResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachToolResultCopyWith<CoachToolResult> get copyWith => _$CoachToolResultCopyWithImpl<CoachToolResult>(this as CoachToolResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachToolResult&&(identical(other.toolCall, toolCall) || other.toolCall == toolCall)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.promptSummary, promptSummary) || other.promptSummary == promptSummary)&&(identical(other.displayLabel, displayLabel) || other.displayLabel == displayLabel));
}


@override
int get hashCode => Object.hash(runtimeType,toolCall,isError,promptSummary,displayLabel);

@override
String toString() {
  return 'CoachToolResult(toolCall: $toolCall, isError: $isError, promptSummary: $promptSummary, displayLabel: $displayLabel)';
}


}

/// @nodoc
abstract mixin class $CoachToolResultCopyWith<$Res>  {
  factory $CoachToolResultCopyWith(CoachToolResult value, $Res Function(CoachToolResult) _then) = _$CoachToolResultCopyWithImpl;
@useResult
$Res call({
 CoachToolCall toolCall, bool isError, String promptSummary, String displayLabel
});


$CoachToolCallCopyWith<$Res> get toolCall;

}
/// @nodoc
class _$CoachToolResultCopyWithImpl<$Res>
    implements $CoachToolResultCopyWith<$Res> {
  _$CoachToolResultCopyWithImpl(this._self, this._then);

  final CoachToolResult _self;
  final $Res Function(CoachToolResult) _then;

/// Create a copy of CoachToolResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? toolCall = null,Object? isError = null,Object? promptSummary = null,Object? displayLabel = null,}) {
  return _then(_self.copyWith(
toolCall: null == toolCall ? _self.toolCall : toolCall // ignore: cast_nullable_to_non_nullable
as CoachToolCall,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,promptSummary: null == promptSummary ? _self.promptSummary : promptSummary // ignore: cast_nullable_to_non_nullable
as String,displayLabel: null == displayLabel ? _self.displayLabel : displayLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CoachToolResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoachToolCallCopyWith<$Res> get toolCall {
  
  return $CoachToolCallCopyWith<$Res>(_self.toolCall, (value) {
    return _then(_self.copyWith(toolCall: value));
  });
}
}


/// Adds pattern-matching-related methods to [CoachToolResult].
extension CoachToolResultPatterns on CoachToolResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachToolResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachToolResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachToolResult value)  $default,){
final _that = this;
switch (_that) {
case _CoachToolResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachToolResult value)?  $default,){
final _that = this;
switch (_that) {
case _CoachToolResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CoachToolCall toolCall,  bool isError,  String promptSummary,  String displayLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachToolResult() when $default != null:
return $default(_that.toolCall,_that.isError,_that.promptSummary,_that.displayLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CoachToolCall toolCall,  bool isError,  String promptSummary,  String displayLabel)  $default,) {final _that = this;
switch (_that) {
case _CoachToolResult():
return $default(_that.toolCall,_that.isError,_that.promptSummary,_that.displayLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CoachToolCall toolCall,  bool isError,  String promptSummary,  String displayLabel)?  $default,) {final _that = this;
switch (_that) {
case _CoachToolResult() when $default != null:
return $default(_that.toolCall,_that.isError,_that.promptSummary,_that.displayLabel);case _:
  return null;

}
}

}

/// @nodoc


class _CoachToolResult implements CoachToolResult {
  const _CoachToolResult({required this.toolCall, required this.isError, required this.promptSummary, required this.displayLabel});
  

@override final  CoachToolCall toolCall;
@override final  bool isError;
@override final  String promptSummary;
@override final  String displayLabel;

/// Create a copy of CoachToolResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachToolResultCopyWith<_CoachToolResult> get copyWith => __$CoachToolResultCopyWithImpl<_CoachToolResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachToolResult&&(identical(other.toolCall, toolCall) || other.toolCall == toolCall)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.promptSummary, promptSummary) || other.promptSummary == promptSummary)&&(identical(other.displayLabel, displayLabel) || other.displayLabel == displayLabel));
}


@override
int get hashCode => Object.hash(runtimeType,toolCall,isError,promptSummary,displayLabel);

@override
String toString() {
  return 'CoachToolResult(toolCall: $toolCall, isError: $isError, promptSummary: $promptSummary, displayLabel: $displayLabel)';
}


}

/// @nodoc
abstract mixin class _$CoachToolResultCopyWith<$Res> implements $CoachToolResultCopyWith<$Res> {
  factory _$CoachToolResultCopyWith(_CoachToolResult value, $Res Function(_CoachToolResult) _then) = __$CoachToolResultCopyWithImpl;
@override @useResult
$Res call({
 CoachToolCall toolCall, bool isError, String promptSummary, String displayLabel
});


@override $CoachToolCallCopyWith<$Res> get toolCall;

}
/// @nodoc
class __$CoachToolResultCopyWithImpl<$Res>
    implements _$CoachToolResultCopyWith<$Res> {
  __$CoachToolResultCopyWithImpl(this._self, this._then);

  final _CoachToolResult _self;
  final $Res Function(_CoachToolResult) _then;

/// Create a copy of CoachToolResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? toolCall = null,Object? isError = null,Object? promptSummary = null,Object? displayLabel = null,}) {
  return _then(_CoachToolResult(
toolCall: null == toolCall ? _self.toolCall : toolCall // ignore: cast_nullable_to_non_nullable
as CoachToolCall,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,promptSummary: null == promptSummary ? _self.promptSummary : promptSummary // ignore: cast_nullable_to_non_nullable
as String,displayLabel: null == displayLabel ? _self.displayLabel : displayLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CoachToolResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoachToolCallCopyWith<$Res> get toolCall {
  
  return $CoachToolCallCopyWith<$Res>(_self.toolCall, (value) {
    return _then(_self.copyWith(toolCall: value));
  });
}
}

/// @nodoc
mixin _$CoachToolStep {

 String get toolName; CoachToolStatus get status; String? get displayLabel;
/// Create a copy of CoachToolStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachToolStepCopyWith<CoachToolStep> get copyWith => _$CoachToolStepCopyWithImpl<CoachToolStep>(this as CoachToolStep, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachToolStep&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.status, status) || other.status == status)&&(identical(other.displayLabel, displayLabel) || other.displayLabel == displayLabel));
}


@override
int get hashCode => Object.hash(runtimeType,toolName,status,displayLabel);

@override
String toString() {
  return 'CoachToolStep(toolName: $toolName, status: $status, displayLabel: $displayLabel)';
}


}

/// @nodoc
abstract mixin class $CoachToolStepCopyWith<$Res>  {
  factory $CoachToolStepCopyWith(CoachToolStep value, $Res Function(CoachToolStep) _then) = _$CoachToolStepCopyWithImpl;
@useResult
$Res call({
 String toolName, CoachToolStatus status, String? displayLabel
});




}
/// @nodoc
class _$CoachToolStepCopyWithImpl<$Res>
    implements $CoachToolStepCopyWith<$Res> {
  _$CoachToolStepCopyWithImpl(this._self, this._then);

  final CoachToolStep _self;
  final $Res Function(CoachToolStep) _then;

/// Create a copy of CoachToolStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? toolName = null,Object? status = null,Object? displayLabel = freezed,}) {
  return _then(_self.copyWith(
toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CoachToolStatus,displayLabel: freezed == displayLabel ? _self.displayLabel : displayLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachToolStep].
extension CoachToolStepPatterns on CoachToolStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachToolStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachToolStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachToolStep value)  $default,){
final _that = this;
switch (_that) {
case _CoachToolStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachToolStep value)?  $default,){
final _that = this;
switch (_that) {
case _CoachToolStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String toolName,  CoachToolStatus status,  String? displayLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachToolStep() when $default != null:
return $default(_that.toolName,_that.status,_that.displayLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String toolName,  CoachToolStatus status,  String? displayLabel)  $default,) {final _that = this;
switch (_that) {
case _CoachToolStep():
return $default(_that.toolName,_that.status,_that.displayLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String toolName,  CoachToolStatus status,  String? displayLabel)?  $default,) {final _that = this;
switch (_that) {
case _CoachToolStep() when $default != null:
return $default(_that.toolName,_that.status,_that.displayLabel);case _:
  return null;

}
}

}

/// @nodoc


class _CoachToolStep implements CoachToolStep {
  const _CoachToolStep({required this.toolName, required this.status, this.displayLabel});
  

@override final  String toolName;
@override final  CoachToolStatus status;
@override final  String? displayLabel;

/// Create a copy of CoachToolStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachToolStepCopyWith<_CoachToolStep> get copyWith => __$CoachToolStepCopyWithImpl<_CoachToolStep>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachToolStep&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.status, status) || other.status == status)&&(identical(other.displayLabel, displayLabel) || other.displayLabel == displayLabel));
}


@override
int get hashCode => Object.hash(runtimeType,toolName,status,displayLabel);

@override
String toString() {
  return 'CoachToolStep(toolName: $toolName, status: $status, displayLabel: $displayLabel)';
}


}

/// @nodoc
abstract mixin class _$CoachToolStepCopyWith<$Res> implements $CoachToolStepCopyWith<$Res> {
  factory _$CoachToolStepCopyWith(_CoachToolStep value, $Res Function(_CoachToolStep) _then) = __$CoachToolStepCopyWithImpl;
@override @useResult
$Res call({
 String toolName, CoachToolStatus status, String? displayLabel
});




}
/// @nodoc
class __$CoachToolStepCopyWithImpl<$Res>
    implements _$CoachToolStepCopyWith<$Res> {
  __$CoachToolStepCopyWithImpl(this._self, this._then);

  final _CoachToolStep _self;
  final $Res Function(_CoachToolStep) _then;

/// Create a copy of CoachToolStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? toolName = null,Object? status = null,Object? displayLabel = freezed,}) {
  return _then(_CoachToolStep(
toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CoachToolStatus,displayLabel: freezed == displayLabel ? _self.displayLabel : displayLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
