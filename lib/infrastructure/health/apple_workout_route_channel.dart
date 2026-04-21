import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';

class AppleWorkoutRouteChannel {
  AppleWorkoutRouteChannel._();

  static const MethodChannel _channel = MethodChannel('kynos/health_route');

  static Future<List<WorkoutRoutePoint>> getWorkoutRoute({
    required String workoutUuid,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const <WorkoutRoutePoint>[];
    }

    final response = await _channel.invokeMethod<dynamic>(
      'getWorkoutRoute',
      <String, dynamic>{'workoutUuid': workoutUuid},
    );

    if (response is! Map<Object?, Object?>) {
      return const <WorkoutRoutePoint>[];
    }

    final rawPoints = response['points'];
    if (rawPoints is! List) {
      return const <WorkoutRoutePoint>[];
    }

    return rawPoints.whereType<Map<Object?, Object?>>().map((raw) {
      final map = Map<String, dynamic>.from(raw);
      return WorkoutRoutePoint.fromJson(map);
    }).toList();
  }
}
