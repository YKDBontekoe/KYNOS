import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/providers/health_repository_provider.dart';

final healthSummaryProvider = FutureProvider.autoDispose<HealthSummary?>((ref) async {
  if (kIsWeb) return null;
  final repository = ref.watch(sharedHealthRepositoryProvider);
  await repository.requestPermissions();
  final result = await repository.getToday();
  if (result.failure != null) throw result.failure!;
  return result.summary;
});

final healthHistoryProvider = FutureProvider.autoDispose.family<List<HealthSummary>, int>(
  (ref, days) async {
    if (kIsWeb) return const <HealthSummary>[];
    final repository = ref.watch(sharedHealthRepositoryProvider);
    await repository.requestPermissions();
    final result = await repository.getSummaries(days: days);
    if (result.failure != null) throw result.failure!;
    return result.summaries;
  },
);

// Named-parameter record for recentRuns to preserve call-site clarity.
typedef RecentRunsArgs = ({int days, int limit});

final recentRunsProvider = FutureProvider.autoDispose.family<List<WorkoutSession>, RecentRunsArgs>(
  (ref, args) async {
    if (kIsWeb) return const <WorkoutSession>[];
    final repository = ref.watch(sharedHealthRepositoryProvider);
    await repository.requestPermissions();
    final result = await repository.getRecentRuns(
      days: args.days,
      limit: args.limit,
    );
    if (result.failure != null) throw result.failure!;
    return result.runs;
  },
);

final runRouteProvider = FutureProvider.autoDispose.family<List<WorkoutRoutePoint>, String>(
  (ref, workoutUuid) async {
    if (kIsWeb) return const <WorkoutRoutePoint>[];
    final repository = ref.watch(sharedHealthRepositoryProvider);
    await repository.requestPermissions();
    final result = await repository.getRunRoute(workoutUuid: workoutUuid);
    if (result.failure != null) throw result.failure!;
    return result.points;
  },
);

/// Handles the HealthKit permission request triggered from the UI.
///
/// Invalidates the health data providers on success so every section refreshes.
class HealthPermissionsNotifier extends Notifier<AsyncValue<bool>> {
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

final healthPermissionsNotifierProvider =
    NotifierProvider<HealthPermissionsNotifier, AsyncValue<bool>>(
      HealthPermissionsNotifier.new,
    );
