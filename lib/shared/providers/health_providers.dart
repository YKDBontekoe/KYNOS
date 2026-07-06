import 'package:flutter/foundation.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_providers.g.dart';

/// Canonical health repository binding — merges HealthKit and imported data.
@Riverpod(keepAlive: true)
HealthRepository healthRepository(Ref ref) {
  return ref.watch(compositeHealthRepositoryProvider);
}

@riverpod
Future<HealthSummary?> healthSummary(Ref ref) async {
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getToday();
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.summary;
}

@riverpod
Future<List<HealthSummary>> healthHistory(
  Ref ref, {
  int days = 30,
}) async {
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
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getRunRoute(workoutUuid: workoutUuid);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.points;
}

@riverpod
Future<int> importedWorkoutCount(Ref ref) async {
  final store = ref.watch(importedHealthStoreProvider);
  return store.workoutCount();
}

void invalidateHealthProviders(Ref ref) {
  ref.invalidate(healthSummaryProvider);
  ref.invalidate(healthHistoryProvider);
  ref.invalidate(recentRunsProvider);
  ref.invalidate(importedWorkoutCountProvider);
}

/// Handles the HealthKit permission request triggered from the UI.
@Riverpod(keepAlive: true)
class HealthPermissionsNotifier extends _$HealthPermissionsNotifier {
  final _logger = Logger();

  @override
  Future<bool> build() async {
    if (kIsWeb) return false;
    try {
      final repo = ref.read(healthRepositoryProvider);
      return await repo.hasPermissions();
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Unexpected error checking health permissions',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> request() async {
    if (kIsWeb) {
      state = AsyncError(
        UnsupportedError(
          'HealthKit is only available on iOS. Import runs from Settings instead.',
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
        invalidateHealthProviders(ref);
      }
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Clears all imported workouts and refreshes health providers.
@Riverpod(keepAlive: true)
class ImportedHealthDataNotifier extends _$ImportedHealthDataNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> clearAll() async {
    state = const AsyncLoading();
    try {
      final store = ref.read(importedHealthStoreProvider);
      await store.clearAll();
      state = const AsyncData(null);
      invalidateHealthProviders(ref);
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
