import 'package:flutter/foundation.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/shared/providers/health_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_provider.g.dart';

@riverpod
Future<HealthSummary?> healthSummary(HealthSummaryRef ref) async {
  if (kIsWeb) return null;
  final repository = ref.watch(sharedHealthRepositoryProvider);

  // HealthKit requires authorisation before querying; this triggers the
  // system dialog on first run and is a no-op on subsequent calls.
  await repository.requestPermissions();

  final result = await repository.getToday();
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.summary;
}

@riverpod
Future<List<HealthSummary>> healthHistory(
  HealthHistoryRef ref, {
  int days = 30,
}) async {
  if (kIsWeb) return const <HealthSummary>[];
  final repository = ref.watch(sharedHealthRepositoryProvider);
  await repository.requestPermissions();

  final result = await repository.getSummaries(days: days);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.summaries;
}

@riverpod
Future<List<WorkoutSession>> recentRuns(
  RecentRunsRef ref, {
  int days = 30,
  int limit = 20,
}) async {
  if (kIsWeb) return const <WorkoutSession>[];
  final repository = ref.watch(sharedHealthRepositoryProvider);
  await repository.requestPermissions();

  final result = await repository.getRecentRuns(days: days, limit: limit);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.runs;
}

/// Handles the HealthKit permission request triggered from the UI.
///
/// Invalidates health providers on success so dashboard sections refresh.
@riverpod
class HealthPermissionsNotifier extends _$HealthPermissionsNotifier {
  @override
  AsyncValue<bool> build() => const AsyncData(false);

  Future<void> request() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(sharedHealthRepositoryProvider);
      final success = await repo.requestPermissions();
      state = AsyncData(success);
      if (success) {
        ref.invalidate(healthSummaryProvider);
        ref.invalidate(healthHistoryProvider);
        ref.invalidate(recentRunsProvider);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

@riverpod
Future<List<WorkoutRoutePoint>> runRoute(
  RunRouteRef ref, {
  required String workoutUuid,
}) async {
  if (kIsWeb) return const <WorkoutRoutePoint>[];
  final repository = ref.watch(sharedHealthRepositoryProvider);
  await repository.requestPermissions();

  final result = await repository.getRunRoute(workoutUuid: workoutUuid);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.points;
}
