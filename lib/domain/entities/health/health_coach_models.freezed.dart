// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_coach_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HealthCheckIn {

 DateTime get date; int get energy; int get mood; int get stress; int get soreness; bool get feelingUnwell; String? get note;
/// Create a copy of HealthCheckIn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthCheckInCopyWith<HealthCheckIn> get copyWith => _$HealthCheckInCopyWithImpl<HealthCheckIn>(this as HealthCheckIn, _$identity);

  /// Serializes this HealthCheckIn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthCheckIn&&(identical(other.date, date) || other.date == date)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.stress, stress) || other.stress == stress)&&(identical(other.soreness, soreness) || other.soreness == soreness)&&(identical(other.feelingUnwell, feelingUnwell) || other.feelingUnwell == feelingUnwell)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,energy,mood,stress,soreness,feelingUnwell,note);

@override
String toString() {
  return 'HealthCheckIn(date: $date, energy: $energy, mood: $mood, stress: $stress, soreness: $soreness, feelingUnwell: $feelingUnwell, note: $note)';
}


}

/// @nodoc
abstract mixin class $HealthCheckInCopyWith<$Res>  {
  factory $HealthCheckInCopyWith(HealthCheckIn value, $Res Function(HealthCheckIn) _then) = _$HealthCheckInCopyWithImpl;
@useResult
$Res call({
 DateTime date, int energy, int mood, int stress, int soreness, bool feelingUnwell, String? note
});




}
/// @nodoc
class _$HealthCheckInCopyWithImpl<$Res>
    implements $HealthCheckInCopyWith<$Res> {
  _$HealthCheckInCopyWithImpl(this._self, this._then);

  final HealthCheckIn _self;
  final $Res Function(HealthCheckIn) _then;

/// Create a copy of HealthCheckIn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? energy = null,Object? mood = null,Object? stress = null,Object? soreness = null,Object? feelingUnwell = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as int,mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as int,stress: null == stress ? _self.stress : stress // ignore: cast_nullable_to_non_nullable
as int,soreness: null == soreness ? _self.soreness : soreness // ignore: cast_nullable_to_non_nullable
as int,feelingUnwell: null == feelingUnwell ? _self.feelingUnwell : feelingUnwell // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthCheckIn].
extension HealthCheckInPatterns on HealthCheckIn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthCheckIn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthCheckIn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthCheckIn value)  $default,){
final _that = this;
switch (_that) {
case _HealthCheckIn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthCheckIn value)?  $default,){
final _that = this;
switch (_that) {
case _HealthCheckIn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int energy,  int mood,  int stress,  int soreness,  bool feelingUnwell,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthCheckIn() when $default != null:
return $default(_that.date,_that.energy,_that.mood,_that.stress,_that.soreness,_that.feelingUnwell,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int energy,  int mood,  int stress,  int soreness,  bool feelingUnwell,  String? note)  $default,) {final _that = this;
switch (_that) {
case _HealthCheckIn():
return $default(_that.date,_that.energy,_that.mood,_that.stress,_that.soreness,_that.feelingUnwell,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int energy,  int mood,  int stress,  int soreness,  bool feelingUnwell,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _HealthCheckIn() when $default != null:
return $default(_that.date,_that.energy,_that.mood,_that.stress,_that.soreness,_that.feelingUnwell,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthCheckIn implements HealthCheckIn {
  const _HealthCheckIn({required this.date, required this.energy, required this.mood, required this.stress, required this.soreness, this.feelingUnwell = false, this.note});
  factory _HealthCheckIn.fromJson(Map<String, dynamic> json) => _$HealthCheckInFromJson(json);

@override final  DateTime date;
@override final  int energy;
@override final  int mood;
@override final  int stress;
@override final  int soreness;
@override@JsonKey() final  bool feelingUnwell;
@override final  String? note;

/// Create a copy of HealthCheckIn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthCheckInCopyWith<_HealthCheckIn> get copyWith => __$HealthCheckInCopyWithImpl<_HealthCheckIn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthCheckInToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthCheckIn&&(identical(other.date, date) || other.date == date)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.stress, stress) || other.stress == stress)&&(identical(other.soreness, soreness) || other.soreness == soreness)&&(identical(other.feelingUnwell, feelingUnwell) || other.feelingUnwell == feelingUnwell)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,energy,mood,stress,soreness,feelingUnwell,note);

@override
String toString() {
  return 'HealthCheckIn(date: $date, energy: $energy, mood: $mood, stress: $stress, soreness: $soreness, feelingUnwell: $feelingUnwell, note: $note)';
}


}

/// @nodoc
abstract mixin class _$HealthCheckInCopyWith<$Res> implements $HealthCheckInCopyWith<$Res> {
  factory _$HealthCheckInCopyWith(_HealthCheckIn value, $Res Function(_HealthCheckIn) _then) = __$HealthCheckInCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int energy, int mood, int stress, int soreness, bool feelingUnwell, String? note
});




}
/// @nodoc
class __$HealthCheckInCopyWithImpl<$Res>
    implements _$HealthCheckInCopyWith<$Res> {
  __$HealthCheckInCopyWithImpl(this._self, this._then);

  final _HealthCheckIn _self;
  final $Res Function(_HealthCheckIn) _then;

/// Create a copy of HealthCheckIn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? energy = null,Object? mood = null,Object? stress = null,Object? soreness = null,Object? feelingUnwell = null,Object? note = freezed,}) {
  return _then(_HealthCheckIn(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as int,mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as int,stress: null == stress ? _self.stress : stress // ignore: cast_nullable_to_non_nullable
as int,soreness: null == soreness ? _self.soreness : soreness // ignore: cast_nullable_to_non_nullable
as int,feelingUnwell: null == feelingUnwell ? _self.feelingUnwell : feelingUnwell // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PersonalBaseline {

 HealthMetric get metric; int get observationCount; double get median; double get medianAbsoluteDeviation; DateTime get start; DateTime get end; BaselineQuality get quality;
/// Create a copy of PersonalBaseline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalBaselineCopyWith<PersonalBaseline> get copyWith => _$PersonalBaselineCopyWithImpl<PersonalBaseline>(this as PersonalBaseline, _$identity);

  /// Serializes this PersonalBaseline to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalBaseline&&(identical(other.metric, metric) || other.metric == metric)&&(identical(other.observationCount, observationCount) || other.observationCount == observationCount)&&(identical(other.median, median) || other.median == median)&&(identical(other.medianAbsoluteDeviation, medianAbsoluteDeviation) || other.medianAbsoluteDeviation == medianAbsoluteDeviation)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.quality, quality) || other.quality == quality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metric,observationCount,median,medianAbsoluteDeviation,start,end,quality);

@override
String toString() {
  return 'PersonalBaseline(metric: $metric, observationCount: $observationCount, median: $median, medianAbsoluteDeviation: $medianAbsoluteDeviation, start: $start, end: $end, quality: $quality)';
}


}

/// @nodoc
abstract mixin class $PersonalBaselineCopyWith<$Res>  {
  factory $PersonalBaselineCopyWith(PersonalBaseline value, $Res Function(PersonalBaseline) _then) = _$PersonalBaselineCopyWithImpl;
@useResult
$Res call({
 HealthMetric metric, int observationCount, double median, double medianAbsoluteDeviation, DateTime start, DateTime end, BaselineQuality quality
});




}
/// @nodoc
class _$PersonalBaselineCopyWithImpl<$Res>
    implements $PersonalBaselineCopyWith<$Res> {
  _$PersonalBaselineCopyWithImpl(this._self, this._then);

  final PersonalBaseline _self;
  final $Res Function(PersonalBaseline) _then;

/// Create a copy of PersonalBaseline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metric = null,Object? observationCount = null,Object? median = null,Object? medianAbsoluteDeviation = null,Object? start = null,Object? end = null,Object? quality = null,}) {
  return _then(_self.copyWith(
metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as HealthMetric,observationCount: null == observationCount ? _self.observationCount : observationCount // ignore: cast_nullable_to_non_nullable
as int,median: null == median ? _self.median : median // ignore: cast_nullable_to_non_nullable
as double,medianAbsoluteDeviation: null == medianAbsoluteDeviation ? _self.medianAbsoluteDeviation : medianAbsoluteDeviation // ignore: cast_nullable_to_non_nullable
as double,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as BaselineQuality,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalBaseline].
extension PersonalBaselinePatterns on PersonalBaseline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalBaseline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalBaseline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalBaseline value)  $default,){
final _that = this;
switch (_that) {
case _PersonalBaseline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalBaseline value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalBaseline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HealthMetric metric,  int observationCount,  double median,  double medianAbsoluteDeviation,  DateTime start,  DateTime end,  BaselineQuality quality)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalBaseline() when $default != null:
return $default(_that.metric,_that.observationCount,_that.median,_that.medianAbsoluteDeviation,_that.start,_that.end,_that.quality);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HealthMetric metric,  int observationCount,  double median,  double medianAbsoluteDeviation,  DateTime start,  DateTime end,  BaselineQuality quality)  $default,) {final _that = this;
switch (_that) {
case _PersonalBaseline():
return $default(_that.metric,_that.observationCount,_that.median,_that.medianAbsoluteDeviation,_that.start,_that.end,_that.quality);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HealthMetric metric,  int observationCount,  double median,  double medianAbsoluteDeviation,  DateTime start,  DateTime end,  BaselineQuality quality)?  $default,) {final _that = this;
switch (_that) {
case _PersonalBaseline() when $default != null:
return $default(_that.metric,_that.observationCount,_that.median,_that.medianAbsoluteDeviation,_that.start,_that.end,_that.quality);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonalBaseline implements PersonalBaseline {
  const _PersonalBaseline({required this.metric, required this.observationCount, required this.median, required this.medianAbsoluteDeviation, required this.start, required this.end, required this.quality});
  factory _PersonalBaseline.fromJson(Map<String, dynamic> json) => _$PersonalBaselineFromJson(json);

@override final  HealthMetric metric;
@override final  int observationCount;
@override final  double median;
@override final  double medianAbsoluteDeviation;
@override final  DateTime start;
@override final  DateTime end;
@override final  BaselineQuality quality;

/// Create a copy of PersonalBaseline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalBaselineCopyWith<_PersonalBaseline> get copyWith => __$PersonalBaselineCopyWithImpl<_PersonalBaseline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalBaselineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalBaseline&&(identical(other.metric, metric) || other.metric == metric)&&(identical(other.observationCount, observationCount) || other.observationCount == observationCount)&&(identical(other.median, median) || other.median == median)&&(identical(other.medianAbsoluteDeviation, medianAbsoluteDeviation) || other.medianAbsoluteDeviation == medianAbsoluteDeviation)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.quality, quality) || other.quality == quality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metric,observationCount,median,medianAbsoluteDeviation,start,end,quality);

@override
String toString() {
  return 'PersonalBaseline(metric: $metric, observationCount: $observationCount, median: $median, medianAbsoluteDeviation: $medianAbsoluteDeviation, start: $start, end: $end, quality: $quality)';
}


}

/// @nodoc
abstract mixin class _$PersonalBaselineCopyWith<$Res> implements $PersonalBaselineCopyWith<$Res> {
  factory _$PersonalBaselineCopyWith(_PersonalBaseline value, $Res Function(_PersonalBaseline) _then) = __$PersonalBaselineCopyWithImpl;
@override @useResult
$Res call({
 HealthMetric metric, int observationCount, double median, double medianAbsoluteDeviation, DateTime start, DateTime end, BaselineQuality quality
});




}
/// @nodoc
class __$PersonalBaselineCopyWithImpl<$Res>
    implements _$PersonalBaselineCopyWith<$Res> {
  __$PersonalBaselineCopyWithImpl(this._self, this._then);

  final _PersonalBaseline _self;
  final $Res Function(_PersonalBaseline) _then;

/// Create a copy of PersonalBaseline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metric = null,Object? observationCount = null,Object? median = null,Object? medianAbsoluteDeviation = null,Object? start = null,Object? end = null,Object? quality = null,}) {
  return _then(_PersonalBaseline(
metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as HealthMetric,observationCount: null == observationCount ? _self.observationCount : observationCount // ignore: cast_nullable_to_non_nullable
as int,median: null == median ? _self.median : median // ignore: cast_nullable_to_non_nullable
as double,medianAbsoluteDeviation: null == medianAbsoluteDeviation ? _self.medianAbsoluteDeviation : medianAbsoluteDeviation // ignore: cast_nullable_to_non_nullable
as double,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as BaselineQuality,
  ));
}


}


/// @nodoc
mixin _$HealthFinding {

 String get id; String get observation; List<String> get evidence; FindingConfidence get confidence; FindingBasis get basis; List<String> get limitations; HealthMetric? get metric;
/// Create a copy of HealthFinding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthFindingCopyWith<HealthFinding> get copyWith => _$HealthFindingCopyWithImpl<HealthFinding>(this as HealthFinding, _$identity);

  /// Serializes this HealthFinding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthFinding&&(identical(other.id, id) || other.id == id)&&(identical(other.observation, observation) || other.observation == observation)&&const DeepCollectionEquality().equals(other.evidence, evidence)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.basis, basis) || other.basis == basis)&&const DeepCollectionEquality().equals(other.limitations, limitations)&&(identical(other.metric, metric) || other.metric == metric));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,observation,const DeepCollectionEquality().hash(evidence),confidence,basis,const DeepCollectionEquality().hash(limitations),metric);

@override
String toString() {
  return 'HealthFinding(id: $id, observation: $observation, evidence: $evidence, confidence: $confidence, basis: $basis, limitations: $limitations, metric: $metric)';
}


}

/// @nodoc
abstract mixin class $HealthFindingCopyWith<$Res>  {
  factory $HealthFindingCopyWith(HealthFinding value, $Res Function(HealthFinding) _then) = _$HealthFindingCopyWithImpl;
@useResult
$Res call({
 String id, String observation, List<String> evidence, FindingConfidence confidence, FindingBasis basis, List<String> limitations, HealthMetric? metric
});




}
/// @nodoc
class _$HealthFindingCopyWithImpl<$Res>
    implements $HealthFindingCopyWith<$Res> {
  _$HealthFindingCopyWithImpl(this._self, this._then);

  final HealthFinding _self;
  final $Res Function(HealthFinding) _then;

/// Create a copy of HealthFinding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? observation = null,Object? evidence = null,Object? confidence = null,Object? basis = null,Object? limitations = null,Object? metric = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,observation: null == observation ? _self.observation : observation // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<String>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as FindingConfidence,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as FindingBasis,limitations: null == limitations ? _self.limitations : limitations // ignore: cast_nullable_to_non_nullable
as List<String>,metric: freezed == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as HealthMetric?,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthFinding].
extension HealthFindingPatterns on HealthFinding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthFinding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthFinding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthFinding value)  $default,){
final _that = this;
switch (_that) {
case _HealthFinding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthFinding value)?  $default,){
final _that = this;
switch (_that) {
case _HealthFinding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String observation,  List<String> evidence,  FindingConfidence confidence,  FindingBasis basis,  List<String> limitations,  HealthMetric? metric)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthFinding() when $default != null:
return $default(_that.id,_that.observation,_that.evidence,_that.confidence,_that.basis,_that.limitations,_that.metric);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String observation,  List<String> evidence,  FindingConfidence confidence,  FindingBasis basis,  List<String> limitations,  HealthMetric? metric)  $default,) {final _that = this;
switch (_that) {
case _HealthFinding():
return $default(_that.id,_that.observation,_that.evidence,_that.confidence,_that.basis,_that.limitations,_that.metric);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String observation,  List<String> evidence,  FindingConfidence confidence,  FindingBasis basis,  List<String> limitations,  HealthMetric? metric)?  $default,) {final _that = this;
switch (_that) {
case _HealthFinding() when $default != null:
return $default(_that.id,_that.observation,_that.evidence,_that.confidence,_that.basis,_that.limitations,_that.metric);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthFinding implements HealthFinding {
  const _HealthFinding({required this.id, required this.observation, required final  List<String> evidence, required this.confidence, required this.basis, final  List<String> limitations = const <String>[], this.metric}): _evidence = evidence,_limitations = limitations;
  factory _HealthFinding.fromJson(Map<String, dynamic> json) => _$HealthFindingFromJson(json);

@override final  String id;
@override final  String observation;
 final  List<String> _evidence;
@override List<String> get evidence {
  if (_evidence is EqualUnmodifiableListView) return _evidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidence);
}

@override final  FindingConfidence confidence;
@override final  FindingBasis basis;
 final  List<String> _limitations;
@override@JsonKey() List<String> get limitations {
  if (_limitations is EqualUnmodifiableListView) return _limitations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_limitations);
}

@override final  HealthMetric? metric;

/// Create a copy of HealthFinding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthFindingCopyWith<_HealthFinding> get copyWith => __$HealthFindingCopyWithImpl<_HealthFinding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthFindingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthFinding&&(identical(other.id, id) || other.id == id)&&(identical(other.observation, observation) || other.observation == observation)&&const DeepCollectionEquality().equals(other._evidence, _evidence)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.basis, basis) || other.basis == basis)&&const DeepCollectionEquality().equals(other._limitations, _limitations)&&(identical(other.metric, metric) || other.metric == metric));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,observation,const DeepCollectionEquality().hash(_evidence),confidence,basis,const DeepCollectionEquality().hash(_limitations),metric);

@override
String toString() {
  return 'HealthFinding(id: $id, observation: $observation, evidence: $evidence, confidence: $confidence, basis: $basis, limitations: $limitations, metric: $metric)';
}


}

/// @nodoc
abstract mixin class _$HealthFindingCopyWith<$Res> implements $HealthFindingCopyWith<$Res> {
  factory _$HealthFindingCopyWith(_HealthFinding value, $Res Function(_HealthFinding) _then) = __$HealthFindingCopyWithImpl;
@override @useResult
$Res call({
 String id, String observation, List<String> evidence, FindingConfidence confidence, FindingBasis basis, List<String> limitations, HealthMetric? metric
});




}
/// @nodoc
class __$HealthFindingCopyWithImpl<$Res>
    implements _$HealthFindingCopyWith<$Res> {
  __$HealthFindingCopyWithImpl(this._self, this._then);

  final _HealthFinding _self;
  final $Res Function(_HealthFinding) _then;

/// Create a copy of HealthFinding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? observation = null,Object? evidence = null,Object? confidence = null,Object? basis = null,Object? limitations = null,Object? metric = freezed,}) {
  return _then(_HealthFinding(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,observation: null == observation ? _self.observation : observation // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self._evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<String>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as FindingConfidence,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as FindingBasis,limitations: null == limitations ? _self._limitations : limitations // ignore: cast_nullable_to_non_nullable
as List<String>,metric: freezed == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as HealthMetric?,
  ));
}


}


/// @nodoc
mixin _$DailyHealthBrief {

 DateTime get date; String get bodyStateSummary; List<HealthFinding> get findings; String get primaryAction; String get alternativeAction; String get fingerprint; BaselineQuality get baselineQuality;
/// Create a copy of DailyHealthBrief
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyHealthBriefCopyWith<DailyHealthBrief> get copyWith => _$DailyHealthBriefCopyWithImpl<DailyHealthBrief>(this as DailyHealthBrief, _$identity);

  /// Serializes this DailyHealthBrief to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyHealthBrief&&(identical(other.date, date) || other.date == date)&&(identical(other.bodyStateSummary, bodyStateSummary) || other.bodyStateSummary == bodyStateSummary)&&const DeepCollectionEquality().equals(other.findings, findings)&&(identical(other.primaryAction, primaryAction) || other.primaryAction == primaryAction)&&(identical(other.alternativeAction, alternativeAction) || other.alternativeAction == alternativeAction)&&(identical(other.fingerprint, fingerprint) || other.fingerprint == fingerprint)&&(identical(other.baselineQuality, baselineQuality) || other.baselineQuality == baselineQuality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,bodyStateSummary,const DeepCollectionEquality().hash(findings),primaryAction,alternativeAction,fingerprint,baselineQuality);

@override
String toString() {
  return 'DailyHealthBrief(date: $date, bodyStateSummary: $bodyStateSummary, findings: $findings, primaryAction: $primaryAction, alternativeAction: $alternativeAction, fingerprint: $fingerprint, baselineQuality: $baselineQuality)';
}


}

/// @nodoc
abstract mixin class $DailyHealthBriefCopyWith<$Res>  {
  factory $DailyHealthBriefCopyWith(DailyHealthBrief value, $Res Function(DailyHealthBrief) _then) = _$DailyHealthBriefCopyWithImpl;
@useResult
$Res call({
 DateTime date, String bodyStateSummary, List<HealthFinding> findings, String primaryAction, String alternativeAction, String fingerprint, BaselineQuality baselineQuality
});




}
/// @nodoc
class _$DailyHealthBriefCopyWithImpl<$Res>
    implements $DailyHealthBriefCopyWith<$Res> {
  _$DailyHealthBriefCopyWithImpl(this._self, this._then);

  final DailyHealthBrief _self;
  final $Res Function(DailyHealthBrief) _then;

/// Create a copy of DailyHealthBrief
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? bodyStateSummary = null,Object? findings = null,Object? primaryAction = null,Object? alternativeAction = null,Object? fingerprint = null,Object? baselineQuality = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,bodyStateSummary: null == bodyStateSummary ? _self.bodyStateSummary : bodyStateSummary // ignore: cast_nullable_to_non_nullable
as String,findings: null == findings ? _self.findings : findings // ignore: cast_nullable_to_non_nullable
as List<HealthFinding>,primaryAction: null == primaryAction ? _self.primaryAction : primaryAction // ignore: cast_nullable_to_non_nullable
as String,alternativeAction: null == alternativeAction ? _self.alternativeAction : alternativeAction // ignore: cast_nullable_to_non_nullable
as String,fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,baselineQuality: null == baselineQuality ? _self.baselineQuality : baselineQuality // ignore: cast_nullable_to_non_nullable
as BaselineQuality,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyHealthBrief].
extension DailyHealthBriefPatterns on DailyHealthBrief {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyHealthBrief value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyHealthBrief() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyHealthBrief value)  $default,){
final _that = this;
switch (_that) {
case _DailyHealthBrief():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyHealthBrief value)?  $default,){
final _that = this;
switch (_that) {
case _DailyHealthBrief() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  String bodyStateSummary,  List<HealthFinding> findings,  String primaryAction,  String alternativeAction,  String fingerprint,  BaselineQuality baselineQuality)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyHealthBrief() when $default != null:
return $default(_that.date,_that.bodyStateSummary,_that.findings,_that.primaryAction,_that.alternativeAction,_that.fingerprint,_that.baselineQuality);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  String bodyStateSummary,  List<HealthFinding> findings,  String primaryAction,  String alternativeAction,  String fingerprint,  BaselineQuality baselineQuality)  $default,) {final _that = this;
switch (_that) {
case _DailyHealthBrief():
return $default(_that.date,_that.bodyStateSummary,_that.findings,_that.primaryAction,_that.alternativeAction,_that.fingerprint,_that.baselineQuality);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  String bodyStateSummary,  List<HealthFinding> findings,  String primaryAction,  String alternativeAction,  String fingerprint,  BaselineQuality baselineQuality)?  $default,) {final _that = this;
switch (_that) {
case _DailyHealthBrief() when $default != null:
return $default(_that.date,_that.bodyStateSummary,_that.findings,_that.primaryAction,_that.alternativeAction,_that.fingerprint,_that.baselineQuality);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyHealthBrief implements DailyHealthBrief {
  const _DailyHealthBrief({required this.date, required this.bodyStateSummary, required final  List<HealthFinding> findings, required this.primaryAction, required this.alternativeAction, required this.fingerprint, required this.baselineQuality}): _findings = findings;
  factory _DailyHealthBrief.fromJson(Map<String, dynamic> json) => _$DailyHealthBriefFromJson(json);

@override final  DateTime date;
@override final  String bodyStateSummary;
 final  List<HealthFinding> _findings;
@override List<HealthFinding> get findings {
  if (_findings is EqualUnmodifiableListView) return _findings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_findings);
}

@override final  String primaryAction;
@override final  String alternativeAction;
@override final  String fingerprint;
@override final  BaselineQuality baselineQuality;

/// Create a copy of DailyHealthBrief
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyHealthBriefCopyWith<_DailyHealthBrief> get copyWith => __$DailyHealthBriefCopyWithImpl<_DailyHealthBrief>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyHealthBriefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyHealthBrief&&(identical(other.date, date) || other.date == date)&&(identical(other.bodyStateSummary, bodyStateSummary) || other.bodyStateSummary == bodyStateSummary)&&const DeepCollectionEquality().equals(other._findings, _findings)&&(identical(other.primaryAction, primaryAction) || other.primaryAction == primaryAction)&&(identical(other.alternativeAction, alternativeAction) || other.alternativeAction == alternativeAction)&&(identical(other.fingerprint, fingerprint) || other.fingerprint == fingerprint)&&(identical(other.baselineQuality, baselineQuality) || other.baselineQuality == baselineQuality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,bodyStateSummary,const DeepCollectionEquality().hash(_findings),primaryAction,alternativeAction,fingerprint,baselineQuality);

@override
String toString() {
  return 'DailyHealthBrief(date: $date, bodyStateSummary: $bodyStateSummary, findings: $findings, primaryAction: $primaryAction, alternativeAction: $alternativeAction, fingerprint: $fingerprint, baselineQuality: $baselineQuality)';
}


}

/// @nodoc
abstract mixin class _$DailyHealthBriefCopyWith<$Res> implements $DailyHealthBriefCopyWith<$Res> {
  factory _$DailyHealthBriefCopyWith(_DailyHealthBrief value, $Res Function(_DailyHealthBrief) _then) = __$DailyHealthBriefCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, String bodyStateSummary, List<HealthFinding> findings, String primaryAction, String alternativeAction, String fingerprint, BaselineQuality baselineQuality
});




}
/// @nodoc
class __$DailyHealthBriefCopyWithImpl<$Res>
    implements _$DailyHealthBriefCopyWith<$Res> {
  __$DailyHealthBriefCopyWithImpl(this._self, this._then);

  final _DailyHealthBrief _self;
  final $Res Function(_DailyHealthBrief) _then;

/// Create a copy of DailyHealthBrief
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? bodyStateSummary = null,Object? findings = null,Object? primaryAction = null,Object? alternativeAction = null,Object? fingerprint = null,Object? baselineQuality = null,}) {
  return _then(_DailyHealthBrief(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,bodyStateSummary: null == bodyStateSummary ? _self.bodyStateSummary : bodyStateSummary // ignore: cast_nullable_to_non_nullable
as String,findings: null == findings ? _self._findings : findings // ignore: cast_nullable_to_non_nullable
as List<HealthFinding>,primaryAction: null == primaryAction ? _self.primaryAction : primaryAction // ignore: cast_nullable_to_non_nullable
as String,alternativeAction: null == alternativeAction ? _self.alternativeAction : alternativeAction // ignore: cast_nullable_to_non_nullable
as String,fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,baselineQuality: null == baselineQuality ? _self.baselineQuality : baselineQuality // ignore: cast_nullable_to_non_nullable
as BaselineQuality,
  ));
}


}


