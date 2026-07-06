import 'dart:math' as math;

import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/geo_distance.dart';

/// A single pace sample along the route (distance in km, pace in sec/km).
class PaceProfilePoint {
  const PaceProfilePoint({
    required this.distanceKm,
    required this.paceSecondsPerKm,
  });

  final double distanceKm;
  final double paceSecondsPerKm;
}

/// Per-kilometer split timing.
class KilometerSplit {
  const KilometerSplit({
    required this.kilometer,
    required this.duration,
    required this.paceSecondsPerKm,
  });

  final int kilometer;
  final Duration duration;
  final double paceSecondsPerKm;
}

/// Analytics derived from a workout session and optional GPS route.
class RunRouteAnalytics {
  const RunRouteAnalytics({
    required this.avgPaceSecondsPerKm,
    required this.gpsDistanceMeters,
    required this.movingTime,
    required this.paceProfile,
    required this.kilometerSplits,
    this.fastestSplitIndex,
    this.slowestSplitIndex,
  });

  final double? avgPaceSecondsPerKm;
  final double gpsDistanceMeters;
  final Duration? movingTime;
  final List<PaceProfilePoint> paceProfile;
  final List<KilometerSplit> kilometerSplits;
  final int? fastestSplitIndex;
  final int? slowestSplitIndex;

  bool get hasPaceProfile => paceProfile.length >= 3;
  bool get hasSplits => kilometerSplits.isNotEmpty;
}

const _maxReasonableSpeedMps = 12.0; // ~2:47 /km
const _minSegmentMeters = 3.0;
const _targetProfilePoints = 30;

/// Computes run analytics from session metadata and GPS points.
RunRouteAnalytics computeRunRouteAnalytics({
  required WorkoutSession session,
  required List<WorkoutRoutePoint> points,
}) {
  final gpsDistance = routeDistanceMeters(points);
  final effectiveDistance = session.distanceMeters ?? gpsDistance;

  final avgPace = effectiveDistance > 0
      ? session.duration.inSeconds / (effectiveDistance / 1000)
      : null;

  final segments = _buildSegments(points);
  final movingTime = _computeMovingTime(segments);
  final paceProfile = _buildPaceProfile(segments);
  final splits = _buildKilometerSplits(segments);

  int? fastestIndex;
  int? slowestIndex;
  if (splits.length >= 2) {
    var fastestPace = double.infinity;
    var slowestPace = 0.0;
    for (var i = 0; i < splits.length; i++) {
      final pace = splits[i].paceSecondsPerKm;
      if (pace < fastestPace) {
        fastestPace = pace;
        fastestIndex = i;
      }
      if (pace > slowestPace) {
        slowestPace = pace;
        slowestIndex = i;
      }
    }
  }

  return RunRouteAnalytics(
    avgPaceSecondsPerKm: avgPace,
    gpsDistanceMeters: gpsDistance,
    movingTime: movingTime,
    paceProfile: paceProfile,
    kilometerSplits: splits,
    fastestSplitIndex: fastestIndex,
    slowestSplitIndex: slowestIndex,
  );
}

class _RouteSegment {
  const _RouteSegment({
    required this.distanceMeters,
    required this.duration,
  });

  final double distanceMeters;
  final Duration? duration;
}

List<_RouteSegment> _buildSegments(List<WorkoutRoutePoint> points) {
  if (points.length < 2) return const [];

  final segments = <_RouteSegment>[];
  for (var i = 1; i < points.length; i++) {
    final prev = points[i - 1];
    final curr = points[i];
    final distance = haversineMeters(
      prev.latitude,
      prev.longitude,
      curr.latitude,
      curr.longitude,
    );
    if (distance < _minSegmentMeters) continue;

    Duration? duration;
    if (prev.timestamp != null && curr.timestamp != null) {
      final delta = curr.timestamp!.difference(prev.timestamp!);
      if (!delta.isNegative) {
        duration = delta;
      }
    }

    segments.add(_RouteSegment(distanceMeters: distance, duration: duration));
  }
  return segments;
}

