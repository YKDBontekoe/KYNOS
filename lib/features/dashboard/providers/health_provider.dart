import 'package:flutter/foundation.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/infrastructure/health/health_infrastructure_providers.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_provider.g.dart';

final _logger = Logger();

@Riverpod(keepAlive: true)
HealthRepository healthRepository(HealthRepositoryRef ref) {
  // Delegate to the infrastructure binding — feature layer stays decoupled
  // from the concrete HealthKitRepository class.
  return ref.watch(healthKitRepositoryProvider);
}

@riverpod
Future<HealthSummary?> healthSummary(HealthSummaryRef ref) async {
  if (kIsWeb) return null;
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.getToday();
  // Fail closed to "no data" so the dashboard still renders and can show
  // the explicit Connect HealthKit call-to-action.
  if (result.failure != null) {
    _logger.d('Health summary unavailable: ${result.failure}');
    return null;
  }
  return result.summary;
}

@riverpod
Future<List<HealthSummary>> healthHistory(
  HealthHistoryRef ref, {
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
  RecentRunsRef ref, {
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

/// Handles the HealthKit permission request triggered from the UI.
///
/// Invalidates health providers on success so dashboard sections refresh.
class HealthPermissionsNotifier extends Notifier<AsyncValue<bool>> {
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

final healthPermissionsNotifierProvider =
    NotifierProvider<HealthPermissionsNotifier, AsyncValue<bool>>(
      HealthPermissionsNotifier.new,
    );

@riverpod
Future<List<WorkoutRoutePoint>> runRoute(
  RunRouteRef ref, {
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