/// @nodoc
mixin _$CoachMemory {

 String get id; String get fact; String get provenance; DateTime get createdAt; bool get confirmed;
/// Create a copy of CoachMemory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachMemoryCopyWith<CoachMemory> get copyWith => _$CoachMemoryCopyWithImpl<CoachMemory>(this as CoachMemory, _$identity);

  /// Serializes this CoachMemory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachMemory&&(identical(other.id, id) || other.id == id)&&(identical(other.fact, fact) || other.fact == fact)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fact,provenance,createdAt,confirmed);

@override
String toString() {
  return 'CoachMemory(id: $id, fact: $fact, provenance: $provenance, createdAt: $createdAt, confirmed: $confirmed)';
}


}

/// @nodoc
abstract mixin class $CoachMemoryCopyWith<$Res>  {
  factory $CoachMemoryCopyWith(CoachMemory value, $Res Function(CoachMemory) _then) = _$CoachMemoryCopyWithImpl;
@useResult
$Res call({
 String id, String fact, String provenance, DateTime createdAt, bool confirmed
});




}
/// @nodoc
class _$CoachMemoryCopyWithImpl<$Res>
    implements $CoachMemoryCopyWith<$Res> {
  _$CoachMemoryCopyWithImpl(this._self, this._then);

  final CoachMemory _self;
  final $Res Function(CoachMemory) _then;

/// Create a copy of CoachMemory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fact = null,Object? provenance = null,Object? createdAt = null,Object? confirmed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachMemory].
extension CoachMemoryPatterns on CoachMemory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachMemory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachMemory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachMemory value)  $default,){
final _that = this;
switch (_that) {
case _CoachMemory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachMemory value)?  $default,){
final _that = this;
switch (_that) {
case _CoachMemory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fact,  String provenance,  DateTime createdAt,  bool confirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachMemory() when $default != null:
return $default(_that.id,_that.fact,_that.provenance,_that.createdAt,_that.confirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fact,  String provenance,  DateTime createdAt,  bool confirmed)  $default,) {final _that = this;
switch (_that) {
case _CoachMemory():
return $default(_that.id,_that.fact,_that.provenance,_that.createdAt,_that.confirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fact,  String provenance,  DateTime createdAt,  bool confirmed)?  $default,) {final _that = this;
switch (_that) {
case _CoachMemory() when $default != null:
return $default(_that.id,_that.fact,_that.provenance,_that.createdAt,_that.confirmed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachMemory implements CoachMemory {
  const _CoachMemory({required this.id, required this.fact, required this.provenance, required this.createdAt, this.confirmed = false});
  factory _CoachMemory.fromJson(Map<String, dynamic> json) => _$CoachMemoryFromJson(json);

@override final  String id;
@override final  String fact;
@override final  String provenance;
@override final  DateTime createdAt;
@override@JsonKey() final  bool confirmed;

/// Create a copy of CoachMemory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachMemoryCopyWith<_CoachMemory> get copyWith => __$CoachMemoryCopyWithImpl<_CoachMemory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachMemoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachMemory&&(identical(other.id, id) || other.id == id)&&(identical(other.fact, fact) || other.fact == fact)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fact,provenance,createdAt,confirmed);

@override
String toString() {
  return 'CoachMemory(id: $id, fact: $fact, provenance: $provenance, createdAt: $createdAt, confirmed: $confirmed)';
}


}

/// @nodoc
abstract mixin class _$CoachMemoryCopyWith<$Res> implements $CoachMemoryCopyWith<$Res> {
  factory _$CoachMemoryCopyWith(_CoachMemory value, $Res Function(_CoachMemory) _then) = __$CoachMemoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String fact, String provenance, DateTime createdAt, bool confirmed
});




}
/// @nodoc
class __$CoachMemoryCopyWithImpl<$Res>
    implements _$CoachMemoryCopyWith<$Res> {
  __$CoachMemoryCopyWithImpl(this._self, this._then);

  final _CoachMemory _self;
  final $Res Function(_CoachMemory) _then;

/// Create a copy of CoachMemory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fact = null,Object? provenance = null,Object? createdAt = null,Object? confirmed = null,}) {
  return _then(_CoachMemory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ExperimentLog {

 DateTime get date; bool get adhered; int? get energy; int? get mood; String? get note;
/// Create a copy of ExperimentLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExperimentLogCopyWith<ExperimentLog> get copyWith => _$ExperimentLogCopyWithImpl<ExperimentLog>(this as ExperimentLog, _$identity);

  /// Serializes this ExperimentLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExperimentLog&&(identical(other.date, date) || other.date == date)&&(identical(other.adhered, adhered) || other.adhered == adhered)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,adhered,energy,mood,note);

@override
String toString() {
  return 'ExperimentLog(date: $date, adhered: $adhered, energy: $energy, mood: $mood, note: $note)';
}


}

/// @nodoc
abstract mixin class $ExperimentLogCopyWith<$Res>  {
  factory $ExperimentLogCopyWith(ExperimentLog value, $Res Function(ExperimentLog) _then) = _$ExperimentLogCopyWithImpl;
@useResult
$Res call({
 DateTime date, bool adhered, int? energy, int? mood, String? note
});




}
/// @nodoc
class _$ExperimentLogCopyWithImpl<$Res>
    implements $ExperimentLogCopyWith<$Res> {
  _$ExperimentLogCopyWithImpl(this._self, this._then);

  final ExperimentLog _self;
  final $Res Function(ExperimentLog) _then;

/// Create a copy of ExperimentLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? adhered = null,Object? energy = freezed,Object? mood = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,adhered: null == adhered ? _self.adhered : adhered // ignore: cast_nullable_to_non_nullable
as bool,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as int?,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExperimentLog].
extension ExperimentLogPatterns on ExperimentLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExperimentLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExperimentLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExperimentLog value)  $default,){
final _that = this;
switch (_that) {
case _ExperimentLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExperimentLog value)?  $default,){
final _that = this;
switch (_that) {
case _ExperimentLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  bool adhered,  int? energy,  int? mood,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExperimentLog() when $default != null:
return $default(_that.date,_that.adhered,_that.energy,_that.mood,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  bool adhered,  int? energy,  int? mood,  String? note)  $default,) {final _that = this;
switch (_that) {
case _ExperimentLog():
return $default(_that.date,_that.adhered,_that.energy,_that.mood,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  bool adhered,  int? energy,  int? mood,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _ExperimentLog() when $default != null:
return $default(_that.date,_that.adhered,_that.energy,_that.mood,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExperimentLog implements ExperimentLog {
  const _ExperimentLog({required this.date, required this.adhered, this.energy, this.mood, this.note});
  factory _ExperimentLog.fromJson(Map<String, dynamic> json) => _$ExperimentLogFromJson(json);

@override final  DateTime date;
@override final  bool adhered;
@override final  int? energy;
@override final  int? mood;
@override final  String? note;

/// Create a copy of ExperimentLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExperimentLogCopyWith<_ExperimentLog> get copyWith => __$ExperimentLogCopyWithImpl<_ExperimentLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExperimentLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExperimentLog&&(identical(other.date, date) || other.date == date)&&(identical(other.adhered, adhered) || other.adhered == adhered)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,adhered,energy,mood,note);

@override
String toString() {
  return 'ExperimentLog(date: $date, adhered: $adhered, energy: $energy, mood: $mood, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ExperimentLogCopyWith<$Res> implements $ExperimentLogCopyWith<$Res> {
  factory _$ExperimentLogCopyWith(_ExperimentLog value, $Res Function(_ExperimentLog) _then) = __$ExperimentLogCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, bool adhered, int? energy, int? mood, String? note
});




}
/// @nodoc
class __$ExperimentLogCopyWithImpl<$Res>
    implements _$ExperimentLogCopyWith<$Res> {
  __$ExperimentLogCopyWithImpl(this._self, this._then);

  final _ExperimentLog _self;
  final $Res Function(_ExperimentLog) _then;

/// Create a copy of ExperimentLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? adhered = null,Object? energy = freezed,Object? mood = freezed,Object? note = freezed,}) {
  return _then(_ExperimentLog(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,adhered: null == adhered ? _self.adhered : adhered // ignore: cast_nullable_to_non_nullable
as bool,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as int?,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WellbeingExperiment {

 String get id; String get title; String get action; String get hypothesis; int get durationDays; DateTime get createdAt; ExperimentStatus get status; List<HealthMetric> get outcomeMetrics; List<ExperimentLog> get logs; String? get result;
/// Create a copy of WellbeingExperiment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WellbeingExperimentCopyWith<WellbeingExperiment> get copyWith => _$WellbeingExperimentCopyWithImpl<WellbeingExperiment>(this as WellbeingExperiment, _$identity);

  /// Serializes this WellbeingExperiment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WellbeingExperiment&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.action, action) || other.action == action)&&(identical(other.hypothesis, hypothesis) || other.hypothesis == hypothesis)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.outcomeMetrics, outcomeMetrics)&&const DeepCollectionEquality().equals(other.logs, logs)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,action,hypothesis,durationDays,createdAt,status,const DeepCollectionEquality().hash(outcomeMetrics),const DeepCollectionEquality().hash(logs),result);

@override
String toString() {
  return 'WellbeingExperiment(id: $id, title: $title, action: $action, hypothesis: $hypothesis, durationDays: $durationDays, createdAt: $createdAt, status: $status, outcomeMetrics: $outcomeMetrics, logs: $logs, result: $result)';
}


}

/// @nodoc
abstract mixin class $WellbeingExperimentCopyWith<$Res>  {
  factory $WellbeingExperimentCopyWith(WellbeingExperiment value, $Res Function(WellbeingExperiment) _then) = _$WellbeingExperimentCopyWithImpl;
@useResult
$Res call({
 String id, String title, String action, String hypothesis, int durationDays, DateTime createdAt, ExperimentStatus status, List<HealthMetric> outcomeMetrics, List<ExperimentLog> logs, String? result
});




}
/// @nodoc
class _$WellbeingExperimentCopyWithImpl<$Res>
    implements $WellbeingExperimentCopyWith<$Res> {
  _$WellbeingExperimentCopyWithImpl(this._self, this._then);

  final WellbeingExperiment _self;
  final $Res Function(WellbeingExperiment) _then;

/// Create a copy of WellbeingExperiment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? action = null,Object? hypothesis = null,Object? durationDays = null,Object? createdAt = null,Object? status = null,Object? outcomeMetrics = null,Object? logs = null,Object? result = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,hypothesis: null == hypothesis ? _self.hypothesis : hypothesis // ignore: cast_nullable_to_non_nullable
as String,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExperimentStatus,outcomeMetrics: null == outcomeMetrics ? _self.outcomeMetrics : outcomeMetrics // ignore: cast_nullable_to_non_nullable
as List<HealthMetric>,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<ExperimentLog>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WellbeingExperiment].
extension WellbeingExperimentPatterns on WellbeingExperiment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WellbeingExperiment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WellbeingExperiment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WellbeingExperiment value)  $default,){
final _that = this;
switch (_that) {
case _WellbeingExperiment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WellbeingExperiment value)?  $default,){
final _that = this;
switch (_that) {
case _WellbeingExperiment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String action,  String hypothesis,  int durationDays,  DateTime createdAt,  ExperimentStatus status,  List<HealthMetric> outcomeMetrics,  List<ExperimentLog> logs,  String? result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WellbeingExperiment() when $default != null:
return $default(_that.id,_that.title,_that.action,_that.hypothesis,_that.durationDays,_that.createdAt,_that.status,_that.outcomeMetrics,_that.logs,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String action,  String hypothesis,  int durationDays,  DateTime createdAt,  ExperimentStatus status,  List<HealthMetric> outcomeMetrics,  List<ExperimentLog> logs,  String? result)  $default,) {final _that = this;
switch (_that) {
case _WellbeingExperiment():
return $default(_that.id,_that.title,_that.action,_that.hypothesis,_that.durationDays,_that.createdAt,_that.status,_that.outcomeMetrics,_that.logs,_that.result);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String action,  String hypothesis,  int durationDays,  DateTime createdAt,  ExperimentStatus status,  List<HealthMetric> outcomeMetrics,  List<ExperimentLog> logs,  String? result)?  $default,) {final _that = this;
switch (_that) {
case _WellbeingExperiment() when $default != null:
return $default(_that.id,_that.title,_that.action,_that.hypothesis,_that.durationDays,_that.createdAt,_that.status,_that.outcomeMetrics,_that.logs,_that.result);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WellbeingExperiment implements WellbeingExperiment {
  const _WellbeingExperiment({required this.id, required this.title, required this.action, required this.hypothesis, required this.durationDays, required this.createdAt, required this.status, required final  List<HealthMetric> outcomeMetrics, final  List<ExperimentLog> logs = const <ExperimentLog>[], this.result}): _outcomeMetrics = outcomeMetrics,_logs = logs;
  factory _WellbeingExperiment.fromJson(Map<String, dynamic> json) => _$WellbeingExperimentFromJson(json);

@override final  String id;
@override final  String title;
@override final  String action;
@override final  String hypothesis;
@override final  int durationDays;
@override final  DateTime createdAt;
@override final  ExperimentStatus status;
 final  List<HealthMetric> _outcomeMetrics;
@override List<HealthMetric> get outcomeMetrics {
  if (_outcomeMetrics is EqualUnmodifiableListView) return _outcomeMetrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_outcomeMetrics);
}

 final  List<ExperimentLog> _logs;
@override@JsonKey() List<ExperimentLog> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

@override final  String? result;

/// Create a copy of WellbeingExperiment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WellbeingExperimentCopyWith<_WellbeingExperiment> get copyWith => __$WellbeingExperimentCopyWithImpl<_WellbeingExperiment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WellbeingExperimentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WellbeingExperiment&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.action, action) || other.action == action)&&(identical(other.hypothesis, hypothesis) || other.hypothesis == hypothesis)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._outcomeMetrics, _outcomeMetrics)&&const DeepCollectionEquality().equals(other._logs, _logs)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,action,hypothesis,durationDays,createdAt,status,const DeepCollectionEquality().hash(_outcomeMetrics),const DeepCollectionEquality().hash(_logs),result);

@override
String toString() {
  return 'WellbeingExperiment(id: $id, title: $title, action: $action, hypothesis: $hypothesis, durationDays: $durationDays, createdAt: $createdAt, status: $status, outcomeMetrics: $outcomeMetrics, logs: $logs, result: $result)';
}


}

/// @nodoc
abstract mixin class _$WellbeingExperimentCopyWith<$Res> implements $WellbeingExperimentCopyWith<$Res> {
  factory _$WellbeingExperimentCopyWith(_WellbeingExperiment value, $Res Function(_WellbeingExperiment) _then) = __$WellbeingExperimentCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String action, String hypothesis, int durationDays, DateTime createdAt, ExperimentStatus status, List<HealthMetric> outcomeMetrics, List<ExperimentLog> logs, String? result
});




}
/// @nodoc
class __$WellbeingExperimentCopyWithImpl<$Res>
    implements _$WellbeingExperimentCopyWith<$Res> {
  __$WellbeingExperimentCopyWithImpl(this._self, this._then);

  final _WellbeingExperiment _self;
  final $Res Function(_WellbeingExperiment) _then;

/// Create a copy of WellbeingExperiment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? action = null,Object? hypothesis = null,Object? durationDays = null,Object? createdAt = null,Object? status = null,Object? outcomeMetrics = null,Object? logs = null,Object? result = freezed,}) {
  return _then(_WellbeingExperiment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,hypothesis: null == hypothesis ? _self.hypothesis : hypothesis // ignore: cast_nullable_to_non_nullable
as String,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExperimentStatus,outcomeMetrics: null == outcomeMetrics ? _self._outcomeMetrics : outcomeMetrics // ignore: cast_nullable_to_non_nullable
as List<HealthMetric>,logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<ExperimentLog>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PendingCoachAction {

 String get id; CoachActionType get type; String get title; String get explanation; Map<String, Object?> get payload;
/// Create a copy of PendingCoachAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingCoachActionCopyWith<PendingCoachAction> get copyWith => _$PendingCoachActionCopyWithImpl<PendingCoachAction>(this as PendingCoachAction, _$identity);

  /// Serializes this PendingCoachAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingCoachAction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&const DeepCollectionEquality().equals(other.payload, payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,explanation,const DeepCollectionEquality().hash(payload));

@override
String toString() {
  return 'PendingCoachAction(id: $id, type: $type, title: $title, explanation: $explanation, payload: $payload)';
}


}

/// @nodoc
abstract mixin class $PendingCoachActionCopyWith<$Res>  {
  factory $PendingCoachActionCopyWith(PendingCoachAction value, $Res Function(PendingCoachAction) _then) = _$PendingCoachActionCopyWithImpl;
@useResult
$Res call({
 String id, CoachActionType type, String title, String explanation, Map<String, Object?> payload
});




}
/// @nodoc
class _$PendingCoachActionCopyWithImpl<$Res>
    implements $PendingCoachActionCopyWith<$Res> {
  _$PendingCoachActionCopyWithImpl(this._self, this._then);

  final PendingCoachAction _self;
  final $Res Function(PendingCoachAction) _then;

/// Create a copy of PendingCoachAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? explanation = null,Object? payload = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CoachActionType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingCoachAction].
extension PendingCoachActionPatterns on PendingCoachAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingCoachAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingCoachAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingCoachAction value)  $default,){
final _that = this;
switch (_that) {
case _PendingCoachAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingCoachAction value)?  $default,){
final _that = this;
switch (_that) {
case _PendingCoachAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CoachActionType type,  String title,  String explanation,  Map<String, Object?> payload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingCoachAction() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.explanation,_that.payload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CoachActionType type,  String title,  String explanation,  Map<String, Object?> payload)  $default,) {final _that = this;
switch (_that) {
case _PendingCoachAction():
return $default(_that.id,_that.type,_that.title,_that.explanation,_that.payload);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CoachActionType type,  String title,  String explanation,  Map<String, Object?> payload)?  $default,) {final _that = this;
switch (_that) {
case _PendingCoachAction() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.explanation,_that.payload);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingCoachAction implements PendingCoachAction {
  const _PendingCoachAction({required this.id, required this.type, required this.title, required this.explanation, required final  Map<String, Object?> payload}): _payload = payload;
  factory _PendingCoachAction.fromJson(Map<String, dynamic> json) => _$PendingCoachActionFromJson(json);

@override final  String id;
@override final  CoachActionType type;
@override final  String title;
@override final  String explanation;
 final  Map<String, Object?> _payload;
@override Map<String, Object?> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}


/// Create a copy of PendingCoachAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingCoachActionCopyWith<_PendingCoachAction> get copyWith => __$PendingCoachActionCopyWithImpl<_PendingCoachAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingCoachActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingCoachAction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&const DeepCollectionEquality().equals(other._payload, _payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,explanation,const DeepCollectionEquality().hash(_payload));

@override
String toString() {
  return 'PendingCoachAction(id: $id, type: $type, title: $title, explanation: $explanation, payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$PendingCoachActionCopyWith<$Res> implements $PendingCoachActionCopyWith<$Res> {
  factory _$PendingCoachActionCopyWith(_PendingCoachAction value, $Res Function(_PendingCoachAction) _then) = __$PendingCoachActionCopyWithImpl;
@override @useResult
$Res call({
 String id, CoachActionType type, String title, String explanation, Map<String, Object?> payload
});




}
/// @nodoc
class __$PendingCoachActionCopyWithImpl<$Res>
    implements _$PendingCoachActionCopyWith<$Res> {
  __$PendingCoachActionCopyWithImpl(this._self, this._then);

  final _PendingCoachAction _self;
  final $Res Function(_PendingCoachAction) _then;

/// Create a copy of PendingCoachAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? explanation = null,Object? payload = null,}) {
  return _then(_PendingCoachAction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CoachActionType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}


/// @nodoc
mixin _$HealthCoachState {

 List<HealthCheckIn> get checkIns; List<CoachMemory> get memories; List<WellbeingExperiment> get experiments;
/// Create a copy of HealthCoachState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthCoachStateCopyWith<HealthCoachState> get copyWith => _$HealthCoachStateCopyWithImpl<HealthCoachState>(this as HealthCoachState, _$identity);

  /// Serializes this HealthCoachState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthCoachState&&const DeepCollectionEquality().equals(other.checkIns, checkIns)&&const DeepCollectionEquality().equals(other.memories, memories)&&const DeepCollectionEquality().equals(other.experiments, experiments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(checkIns),const DeepCollectionEquality().hash(memories),const DeepCollectionEquality().hash(experiments));

@override
String toString() {
  return 'HealthCoachState(checkIns: $checkIns, memories: $memories, experiments: $experiments)';
}


}

/// @nodoc
abstract mixin class $HealthCoachStateCopyWith<$Res>  {
  factory $HealthCoachStateCopyWith(HealthCoachState value, $Res Function(HealthCoachState) _then) = _$HealthCoachStateCopyWithImpl;
@useResult
$Res call({
 List<HealthCheckIn> checkIns, List<CoachMemory> memories, List<WellbeingExperiment> experiments
});




}
/// @nodoc
class _$HealthCoachStateCopyWithImpl<$Res>
    implements $HealthCoachStateCopyWith<$Res> {
  _$HealthCoachStateCopyWithImpl(this._self, this._then);

  final HealthCoachState _self;
  final $Res Function(HealthCoachState) _then;

/// Create a copy of HealthCoachState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkIns = null,Object? memories = null,Object? experiments = null,}) {
  return _then(_self.copyWith(
checkIns: null == checkIns ? _self.checkIns : checkIns // ignore: cast_nullable_to_non_nullable
as List<HealthCheckIn>,memories: null == memories ? _self.memories : memories // ignore: cast_nullable_to_non_nullable
as List<CoachMemory>,experiments: null == experiments ? _self.experiments : experiments // ignore: cast_nullable_to_non_nullable
as List<WellbeingExperiment>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthCoachState].
extension HealthCoachStatePatterns on HealthCoachState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthCoachState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthCoachState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthCoachState value)  $default,){
final _that = this;
switch (_that) {
case _HealthCoachState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthCoachState value)?  $default,){
final _that = this;
switch (_that) {
case _HealthCoachState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HealthCheckIn> checkIns,  List<CoachMemory> memories,  List<WellbeingExperiment> experiments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthCoachState() when $default != null:
return $default(_that.checkIns,_that.memories,_that.experiments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HealthCheckIn> checkIns,  List<CoachMemory> memories,  List<WellbeingExperiment> experiments)  $default,) {final _that = this;
switch (_that) {
case _HealthCoachState():
return $default(_that.checkIns,_that.memories,_that.experiments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HealthCheckIn> checkIns,  List<CoachMemory> memories,  List<WellbeingExperiment> experiments)?  $default,) {final _that = this;
switch (_that) {
case _HealthCoachState() when $default != null:
return $default(_that.checkIns,_that.memories,_that.experiments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthCoachState implements HealthCoachState {
  const _HealthCoachState({final  List<HealthCheckIn> checkIns = const <HealthCheckIn>[], final  List<CoachMemory> memories = const <CoachMemory>[], final  List<WellbeingExperiment> experiments = const <WellbeingExperiment>[]}): _checkIns = checkIns,_memories = memories,_experiments = experiments;
  factory _HealthCoachState.fromJson(Map<String, dynamic> json) => _$HealthCoachStateFromJson(json);

 final  List<HealthCheckIn> _checkIns;
@override@JsonKey() List<HealthCheckIn> get checkIns {
  if (_checkIns is EqualUnmodifiableListView) return _checkIns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checkIns);
}

 final  List<CoachMemory> _memories;
@override@JsonKey() List<CoachMemory> get memories {
  if (_memories is EqualUnmodifiableListView) return _memories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memories);
}

 final  List<WellbeingExperiment> _experiments;
@override@JsonKey() List<WellbeingExperiment> get experiments {
  if (_experiments is EqualUnmodifiableListView) return _experiments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_experiments);
}


/// Create a copy of HealthCoachState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthCoachStateCopyWith<_HealthCoachState> get copyWith => __$HealthCoachStateCopyWithImpl<_HealthCoachState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthCoachStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthCoachState&&const DeepCollectionEquality().equals(other._checkIns, _checkIns)&&const DeepCollectionEquality().equals(other._memories, _memories)&&const DeepCollectionEquality().equals(other._experiments, _experiments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_checkIns),const DeepCollectionEquality().hash(_memories),const DeepCollectionEquality().hash(_experiments));

@override
String toString() {
  return 'HealthCoachState(checkIns: $checkIns, memories: $memories, experiments: $experiments)';
}


}

/// @nodoc
abstract mixin class _$HealthCoachStateCopyWith<$Res> implements $HealthCoachStateCopyWith<$Res> {
  factory _$HealthCoachStateCopyWith(_HealthCoachState value, $Res Function(_HealthCoachState) _then) = __$HealthCoachStateCopyWithImpl;
@override @useResult
$Res call({
 List<HealthCheckIn> checkIns, List<CoachMemory> memories, List<WellbeingExperiment> experiments
});




}
/// @nodoc
class __$HealthCoachStateCopyWithImpl<$Res>
    implements _$HealthCoachStateCopyWith<$Res> {
  __$HealthCoachStateCopyWithImpl(this._self, this._then);

  final _HealthCoachState _self;
  final $Res Function(_HealthCoachState) _then;

/// Create a copy of HealthCoachState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkIns = null,Object? memories = null,Object? experiments = null,}) {
  return _then(_HealthCoachState(
checkIns: null == checkIns ? _self._checkIns : checkIns // ignore: cast_nullable_to_non_nullable
as List<HealthCheckIn>,memories: null == memories ? _self._memories : memories // ignore: cast_nullable_to_non_nullable
as List<CoachMemory>,experiments: null == experiments ? _self._experiments : experiments // ignore: cast_nullable_to_non_nullable
as List<WellbeingExperiment>,
  ));
}


}

// dart format on
