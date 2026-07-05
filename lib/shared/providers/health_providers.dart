import 'package:flutter/foundation.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_providers.g.dart';

final _logger = Logger();

/// Canonical HealthKit repository binding for the app.
@Riverpod(keepAlive: true)
HealthRepository healthRepository(Ref ref) {
  return ref.watch(healthKitRepositoryProvider);
}

@riverpod
Future<HealthSummary?> healthSummary(Ref ref) async {
  if (kIsWeb) return null;
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getToday();
  if (result.failure != null) {
    _logger.d('Health summary unavailable: ${result.failure}');
    return null;
  }
  return result.summary;
}

@riverpod
Future<List<HealthSummary>> healthHistory(
  Ref ref, {
  int days = 30,
}) async {
  if (kIsWeb) return const <HealthSummary>[];
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getSummaries(days: days);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.summaries;
}

@riverpod
Future<List<WorkoutSession>> recentRuns(
  Ref ref, {
  int days = 30,
  int limit = 20,
}) async {
  if (kIsWeb) return const <WorkoutSession>[];
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getRecentRuns(days: days, limit: limit);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.runs;
}

@riverpod
Future<List<WorkoutRoutePoint>> runRoute(
  Ref ref, {
  required String workoutUuid,
}) async {
  if (kIsWeb) return const <WorkoutRoutePoint>[];
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getRunRoute(workoutUuid: workoutUuid);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.points;
}

/// Handles the HealthKit permission request triggered from the UI.
@Riverpod(keepAlive: true)
class HealthPermissionsNotifier extends _$HealthPermissionsNotifier {
  @override
  AsyncValue<bool> build() => const AsyncData(false);

  Future<void> request() async {
    if (kIsWeb) {
      state = AsyncError(
        UnsupportedError(
          'HealthKit is only available on iOS. Run KYNOS on a physical iPhone.',
        ),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    try {
      final repo = ref.read(healthRepositoryProvider);
      final success = await repo.requestPermissions();
      state = AsyncData(success);
      if (success) {
        ref.invalidate(healthSummaryProvider);
        ref.invalidate(healthHistoryProvider);
        ref.invalidate(recentRunsProvider);
      }
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
