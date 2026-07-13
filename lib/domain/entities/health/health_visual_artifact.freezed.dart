// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_visual_artifact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HealthArtifactMeta {

 String get id; int get schemaVersion; String get title; String get explanation; DateTime get start; DateTime get end; FindingConfidence get confidence; List<String> get evidenceReferences; List<String> get limitations; bool get isInteractive;
/// Create a copy of HealthArtifactMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthArtifactMetaCopyWith<HealthArtifactMeta> get copyWith => _$HealthArtifactMetaCopyWithImpl<HealthArtifactMeta>(this as HealthArtifactMeta, _$identity);

  /// Serializes this HealthArtifactMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthArtifactMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.title, title) || other.title == title)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.evidenceReferences, evidenceReferences)&&const DeepCollectionEquality().equals(other.limitations, limitations)&&(identical(other.isInteractive, isInteractive) || other.isInteractive == isInteractive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,schemaVersion,title,explanation,start,end,confidence,const DeepCollectionEquality().hash(evidenceReferences),const DeepCollectionEquality().hash(limitations),isInteractive);

@override
String toString() {
  return 'HealthArtifactMeta(id: $id, schemaVersion: $schemaVersion, title: $title, explanation: $explanation, start: $start, end: $end, confidence: $confidence, evidenceReferences: $evidenceReferences, limitations: $limitations, isInteractive: $isInteractive)';
}


}

