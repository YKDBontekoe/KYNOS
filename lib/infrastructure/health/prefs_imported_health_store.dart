import 'dart:convert';

import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/infrastructure/health/imported_health_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-backed store for imported workouts on web.
class PrefsImportedHealthStore implements ImportedHealthStore {
  PrefsImportedHealthStore(this._prefs);

  static const _workoutsKey = 'imported_health_workouts';
  static const _routesKey = 'imported_health_routes';
  static const _summariesKey = 'imported_health_summaries';

  final SharedPreferences _prefs;

  @override
  Future<int> workoutCount() async {
    return _readWorkouts().length;
  }

  @override
  Future<List<WorkoutSession>> getWorkouts({
    required DateTime since,
    int? limit,
  }) async {
    final workouts = _readWorkouts()
        .where((workout) => !workout.start.isBefore(since))
        .toList()
      ..sort((a, b) => b.start.compareTo(a.start));

    if (limit != null && workouts.length > limit) {
      return workouts.take(limit).toList();
    }
    return workouts;
  }

  @override
  Future<List<WorkoutRoutePoint>> getRoutePoints(String workoutId) async {
    final raw = _prefs.getString(_routesKey);
    if (raw == null) return const [];

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final points = decoded[workoutId];
    if (points is! List<dynamic>) return const [];
    return routePointsFromJson(points);
  }

  @override
  Future<void> saveWorkout({
    required WorkoutSession workout,
    List<WorkoutRoutePoint> routePoints = const [],
  }) async {
    final workouts = _readWorkouts()
      ..removeWhere((existing) => existing.id == workout.id)
      ..add(workout);

    workouts.sort((a, b) => b.start.compareTo(a.start));

    await _prefs.setString(
      _workoutsKey,
      jsonEncode(workouts.map(workoutSessionToJson).toList()),
    );

    final routes = _readRoutes();
    if (routePoints.isEmpty) {
      routes.remove(workout.id);
    } else {
      routes[workout.id] = routePointsToJson(routePoints);
    }
    await _prefs.setString(_routesKey, jsonEncode(routes));
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_workoutsKey);
    await _prefs.remove(_routesKey);
    await _prefs.remove(_summariesKey);
  }

  @override
  Future<List<HealthSummary>> getSummaries({required DateTime since}) async {
    return _readSummaries()
        .where((summary) => !summary.date.isBefore(since))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> saveSummaries(List<HealthSummary> summaries) async {
    if (summaries.isEmpty) {
      return;
    }

    final stored = {
      for (final summary in _readSummaries())
        DateTime(summary.date.year, summary.date.month, summary.date.day):
            summary,
    };

    for (final summary in summaries) {
      final day = DateTime(
        summary.date.year,
        summary.date.month,
        summary.date.day,
      );
      stored[day] = summary;
    }

    await _prefs.setString(
      _summariesKey,
      jsonEncode(stored.values.map(healthSummaryToJson).toList()),
    );
  }

  List<HealthSummary> _readSummaries() {
    final raw = _prefs.getString(_summariesKey);
    if (raw == null) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (entry) => healthSummaryFromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  List<WorkoutSession> _readWorkouts() {
    final raw = _prefs.getString(_workoutsKey);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => workoutSessionFromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Map<String, List<Map<String, dynamic>>> _readRoutes() {
    final raw = _prefs.getString(_routesKey);
    if (raw == null) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).cast<Map<String, dynamic>>(),
      ),
    );
  }
}