Duration? _computeMovingTime(List<_RouteSegment> segments) {
  var totalSeconds = 0;
  var hasDuration = false;

  for (final segment in segments) {
    final duration = segment.duration;
    if (duration == null) continue;

    final seconds = duration.inMilliseconds / 1000.0;
    if (seconds <= 0) continue;

    final speed = segment.distanceMeters / seconds;
    if (speed > _maxReasonableSpeedMps) continue;

    totalSeconds += seconds.round();
    hasDuration = true;
  }

  return hasDuration ? Duration(seconds: totalSeconds) : null;
}

List<PaceProfilePoint> _buildPaceProfile(List<_RouteSegment> segments) {
  final timed = <({double distanceMeters, double seconds})>[];
  for (final segment in segments) {
    final duration = segment.duration;
    if (duration == null || duration.inSeconds <= 0) continue;

    final seconds = duration.inMilliseconds / 1000.0;
    final speed = segment.distanceMeters / seconds;
    if (speed > _maxReasonableSpeedMps) continue;

    timed.add((distanceMeters: segment.distanceMeters, seconds: seconds));
  }
  if (timed.length < 2) return const [];

  final cumulativeDistanceKm = <double>[];
  final paceValues = <double>[];
  var distanceM = 0.0;

  for (final sample in timed) {
    distanceM += sample.distanceMeters;
    final pace = sample.seconds / (sample.distanceMeters / 1000);
    cumulativeDistanceKm.add(distanceM / 1000);
    paceValues.add(pace);
  }

  if (paceValues.length <= _targetProfilePoints) {
    return List.generate(
      paceValues.length,
      (i) => PaceProfilePoint(
        distanceKm: cumulativeDistanceKm[i],
        paceSecondsPerKm: paceValues[i],
      ),
    );
  }

  final step = paceValues.length / _targetProfilePoints;
  final profile = <PaceProfilePoint>[];
  for (var i = 0; i < _targetProfilePoints; i++) {
    final index = (i * step).floor().clamp(0, paceValues.length - 1);
    profile.add(
      PaceProfilePoint(
        distanceKm: cumulativeDistanceKm[index],
        paceSecondsPerKm: paceValues[index],
      ),
    );
  }
  return profile;
}

List<KilometerSplit> _buildKilometerSplits(List<_RouteSegment> segments) {
  final timed = segments.where((s) {
    if (s.duration == null || s.duration!.inSeconds <= 0) return false;
    final seconds = s.duration!.inMilliseconds / 1000.0;
    final speed = s.distanceMeters / seconds;
    return speed <= _maxReasonableSpeedMps;
  }).toList();

  if (timed.isEmpty) return const [];

  var currentKm = 1;
  var currentKmMeters = 0.0;
  var currentKmSeconds = 0.0;
  final splits = <KilometerSplit>[];

  for (final segment in timed) {
    var remaining = segment.distanceMeters;
    final seconds = segment.duration!.inMilliseconds / 1000.0;

    while (remaining > 0) {
      final toKmEnd = 1000 - currentKmMeters;
      if (remaining >= toKmEnd) {
        final fraction = toKmEnd / segment.distanceMeters;
        currentKmSeconds += seconds * fraction;
        splits.add(
          KilometerSplit(
            kilometer: currentKm,
            duration: Duration(seconds: currentKmSeconds.round()),
            paceSecondsPerKm: currentKmSeconds,
          ),
        );
        remaining -= toKmEnd;
        currentKm++;
        currentKmMeters = 0;
        currentKmSeconds = 0;
      } else {
        currentKmMeters += remaining;
        currentKmSeconds += seconds * (remaining / segment.distanceMeters);
        remaining = 0;
      }
    }
  }

  return splits;
}

/// Coefficient of variation for pace consistency (lower = more consistent).
double? paceConsistencyScore(List<KilometerSplit> splits) {
  if (splits.length < 2) return null;
  final paces = splits.map((s) => s.paceSecondsPerKm).toList();
  final mean = paces.reduce((a, b) => a + b) / paces.length;
  if (mean <= 0) return null;

  var variance = 0.0;
  for (final pace in paces) {
    final diff = pace - mean;
    variance += diff * diff;
  }
  variance /= paces.length;
  final stdDev = math.sqrt(variance);
  return stdDev / mean;
}