/// @nodoc
abstract mixin class $HealthArtifactMetaCopyWith<$Res>  {
  factory $HealthArtifactMetaCopyWith(HealthArtifactMeta value, $Res Function(HealthArtifactMeta) _then) = _$HealthArtifactMetaCopyWithImpl;
@useResult
$Res call({
 String id, int schemaVersion, String title, String explanation, DateTime start, DateTime end, FindingConfidence confidence, List<String> evidenceReferences, List<String> limitations, bool isInteractive
});




}
/// @nodoc
class _$HealthArtifactMetaCopyWithImpl<$Res>
    implements $HealthArtifactMetaCopyWith<$Res> {
  _$HealthArtifactMetaCopyWithImpl(this._self, this._then);

  final HealthArtifactMeta _self;
  final $Res Function(HealthArtifactMeta) _then;

/// Create a copy of HealthArtifactMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? schemaVersion = null,Object? title = null,Object? explanation = null,Object? start = null,Object? end = null,Object? confidence = null,Object? evidenceReferences = null,Object? limitations = null,Object? isInteractive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as FindingConfidence,evidenceReferences: null == evidenceReferences ? _self.evidenceReferences : evidenceReferences // ignore: cast_nullable_to_non_nullable
as List<String>,limitations: null == limitations ? _self.limitations : limitations // ignore: cast_nullable_to_non_nullable
as List<String>,isInteractive: null == isInteractive ? _self.isInteractive : isInteractive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthArtifactMeta].
extension HealthArtifactMetaPatterns on HealthArtifactMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthArtifactMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthArtifactMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthArtifactMeta value)  $default,){
final _that = this;
switch (_that) {
case _HealthArtifactMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthArtifactMeta value)?  $default,){
final _that = this;
switch (_that) {
case _HealthArtifactMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int schemaVersion,  String title,  String explanation,  DateTime start,  DateTime end,  FindingConfidence confidence,  List<String> evidenceReferences,  List<String> limitations,  bool isInteractive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthArtifactMeta() when $default != null:
return $default(_that.id,_that.schemaVersion,_that.title,_that.explanation,_that.start,_that.end,_that.confidence,_that.evidenceReferences,_that.limitations,_that.isInteractive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int schemaVersion,  String title,  String explanation,  DateTime start,  DateTime end,  FindingConfidence confidence,  List<String> evidenceReferences,  List<String> limitations,  bool isInteractive)  $default,) {final _that = this;
switch (_that) {
case _HealthArtifactMeta():
return $default(_that.id,_that.schemaVersion,_that.title,_that.explanation,_that.start,_that.end,_that.confidence,_that.evidenceReferences,_that.limitations,_that.isInteractive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int schemaVersion,  String title,  String explanation,  DateTime start,  DateTime end,  FindingConfidence confidence,  List<String> evidenceReferences,  List<String> limitations,  bool isInteractive)?  $default,) {final _that = this;
switch (_that) {
case _HealthArtifactMeta() when $default != null:
return $default(_that.id,_that.schemaVersion,_that.title,_that.explanation,_that.start,_that.end,_that.confidence,_that.evidenceReferences,_that.limitations,_that.isInteractive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthArtifactMeta implements HealthArtifactMeta {
  const _HealthArtifactMeta({required this.id, this.schemaVersion = 1, required this.title, required this.explanation, required this.start, required this.end, required this.confidence, final  List<String> evidenceReferences = const <String>[], final  List<String> limitations = const <String>[], this.isInteractive = true}): _evidenceReferences = evidenceReferences,_limitations = limitations;
  factory _HealthArtifactMeta.fromJson(Map<String, dynamic> json) => _$HealthArtifactMetaFromJson(json);

@override final  String id;
@override@JsonKey() final  int schemaVersion;
@override final  String title;
@override final  String explanation;
@override final  DateTime start;
@override final  DateTime end;
@override final  FindingConfidence confidence;
 final  List<String> _evidenceReferences;
@override@JsonKey() List<String> get evidenceReferences {
  if (_evidenceReferences is EqualUnmodifiableListView) return _evidenceReferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceReferences);
}

 final  List<String> _limitations;
@override@JsonKey() List<String> get limitations {
  if (_limitations is EqualUnmodifiableListView) return _limitations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_limitations);
}

@override@JsonKey() final  bool isInteractive;

/// Create a copy of HealthArtifactMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthArtifactMetaCopyWith<_HealthArtifactMeta> get copyWith => __$HealthArtifactMetaCopyWithImpl<_HealthArtifactMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthArtifactMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthArtifactMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.title, title) || other.title == title)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other._evidenceReferences, _evidenceReferences)&&const DeepCollectionEquality().equals(other._limitations, _limitations)&&(identical(other.isInteractive, isInteractive) || other.isInteractive == isInteractive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,schemaVersion,title,explanation,start,end,confidence,const DeepCollectionEquality().hash(_evidenceReferences),const DeepCollectionEquality().hash(_limitations),isInteractive);

@override
String toString() {
  return 'HealthArtifactMeta(id: $id, schemaVersion: $schemaVersion, title: $title, explanation: $explanation, start: $start, end: $end, confidence: $confidence, evidenceReferences: $evidenceReferences, limitations: $limitations, isInteractive: $isInteractive)';
}


}

/// @nodoc
abstract mixin class _$HealthArtifactMetaCopyWith<$Res> implements $HealthArtifactMetaCopyWith<$Res> {
  factory _$HealthArtifactMetaCopyWith(_HealthArtifactMeta value, $Res Function(_HealthArtifactMeta) _then) = __$HealthArtifactMetaCopyWithImpl;
@override @useResult
$Res call({
 String id, int schemaVersion, String title, String explanation, DateTime start, DateTime end, FindingConfidence confidence, List<String> evidenceReferences, List<String> limitations, bool isInteractive
});




}
/// @nodoc
class __$HealthArtifactMetaCopyWithImpl<$Res>
    implements _$HealthArtifactMetaCopyWith<$Res> {
  __$HealthArtifactMetaCopyWithImpl(this._self, this._then);

  final _HealthArtifactMeta _self;
  final $Res Function(_HealthArtifactMeta) _then;

/// Create a copy of HealthArtifactMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? schemaVersion = null,Object? title = null,Object? explanation = null,Object? start = null,Object? end = null,Object? confidence = null,Object? evidenceReferences = null,Object? limitations = null,Object? isInteractive = null,}) {
  return _then(_HealthArtifactMeta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as FindingConfidence,evidenceReferences: null == evidenceReferences ? _self._evidenceReferences : evidenceReferences // ignore: cast_nullable_to_non_nullable
as List<String>,limitations: null == limitations ? _self._limitations : limitations // ignore: cast_nullable_to_non_nullable
as List<String>,isInteractive: null == isInteractive ? _self.isInteractive : isInteractive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$HealthDataPoint {

 DateTime get date; double get value; String? get label;
/// Create a copy of HealthDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthDataPointCopyWith<HealthDataPoint> get copyWith => _$HealthDataPointCopyWithImpl<HealthDataPoint>(this as HealthDataPoint, _$identity);

  /// Serializes this HealthDataPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,value,label);

@override
String toString() {
  return 'HealthDataPoint(date: $date, value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class $HealthDataPointCopyWith<$Res>  {
  factory $HealthDataPointCopyWith(HealthDataPoint value, $Res Function(HealthDataPoint) _then) = _$HealthDataPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double value, String? label
});




}
/// @nodoc
class _$HealthDataPointCopyWithImpl<$Res>
    implements $HealthDataPointCopyWith<$Res> {
  _$HealthDataPointCopyWithImpl(this._self, this._then);

  final HealthDataPoint _self;
  final $Res Function(HealthDataPoint) _then;

/// Create a copy of HealthDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? value = null,Object? label = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthDataPoint].
extension HealthDataPointPatterns on HealthDataPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthDataPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _HealthDataPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _HealthDataPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double value,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthDataPoint() when $default != null:
return $default(_that.date,_that.value,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double value,  String? label)  $default,) {final _that = this;
switch (_that) {
case _HealthDataPoint():
return $default(_that.date,_that.value,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double value,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _HealthDataPoint() when $default != null:
return $default(_that.date,_that.value,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthDataPoint implements HealthDataPoint {
  const _HealthDataPoint({required this.date, required this.value, this.label});
  factory _HealthDataPoint.fromJson(Map<String, dynamic> json) => _$HealthDataPointFromJson(json);

@override final  DateTime date;
@override final  double value;
@override final  String? label;

/// Create a copy of HealthDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthDataPointCopyWith<_HealthDataPoint> get copyWith => __$HealthDataPointCopyWithImpl<_HealthDataPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthDataPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,value,label);

@override
String toString() {
  return 'HealthDataPoint(date: $date, value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class _$HealthDataPointCopyWith<$Res> implements $HealthDataPointCopyWith<$Res> {
  factory _$HealthDataPointCopyWith(_HealthDataPoint value, $Res Function(_HealthDataPoint) _then) = __$HealthDataPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double value, String? label
});




}
/// @nodoc
class __$HealthDataPointCopyWithImpl<$Res>
    implements _$HealthDataPointCopyWith<$Res> {
  __$HealthDataPointCopyWithImpl(this._self, this._then);

  final _HealthDataPoint _self;
  final $Res Function(_HealthDataPoint) _then;

/// Create a copy of HealthDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? value = null,Object? label = freezed,}) {
  return _then(_HealthDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$HealthSeries {

 String get id; String get label; HealthMetric get metric; String get unit; List<HealthDataPoint> get points; double? get baseline;
/// Create a copy of HealthSeries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthSeriesCopyWith<HealthSeries> get copyWith => _$HealthSeriesCopyWithImpl<HealthSeries>(this as HealthSeries, _$identity);

  /// Serializes this HealthSeries to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthSeries&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.metric, metric) || other.metric == metric)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.baseline, baseline) || other.baseline == baseline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,metric,unit,const DeepCollectionEquality().hash(points),baseline);

@override
String toString() {
  return 'HealthSeries(id: $id, label: $label, metric: $metric, unit: $unit, points: $points, baseline: $baseline)';
}


}

/// @nodoc
abstract mixin class $HealthSeriesCopyWith<$Res>  {
  factory $HealthSeriesCopyWith(HealthSeries value, $Res Function(HealthSeries) _then) = _$HealthSeriesCopyWithImpl;
@useResult
$Res call({
 String id, String label, HealthMetric metric, String unit, List<HealthDataPoint> points, double? baseline
});




}
/// @nodoc
class _$HealthSeriesCopyWithImpl<$Res>
    implements $HealthSeriesCopyWith<$Res> {
  _$HealthSeriesCopyWithImpl(this._self, this._then);

  final HealthSeries _self;
  final $Res Function(HealthSeries) _then;

/// Create a copy of HealthSeries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? metric = null,Object? unit = null,Object? points = null,Object? baseline = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as HealthMetric,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<HealthDataPoint>,baseline: freezed == baseline ? _self.baseline : baseline // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthSeries].
extension HealthSeriesPatterns on HealthSeries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthSeries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthSeries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthSeries value)  $default,){
final _that = this;
switch (_that) {
case _HealthSeries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthSeries value)?  $default,){
final _that = this;
switch (_that) {
case _HealthSeries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  HealthMetric metric,  String unit,  List<HealthDataPoint> points,  double? baseline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthSeries() when $default != null:
return $default(_that.id,_that.label,_that.metric,_that.unit,_that.points,_that.baseline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  HealthMetric metric,  String unit,  List<HealthDataPoint> points,  double? baseline)  $default,) {final _that = this;
switch (_that) {
case _HealthSeries():
return $default(_that.id,_that.label,_that.metric,_that.unit,_that.points,_that.baseline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  HealthMetric metric,  String unit,  List<HealthDataPoint> points,  double? baseline)?  $default,) {final _that = this;
switch (_that) {
case _HealthSeries() when $default != null:
return $default(_that.id,_that.label,_that.metric,_that.unit,_that.points,_that.baseline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthSeries implements HealthSeries {
  const _HealthSeries({required this.id, required this.label, required this.metric, required this.unit, required final  List<HealthDataPoint> points, this.baseline}): _points = points;
  factory _HealthSeries.fromJson(Map<String, dynamic> json) => _$HealthSeriesFromJson(json);

@override final  String id;
@override final  String label;
@override final  HealthMetric metric;
@override final  String unit;
 final  List<HealthDataPoint> _points;
@override List<HealthDataPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  double? baseline;

/// Create a copy of HealthSeries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthSeriesCopyWith<_HealthSeries> get copyWith => __$HealthSeriesCopyWithImpl<_HealthSeries>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthSeriesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthSeries&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.metric, metric) || other.metric == metric)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.baseline, baseline) || other.baseline == baseline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,metric,unit,const DeepCollectionEquality().hash(_points),baseline);

@override
String toString() {
  return 'HealthSeries(id: $id, label: $label, metric: $metric, unit: $unit, points: $points, baseline: $baseline)';
}


}

/// @nodoc
abstract mixin class _$HealthSeriesCopyWith<$Res> implements $HealthSeriesCopyWith<$Res> {
  factory _$HealthSeriesCopyWith(_HealthSeries value, $Res Function(_HealthSeries) _then) = __$HealthSeriesCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, HealthMetric metric, String unit, List<HealthDataPoint> points, double? baseline
});




}
/// @nodoc
class __$HealthSeriesCopyWithImpl<$Res>
    implements _$HealthSeriesCopyWith<$Res> {
  __$HealthSeriesCopyWithImpl(this._self, this._then);

  final _HealthSeries _self;
  final $Res Function(_HealthSeries) _then;

/// Create a copy of HealthSeries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? metric = null,Object? unit = null,Object? points = null,Object? baseline = freezed,}) {
  return _then(_HealthSeries(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as HealthMetric,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<HealthDataPoint>,baseline: freezed == baseline ? _self.baseline : baseline // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$HealthTableRow {

 String get label; List<String> get values;
/// Create a copy of HealthTableRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthTableRowCopyWith<HealthTableRow> get copyWith => _$HealthTableRowCopyWithImpl<HealthTableRow>(this as HealthTableRow, _$identity);

  /// Serializes this HealthTableRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthTableRow&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.values, values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,const DeepCollectionEquality().hash(values));

@override
String toString() {
  return 'HealthTableRow(label: $label, values: $values)';
}


}

/// @nodoc
abstract mixin class $HealthTableRowCopyWith<$Res>  {
  factory $HealthTableRowCopyWith(HealthTableRow value, $Res Function(HealthTableRow) _then) = _$HealthTableRowCopyWithImpl;
@useResult
$Res call({
 String label, List<String> values
});




}
/// @nodoc
class _$HealthTableRowCopyWithImpl<$Res>
    implements $HealthTableRowCopyWith<$Res> {
  _$HealthTableRowCopyWithImpl(this._self, this._then);

  final HealthTableRow _self;
  final $Res Function(HealthTableRow) _then;

/// Create a copy of HealthTableRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? values = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthTableRow].
extension HealthTableRowPatterns on HealthTableRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthTableRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthTableRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthTableRow value)  $default,){
final _that = this;
switch (_that) {
case _HealthTableRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthTableRow value)?  $default,){
final _that = this;
switch (_that) {
case _HealthTableRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  List<String> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthTableRow() when $default != null:
return $default(_that.label,_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  List<String> values)  $default,) {final _that = this;
switch (_that) {
case _HealthTableRow():
return $default(_that.label,_that.values);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  List<String> values)?  $default,) {final _that = this;
switch (_that) {
case _HealthTableRow() when $default != null:
return $default(_that.label,_that.values);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthTableRow implements HealthTableRow {
  const _HealthTableRow({required this.label, required final  List<String> values}): _values = values;
  factory _HealthTableRow.fromJson(Map<String, dynamic> json) => _$HealthTableRowFromJson(json);

@override final  String label;
 final  List<String> _values;
@override List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of HealthTableRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthTableRowCopyWith<_HealthTableRow> get copyWith => __$HealthTableRowCopyWithImpl<_HealthTableRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthTableRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthTableRow&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other._values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'HealthTableRow(label: $label, values: $values)';
}


}

/// @nodoc
abstract mixin class _$HealthTableRowCopyWith<$Res> implements $HealthTableRowCopyWith<$Res> {
  factory _$HealthTableRowCopyWith(_HealthTableRow value, $Res Function(_HealthTableRow) _then) = __$HealthTableRowCopyWithImpl;
@override @useResult
$Res call({
 String label, List<String> values
});




}
/// @nodoc
class __$HealthTableRowCopyWithImpl<$Res>
    implements _$HealthTableRowCopyWith<$Res> {
  __$HealthTableRowCopyWithImpl(this._self, this._then);

  final _HealthTableRow _self;
  final $Res Function(_HealthTableRow) _then;

/// Create a copy of HealthTableRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? values = null,}) {
  return _then(_HealthTableRow(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$HealthScatterPoint {

 DateTime get date; double get x; double get y;
/// Create a copy of HealthScatterPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthScatterPointCopyWith<HealthScatterPoint> get copyWith => _$HealthScatterPointCopyWithImpl<HealthScatterPoint>(this as HealthScatterPoint, _$identity);

  /// Serializes this HealthScatterPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthScatterPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,x,y);

@override
String toString() {
  return 'HealthScatterPoint(date: $date, x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $HealthScatterPointCopyWith<$Res>  {
  factory $HealthScatterPointCopyWith(HealthScatterPoint value, $Res Function(HealthScatterPoint) _then) = _$HealthScatterPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double x, double y
});




}
/// @nodoc
class _$HealthScatterPointCopyWithImpl<$Res>
    implements $HealthScatterPointCopyWith<$Res> {
  _$HealthScatterPointCopyWithImpl(this._self, this._then);

  final HealthScatterPoint _self;
  final $Res Function(HealthScatterPoint) _then;

/// Create a copy of HealthScatterPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? x = null,Object? y = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthScatterPoint].
extension HealthScatterPointPatterns on HealthScatterPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthScatterPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthScatterPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthScatterPoint value)  $default,){
final _that = this;
switch (_that) {
case _HealthScatterPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthScatterPoint value)?  $default,){
final _that = this;
switch (_that) {
case _HealthScatterPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double x,  double y)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthScatterPoint() when $default != null:
return $default(_that.date,_that.x,_that.y);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double x,  double y)  $default,) {final _that = this;
switch (_that) {
case _HealthScatterPoint():
return $default(_that.date,_that.x,_that.y);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double x,  double y)?  $default,) {final _that = this;
switch (_that) {
case _HealthScatterPoint() when $default != null:
return $default(_that.date,_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthScatterPoint implements HealthScatterPoint {
  const _HealthScatterPoint({required this.date, required this.x, required this.y});
  factory _HealthScatterPoint.fromJson(Map<String, dynamic> json) => _$HealthScatterPointFromJson(json);

@override final  DateTime date;
@override final  double x;
@override final  double y;

/// Create a copy of HealthScatterPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthScatterPointCopyWith<_HealthScatterPoint> get copyWith => __$HealthScatterPointCopyWithImpl<_HealthScatterPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthScatterPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthScatterPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,x,y);

@override
String toString() {
  return 'HealthScatterPoint(date: $date, x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$HealthScatterPointCopyWith<$Res> implements $HealthScatterPointCopyWith<$Res> {
  factory _$HealthScatterPointCopyWith(_HealthScatterPoint value, $Res Function(_HealthScatterPoint) _then) = __$HealthScatterPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double x, double y
});




}
/// @nodoc
class __$HealthScatterPointCopyWithImpl<$Res>
    implements _$HealthScatterPointCopyWith<$Res> {
  __$HealthScatterPointCopyWithImpl(this._self, this._then);

  final _HealthScatterPoint _self;
  final $Res Function(_HealthScatterPoint) _then;

/// Create a copy of HealthScatterPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? x = null,Object? y = null,}) {
  return _then(_HealthScatterPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$HealthTimelineEvent {

 DateTime get date; String get title; String get detail;
/// Create a copy of HealthTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthTimelineEventCopyWith<HealthTimelineEvent> get copyWith => _$HealthTimelineEventCopyWithImpl<HealthTimelineEvent>(this as HealthTimelineEvent, _$identity);

  /// Serializes this HealthTimelineEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthTimelineEvent&&(identical(other.date, date) || other.date == date)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,title,detail);

@override
String toString() {
  return 'HealthTimelineEvent(date: $date, title: $title, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $HealthTimelineEventCopyWith<$Res>  {
  factory $HealthTimelineEventCopyWith(HealthTimelineEvent value, $Res Function(HealthTimelineEvent) _then) = _$HealthTimelineEventCopyWithImpl;
@useResult
$Res call({
 DateTime date, String title, String detail
});




}
/// @nodoc
class _$HealthTimelineEventCopyWithImpl<$Res>
    implements $HealthTimelineEventCopyWith<$Res> {
  _$HealthTimelineEventCopyWithImpl(this._self, this._then);

  final HealthTimelineEvent _self;
  final $Res Function(HealthTimelineEvent) _then;

/// Create a copy of HealthTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? title = null,Object? detail = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthTimelineEvent].
extension HealthTimelineEventPatterns on HealthTimelineEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthTimelineEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthTimelineEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthTimelineEvent value)  $default,){
final _that = this;
switch (_that) {
case _HealthTimelineEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthTimelineEvent value)?  $default,){
final _that = this;
switch (_that) {
case _HealthTimelineEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  String title,  String detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthTimelineEvent() when $default != null:
return $default(_that.date,_that.title,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  String title,  String detail)  $default,) {final _that = this;
switch (_that) {
case _HealthTimelineEvent():
return $default(_that.date,_that.title,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  String title,  String detail)?  $default,) {final _that = this;
switch (_that) {
case _HealthTimelineEvent() when $default != null:
return $default(_that.date,_that.title,_that.detail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthTimelineEvent implements HealthTimelineEvent {
  const _HealthTimelineEvent({required this.date, required this.title, required this.detail});
  factory _HealthTimelineEvent.fromJson(Map<String, dynamic> json) => _$HealthTimelineEventFromJson(json);

@override final  DateTime date;
@override final  String title;
@override final  String detail;

/// Create a copy of HealthTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthTimelineEventCopyWith<_HealthTimelineEvent> get copyWith => __$HealthTimelineEventCopyWithImpl<_HealthTimelineEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthTimelineEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthTimelineEvent&&(identical(other.date, date) || other.date == date)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,title,detail);

@override
String toString() {
  return 'HealthTimelineEvent(date: $date, title: $title, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$HealthTimelineEventCopyWith<$Res> implements $HealthTimelineEventCopyWith<$Res> {
  factory _$HealthTimelineEventCopyWith(_HealthTimelineEvent value, $Res Function(_HealthTimelineEvent) _then) = __$HealthTimelineEventCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, String title, String detail
});




}
/// @nodoc
class __$HealthTimelineEventCopyWithImpl<$Res>
    implements _$HealthTimelineEventCopyWith<$Res> {
  __$HealthTimelineEventCopyWithImpl(this._self, this._then);

  final _HealthTimelineEvent _self;
  final $Res Function(_HealthTimelineEvent) _then;

/// Create a copy of HealthTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? title = null,Object? detail = null,}) {
  return _then(_HealthTimelineEvent(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$InfluenceEdge {

 String get from; String get to; String get label; double get strength;
/// Create a copy of InfluenceEdge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InfluenceEdgeCopyWith<InfluenceEdge> get copyWith => _$InfluenceEdgeCopyWithImpl<InfluenceEdge>(this as InfluenceEdge, _$identity);

  /// Serializes this InfluenceEdge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InfluenceEdge&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.label, label) || other.label == label)&&(identical(other.strength, strength) || other.strength == strength));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,label,strength);

@override
String toString() {
  return 'InfluenceEdge(from: $from, to: $to, label: $label, strength: $strength)';
}


}

/// @nodoc
abstract mixin class $InfluenceEdgeCopyWith<$Res>  {
  factory $InfluenceEdgeCopyWith(InfluenceEdge value, $Res Function(InfluenceEdge) _then) = _$InfluenceEdgeCopyWithImpl;
@useResult
$Res call({
 String from, String to, String label, double strength
});




}
/// @nodoc
class _$InfluenceEdgeCopyWithImpl<$Res>
    implements $InfluenceEdgeCopyWith<$Res> {
  _$InfluenceEdgeCopyWithImpl(this._self, this._then);

  final InfluenceEdge _self;
  final $Res Function(InfluenceEdge) _then;

/// Create a copy of InfluenceEdge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? label = null,Object? strength = null,}) {
  return _then(_self.copyWith(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,strength: null == strength ? _self.strength : strength // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [InfluenceEdge].
extension InfluenceEdgePatterns on InfluenceEdge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InfluenceEdge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InfluenceEdge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InfluenceEdge value)  $default,){
final _that = this;
switch (_that) {
case _InfluenceEdge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InfluenceEdge value)?  $default,){
final _that = this;
switch (_that) {
case _InfluenceEdge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String from,  String to,  String label,  double strength)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InfluenceEdge() when $default != null:
return $default(_that.from,_that.to,_that.label,_that.strength);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String from,  String to,  String label,  double strength)  $default,) {final _that = this;
switch (_that) {
case _InfluenceEdge():
return $default(_that.from,_that.to,_that.label,_that.strength);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String from,  String to,  String label,  double strength)?  $default,) {final _that = this;
switch (_that) {
case _InfluenceEdge() when $default != null:
return $default(_that.from,_that.to,_that.label,_that.strength);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InfluenceEdge implements InfluenceEdge {
  const _InfluenceEdge({required this.from, required this.to, required this.label, required this.strength});
  factory _InfluenceEdge.fromJson(Map<String, dynamic> json) => _$InfluenceEdgeFromJson(json);

@override final  String from;
@override final  String to;
@override final  String label;
@override final  double strength;

/// Create a copy of InfluenceEdge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InfluenceEdgeCopyWith<_InfluenceEdge> get copyWith => __$InfluenceEdgeCopyWithImpl<_InfluenceEdge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InfluenceEdgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InfluenceEdge&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.label, label) || other.label == label)&&(identical(other.strength, strength) || other.strength == strength));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,label,strength);

@override
String toString() {
  return 'InfluenceEdge(from: $from, to: $to, label: $label, strength: $strength)';
}


}

/// @nodoc
abstract mixin class _$InfluenceEdgeCopyWith<$Res> implements $InfluenceEdgeCopyWith<$Res> {
  factory _$InfluenceEdgeCopyWith(_InfluenceEdge value, $Res Function(_InfluenceEdge) _then) = __$InfluenceEdgeCopyWithImpl;
@override @useResult
$Res call({
 String from, String to, String label, double strength
});




}
/// @nodoc
class __$InfluenceEdgeCopyWithImpl<$Res>
    implements _$InfluenceEdgeCopyWith<$Res> {
  __$InfluenceEdgeCopyWithImpl(this._self, this._then);

  final _InfluenceEdge _self;
  final $Res Function(_InfluenceEdge) _then;

/// Create a copy of InfluenceEdge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? label = null,Object? strength = null,}) {
  return _then(_InfluenceEdge(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,strength: null == strength ? _self.strength : strength // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

HealthVisualArtifact _$HealthVisualArtifactFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'trend':
          return HealthTrendArtifact.fromJson(
            json
          );
                case 'comparisonTable':
          return HealthComparisonTableArtifact.fromJson(
            json
          );
                case 'correlationScatter':
          return HealthCorrelationScatterArtifact.fromJson(
            json
          );
                case 'calendarHeatmap':
          return HealthCalendarHeatmapArtifact.fromJson(
            json
          );
                case 'healthTimeline':
          return HealthTimelineArtifact.fromJson(
            json
          );
                case 'influenceMap':
          return HealthInfluenceMapArtifact.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'HealthVisualArtifact',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$HealthVisualArtifact {

 HealthArtifactMeta get meta;
/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthVisualArtifactCopyWith<HealthVisualArtifact> get copyWith => _$HealthVisualArtifactCopyWithImpl<HealthVisualArtifact>(this as HealthVisualArtifact, _$identity);

  /// Serializes this HealthVisualArtifact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthVisualArtifact&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meta);

@override
String toString() {
  return 'HealthVisualArtifact(meta: $meta)';
}


}

/// @nodoc
abstract mixin class $HealthVisualArtifactCopyWith<$Res>  {
  factory $HealthVisualArtifactCopyWith(HealthVisualArtifact value, $Res Function(HealthVisualArtifact) _then) = _$HealthVisualArtifactCopyWithImpl;
@useResult
$Res call({
 HealthArtifactMeta meta
});


$HealthArtifactMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$HealthVisualArtifactCopyWithImpl<$Res>
    implements $HealthVisualArtifactCopyWith<$Res> {
  _$HealthVisualArtifactCopyWithImpl(this._self, this._then);

  final HealthVisualArtifact _self;
  final $Res Function(HealthVisualArtifact) _then;

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? meta = null,}) {
  return _then(_self.copyWith(
meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as HealthArtifactMeta,
  ));
}
/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthArtifactMetaCopyWith<$Res> get meta {
  
  return $HealthArtifactMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [HealthVisualArtifact].
extension HealthVisualArtifactPatterns on HealthVisualArtifact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HealthTrendArtifact value)?  trend,TResult Function( HealthComparisonTableArtifact value)?  comparisonTable,TResult Function( HealthCorrelationScatterArtifact value)?  correlationScatter,TResult Function( HealthCalendarHeatmapArtifact value)?  calendarHeatmap,TResult Function( HealthTimelineArtifact value)?  healthTimeline,TResult Function( HealthInfluenceMapArtifact value)?  influenceMap,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HealthTrendArtifact() when trend != null:
return trend(_that);case HealthComparisonTableArtifact() when comparisonTable != null:
return comparisonTable(_that);case HealthCorrelationScatterArtifact() when correlationScatter != null:
return correlationScatter(_that);case HealthCalendarHeatmapArtifact() when calendarHeatmap != null:
return calendarHeatmap(_that);case HealthTimelineArtifact() when healthTimeline != null:
return healthTimeline(_that);case HealthInfluenceMapArtifact() when influenceMap != null:
return influenceMap(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HealthTrendArtifact value)  trend,required TResult Function( HealthComparisonTableArtifact value)  comparisonTable,required TResult Function( HealthCorrelationScatterArtifact value)  correlationScatter,required TResult Function( HealthCalendarHeatmapArtifact value)  calendarHeatmap,required TResult Function( HealthTimelineArtifact value)  healthTimeline,required TResult Function( HealthInfluenceMapArtifact value)  influenceMap,}){
final _that = this;
switch (_that) {
case HealthTrendArtifact():
return trend(_that);case HealthComparisonTableArtifact():
return comparisonTable(_that);case HealthCorrelationScatterArtifact():
return correlationScatter(_that);case HealthCalendarHeatmapArtifact():
return calendarHeatmap(_that);case HealthTimelineArtifact():
return healthTimeline(_that);case HealthInfluenceMapArtifact():
return influenceMap(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HealthTrendArtifact value)?  trend,TResult? Function( HealthComparisonTableArtifact value)?  comparisonTable,TResult? Function( HealthCorrelationScatterArtifact value)?  correlationScatter,TResult? Function( HealthCalendarHeatmapArtifact value)?  calendarHeatmap,TResult? Function( HealthTimelineArtifact value)?  healthTimeline,TResult? Function( HealthInfluenceMapArtifact value)?  influenceMap,}){
final _that = this;
switch (_that) {
case HealthTrendArtifact() when trend != null:
return trend(_that);case HealthComparisonTableArtifact() when comparisonTable != null:
return comparisonTable(_that);case HealthCorrelationScatterArtifact() when correlationScatter != null:
return correlationScatter(_that);case HealthCalendarHeatmapArtifact() when calendarHeatmap != null:
return calendarHeatmap(_that);case HealthTimelineArtifact() when healthTimeline != null:
return healthTimeline(_that);case HealthInfluenceMapArtifact() when influenceMap != null:
return influenceMap(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( HealthArtifactMeta meta,  List<HealthSeries> series)?  trend,TResult Function( HealthArtifactMeta meta,  List<String> columns,  List<HealthTableRow> rows)?  comparisonTable,TResult Function( HealthArtifactMeta meta,  HealthMetric xMetric,  HealthMetric yMetric,  List<HealthScatterPoint> points,  double correlation)?  correlationScatter,TResult Function( HealthArtifactMeta meta,  HealthMetric metric,  List<HealthDataPoint> points)?  calendarHeatmap,TResult Function( HealthArtifactMeta meta,  List<HealthTimelineEvent> events)?  healthTimeline,TResult Function( HealthArtifactMeta meta,  List<String> nodes,  List<InfluenceEdge> edges)?  influenceMap,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HealthTrendArtifact() when trend != null:
return trend(_that.meta,_that.series);case HealthComparisonTableArtifact() when comparisonTable != null:
return comparisonTable(_that.meta,_that.columns,_that.rows);case HealthCorrelationScatterArtifact() when correlationScatter != null:
return correlationScatter(_that.meta,_that.xMetric,_that.yMetric,_that.points,_that.correlation);case HealthCalendarHeatmapArtifact() when calendarHeatmap != null:
return calendarHeatmap(_that.meta,_that.metric,_that.points);case HealthTimelineArtifact() when healthTimeline != null:
return healthTimeline(_that.meta,_that.events);case HealthInfluenceMapArtifact() when influenceMap != null:
return influenceMap(_that.meta,_that.nodes,_that.edges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( HealthArtifactMeta meta,  List<HealthSeries> series)  trend,required TResult Function( HealthArtifactMeta meta,  List<String> columns,  List<HealthTableRow> rows)  comparisonTable,required TResult Function( HealthArtifactMeta meta,  HealthMetric xMetric,  HealthMetric yMetric,  List<HealthScatterPoint> points,  double correlation)  correlationScatter,required TResult Function( HealthArtifactMeta meta,  HealthMetric metric,  List<HealthDataPoint> points)  calendarHeatmap,required TResult Function( HealthArtifactMeta meta,  List<HealthTimelineEvent> events)  healthTimeline,required TResult Function( HealthArtifactMeta meta,  List<String> nodes,  List<InfluenceEdge> edges)  influenceMap,}) {final _that = this;
switch (_that) {
case HealthTrendArtifact():
return trend(_that.meta,_that.series);case HealthComparisonTableArtifact():
return comparisonTable(_that.meta,_that.columns,_that.rows);case HealthCorrelationScatterArtifact():
return correlationScatter(_that.meta,_that.xMetric,_that.yMetric,_that.points,_that.correlation);case HealthCalendarHeatmapArtifact():
return calendarHeatmap(_that.meta,_that.metric,_that.points);case HealthTimelineArtifact():
return healthTimeline(_that.meta,_that.events);case HealthInfluenceMapArtifact():
return influenceMap(_that.meta,_that.nodes,_that.edges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( HealthArtifactMeta meta,  List<HealthSeries> series)?  trend,TResult? Function( HealthArtifactMeta meta,  List<String> columns,  List<HealthTableRow> rows)?  comparisonTable,TResult? Function( HealthArtifactMeta meta,  HealthMetric xMetric,  HealthMetric yMetric,  List<HealthScatterPoint> points,  double correlation)?  correlationScatter,TResult? Function( HealthArtifactMeta meta,  HealthMetric metric,  List<HealthDataPoint> points)?  calendarHeatmap,TResult? Function( HealthArtifactMeta meta,  List<HealthTimelineEvent> events)?  healthTimeline,TResult? Function( HealthArtifactMeta meta,  List<String> nodes,  List<InfluenceEdge> edges)?  influenceMap,}) {final _that = this;
switch (_that) {
case HealthTrendArtifact() when trend != null:
return trend(_that.meta,_that.series);case HealthComparisonTableArtifact() when comparisonTable != null:
return comparisonTable(_that.meta,_that.columns,_that.rows);case HealthCorrelationScatterArtifact() when correlationScatter != null:
return correlationScatter(_that.meta,_that.xMetric,_that.yMetric,_that.points,_that.correlation);case HealthCalendarHeatmapArtifact() when calendarHeatmap != null:
return calendarHeatmap(_that.meta,_that.metric,_that.points);case HealthTimelineArtifact() when healthTimeline != null:
return healthTimeline(_that.meta,_that.events);case HealthInfluenceMapArtifact() when influenceMap != null:
return influenceMap(_that.meta,_that.nodes,_that.edges);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class HealthTrendArtifact implements HealthVisualArtifact {
  const HealthTrendArtifact({required this.meta, required final  List<HealthSeries> series, final  String? $type}): _series = series,$type = $type ?? 'trend';
  factory HealthTrendArtifact.fromJson(Map<String, dynamic> json) => _$HealthTrendArtifactFromJson(json);

@override final  HealthArtifactMeta meta;
 final  List<HealthSeries> _series;
 List<HealthSeries> get series {
  if (_series is EqualUnmodifiableListView) return _series;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_series);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthTrendArtifactCopyWith<HealthTrendArtifact> get copyWith => _$HealthTrendArtifactCopyWithImpl<HealthTrendArtifact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthTrendArtifactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthTrendArtifact&&(identical(other.meta, meta) || other.meta == meta)&&const DeepCollectionEquality().equals(other._series, _series));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meta,const DeepCollectionEquality().hash(_series));

@override
String toString() {
  return 'HealthVisualArtifact.trend(meta: $meta, series: $series)';
}


}

/// @nodoc
abstract mixin class $HealthTrendArtifactCopyWith<$Res> implements $HealthVisualArtifactCopyWith<$Res> {
  factory $HealthTrendArtifactCopyWith(HealthTrendArtifact value, $Res Function(HealthTrendArtifact) _then) = _$HealthTrendArtifactCopyWithImpl;
@override @useResult
$Res call({
 HealthArtifactMeta meta, List<HealthSeries> series
});


@override $HealthArtifactMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$HealthTrendArtifactCopyWithImpl<$Res>
    implements $HealthTrendArtifactCopyWith<$Res> {
  _$HealthTrendArtifactCopyWithImpl(this._self, this._then);

  final HealthTrendArtifact _self;
  final $Res Function(HealthTrendArtifact) _then;

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meta = null,Object? series = null,}) {
  return _then(HealthTrendArtifact(
meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as HealthArtifactMeta,series: null == series ? _self._series : series // ignore: cast_nullable_to_non_nullable
as List<HealthSeries>,
  ));
}

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthArtifactMetaCopyWith<$Res> get meta {
  
  return $HealthArtifactMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class HealthComparisonTableArtifact implements HealthVisualArtifact {
  const HealthComparisonTableArtifact({required this.meta, required final  List<String> columns, required final  List<HealthTableRow> rows, final  String? $type}): _columns = columns,_rows = rows,$type = $type ?? 'comparisonTable';
  factory HealthComparisonTableArtifact.fromJson(Map<String, dynamic> json) => _$HealthComparisonTableArtifactFromJson(json);

@override final  HealthArtifactMeta meta;
 final  List<String> _columns;
 List<String> get columns {
  if (_columns is EqualUnmodifiableListView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_columns);
}

 final  List<HealthTableRow> _rows;
 List<HealthTableRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthComparisonTableArtifactCopyWith<HealthComparisonTableArtifact> get copyWith => _$HealthComparisonTableArtifactCopyWithImpl<HealthComparisonTableArtifact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthComparisonTableArtifactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthComparisonTableArtifact&&(identical(other.meta, meta) || other.meta == meta)&&const DeepCollectionEquality().equals(other._columns, _columns)&&const DeepCollectionEquality().equals(other._rows, _rows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meta,const DeepCollectionEquality().hash(_columns),const DeepCollectionEquality().hash(_rows));

@override
String toString() {
  return 'HealthVisualArtifact.comparisonTable(meta: $meta, columns: $columns, rows: $rows)';
}


}

/// @nodoc
abstract mixin class $HealthComparisonTableArtifactCopyWith<$Res> implements $HealthVisualArtifactCopyWith<$Res> {
  factory $HealthComparisonTableArtifactCopyWith(HealthComparisonTableArtifact value, $Res Function(HealthComparisonTableArtifact) _then) = _$HealthComparisonTableArtifactCopyWithImpl;
@override @useResult
$Res call({
 HealthArtifactMeta meta, List<String> columns, List<HealthTableRow> rows
});


@override $HealthArtifactMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$HealthComparisonTableArtifactCopyWithImpl<$Res>
    implements $HealthComparisonTableArtifactCopyWith<$Res> {
  _$HealthComparisonTableArtifactCopyWithImpl(this._self, this._then);

  final HealthComparisonTableArtifact _self;
  final $Res Function(HealthComparisonTableArtifact) _then;

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meta = null,Object? columns = null,Object? rows = null,}) {
  return _then(HealthComparisonTableArtifact(
meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as HealthArtifactMeta,columns: null == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as List<String>,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<HealthTableRow>,
  ));
}

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthArtifactMetaCopyWith<$Res> get meta {
  
  return $HealthArtifactMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class HealthCorrelationScatterArtifact implements HealthVisualArtifact {
  const HealthCorrelationScatterArtifact({required this.meta, required this.xMetric, required this.yMetric, required final  List<HealthScatterPoint> points, required this.correlation, final  String? $type}): _points = points,$type = $type ?? 'correlationScatter';
  factory HealthCorrelationScatterArtifact.fromJson(Map<String, dynamic> json) => _$HealthCorrelationScatterArtifactFromJson(json);

@override final  HealthArtifactMeta meta;
 final  HealthMetric xMetric;
 final  HealthMetric yMetric;
 final  List<HealthScatterPoint> _points;
 List<HealthScatterPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

 final  double correlation;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthCorrelationScatterArtifactCopyWith<HealthCorrelationScatterArtifact> get copyWith => _$HealthCorrelationScatterArtifactCopyWithImpl<HealthCorrelationScatterArtifact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthCorrelationScatterArtifactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthCorrelationScatterArtifact&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.xMetric, xMetric) || other.xMetric == xMetric)&&(identical(other.yMetric, yMetric) || other.yMetric == yMetric)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.correlation, correlation) || other.correlation == correlation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meta,xMetric,yMetric,const DeepCollectionEquality().hash(_points),correlation);

@override
String toString() {
  return 'HealthVisualArtifact.correlationScatter(meta: $meta, xMetric: $xMetric, yMetric: $yMetric, points: $points, correlation: $correlation)';
}


}

/// @nodoc
abstract mixin class $HealthCorrelationScatterArtifactCopyWith<$Res> implements $HealthVisualArtifactCopyWith<$Res> {
  factory $HealthCorrelationScatterArtifactCopyWith(HealthCorrelationScatterArtifact value, $Res Function(HealthCorrelationScatterArtifact) _then) = _$HealthCorrelationScatterArtifactCopyWithImpl;
@override @useResult
$Res call({
 HealthArtifactMeta meta, HealthMetric xMetric, HealthMetric yMetric, List<HealthScatterPoint> points, double correlation
});


@override $HealthArtifactMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$HealthCorrelationScatterArtifactCopyWithImpl<$Res>
    implements $HealthCorrelationScatterArtifactCopyWith<$Res> {
  _$HealthCorrelationScatterArtifactCopyWithImpl(this._self, this._then);

  final HealthCorrelationScatterArtifact _self;
  final $Res Function(HealthCorrelationScatterArtifact) _then;

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meta = null,Object? xMetric = null,Object? yMetric = null,Object? points = null,Object? correlation = null,}) {
  return _then(HealthCorrelationScatterArtifact(
meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as HealthArtifactMeta,xMetric: null == xMetric ? _self.xMetric : xMetric // ignore: cast_nullable_to_non_nullable
as HealthMetric,yMetric: null == yMetric ? _self.yMetric : yMetric // ignore: cast_nullable_to_non_nullable
as HealthMetric,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<HealthScatterPoint>,correlation: null == correlation ? _self.correlation : correlation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthArtifactMetaCopyWith<$Res> get meta {
  
  return $HealthArtifactMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class HealthCalendarHeatmapArtifact implements HealthVisualArtifact {
  const HealthCalendarHeatmapArtifact({required this.meta, required this.metric, required final  List<HealthDataPoint> points, final  String? $type}): _points = points,$type = $type ?? 'calendarHeatmap';
  factory HealthCalendarHeatmapArtifact.fromJson(Map<String, dynamic> json) => _$HealthCalendarHeatmapArtifactFromJson(json);

@override final  HealthArtifactMeta meta;
 final  HealthMetric metric;
 final  List<HealthDataPoint> _points;
 List<HealthDataPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthCalendarHeatmapArtifactCopyWith<HealthCalendarHeatmapArtifact> get copyWith => _$HealthCalendarHeatmapArtifactCopyWithImpl<HealthCalendarHeatmapArtifact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthCalendarHeatmapArtifactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthCalendarHeatmapArtifact&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.metric, metric) || other.metric == metric)&&const DeepCollectionEquality().equals(other._points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meta,metric,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'HealthVisualArtifact.calendarHeatmap(meta: $meta, metric: $metric, points: $points)';
}


}

/// @nodoc
abstract mixin class $HealthCalendarHeatmapArtifactCopyWith<$Res> implements $HealthVisualArtifactCopyWith<$Res> {
  factory $HealthCalendarHeatmapArtifactCopyWith(HealthCalendarHeatmapArtifact value, $Res Function(HealthCalendarHeatmapArtifact) _then) = _$HealthCalendarHeatmapArtifactCopyWithImpl;
@override @useResult
$Res call({
 HealthArtifactMeta meta, HealthMetric metric, List<HealthDataPoint> points
});


@override $HealthArtifactMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$HealthCalendarHeatmapArtifactCopyWithImpl<$Res>
    implements $HealthCalendarHeatmapArtifactCopyWith<$Res> {
  _$HealthCalendarHeatmapArtifactCopyWithImpl(this._self, this._then);

  final HealthCalendarHeatmapArtifact _self;
  final $Res Function(HealthCalendarHeatmapArtifact) _then;

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meta = null,Object? metric = null,Object? points = null,}) {
  return _then(HealthCalendarHeatmapArtifact(
meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as HealthArtifactMeta,metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as HealthMetric,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<HealthDataPoint>,
  ));
}

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthArtifactMetaCopyWith<$Res> get meta {
  
  return $HealthArtifactMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class HealthTimelineArtifact implements HealthVisualArtifact {
  const HealthTimelineArtifact({required this.meta, required final  List<HealthTimelineEvent> events, final  String? $type}): _events = events,$type = $type ?? 'healthTimeline';
  factory HealthTimelineArtifact.fromJson(Map<String, dynamic> json) => _$HealthTimelineArtifactFromJson(json);

@override final  HealthArtifactMeta meta;
 final  List<HealthTimelineEvent> _events;
 List<HealthTimelineEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthTimelineArtifactCopyWith<HealthTimelineArtifact> get copyWith => _$HealthTimelineArtifactCopyWithImpl<HealthTimelineArtifact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthTimelineArtifactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthTimelineArtifact&&(identical(other.meta, meta) || other.meta == meta)&&const DeepCollectionEquality().equals(other._events, _events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meta,const DeepCollectionEquality().hash(_events));

@override
String toString() {
  return 'HealthVisualArtifact.healthTimeline(meta: $meta, events: $events)';
}


}

/// @nodoc
abstract mixin class $HealthTimelineArtifactCopyWith<$Res> implements $HealthVisualArtifactCopyWith<$Res> {
  factory $HealthTimelineArtifactCopyWith(HealthTimelineArtifact value, $Res Function(HealthTimelineArtifact) _then) = _$HealthTimelineArtifactCopyWithImpl;
@override @useResult
$Res call({
 HealthArtifactMeta meta, List<HealthTimelineEvent> events
});


@override $HealthArtifactMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$HealthTimelineArtifactCopyWithImpl<$Res>
    implements $HealthTimelineArtifactCopyWith<$Res> {
  _$HealthTimelineArtifactCopyWithImpl(this._self, this._then);

  final HealthTimelineArtifact _self;
  final $Res Function(HealthTimelineArtifact) _then;

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meta = null,Object? events = null,}) {
  return _then(HealthTimelineArtifact(
meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as HealthArtifactMeta,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<HealthTimelineEvent>,
  ));
}

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthArtifactMetaCopyWith<$Res> get meta {
  
  return $HealthArtifactMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class HealthInfluenceMapArtifact implements HealthVisualArtifact {
  const HealthInfluenceMapArtifact({required this.meta, required final  List<String> nodes, required final  List<InfluenceEdge> edges, final  String? $type}): _nodes = nodes,_edges = edges,$type = $type ?? 'influenceMap';
  factory HealthInfluenceMapArtifact.fromJson(Map<String, dynamic> json) => _$HealthInfluenceMapArtifactFromJson(json);

@override final  HealthArtifactMeta meta;
 final  List<String> _nodes;
 List<String> get nodes {
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodes);
}

 final  List<InfluenceEdge> _edges;
 List<InfluenceEdge> get edges {
  if (_edges is EqualUnmodifiableListView) return _edges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_edges);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthInfluenceMapArtifactCopyWith<HealthInfluenceMapArtifact> get copyWith => _$HealthInfluenceMapArtifactCopyWithImpl<HealthInfluenceMapArtifact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthInfluenceMapArtifactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthInfluenceMapArtifact&&(identical(other.meta, meta) || other.meta == meta)&&const DeepCollectionEquality().equals(other._nodes, _nodes)&&const DeepCollectionEquality().equals(other._edges, _edges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meta,const DeepCollectionEquality().hash(_nodes),const DeepCollectionEquality().hash(_edges));

@override
String toString() {
  return 'HealthVisualArtifact.influenceMap(meta: $meta, nodes: $nodes, edges: $edges)';
}


}

/// @nodoc
abstract mixin class $HealthInfluenceMapArtifactCopyWith<$Res> implements $HealthVisualArtifactCopyWith<$Res> {
  factory $HealthInfluenceMapArtifactCopyWith(HealthInfluenceMapArtifact value, $Res Function(HealthInfluenceMapArtifact) _then) = _$HealthInfluenceMapArtifactCopyWithImpl;
@override @useResult
$Res call({
 HealthArtifactMeta meta, List<String> nodes, List<InfluenceEdge> edges
});


@override $HealthArtifactMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$HealthInfluenceMapArtifactCopyWithImpl<$Res>
    implements $HealthInfluenceMapArtifactCopyWith<$Res> {
  _$HealthInfluenceMapArtifactCopyWithImpl(this._self, this._then);

  final HealthInfluenceMapArtifact _self;
  final $Res Function(HealthInfluenceMapArtifact) _then;

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meta = null,Object? nodes = null,Object? edges = null,}) {
  return _then(HealthInfluenceMapArtifact(
meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as HealthArtifactMeta,nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<String>,edges: null == edges ? _self._edges : edges // ignore: cast_nullable_to_non_nullable
as List<InfluenceEdge>,
  ));
}

/// Create a copy of HealthVisualArtifact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthArtifactMetaCopyWith<$Res> get meta {
  
  return $HealthArtifactMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

// dart format on
