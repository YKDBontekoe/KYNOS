import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/usecases/coach/match_workout_to_plan_day_usecase.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/post_run_debrief_provider.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:kynos/shared/providers/training_plan_providers.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plan_health_sync_provider.g.dart';

/// Runs plan auto-adherence + post-run debrief after health data refreshes.
@Riverpod(keepAlive: true)
class PlanHealthSync extends _$PlanHealthSync {
  static const _autoMarkedWorkoutsKey = 'plan_auto_marked_workout_ids';
  static const _matchWorkouts = MatchWorkoutToPlanDayUseCase();
  static final _log = Logger();

  @override
  int build() {
    // Keep alive and react when recent runs resolve after invalidation.
    ref.listen(recentRunsProvider(days: 14, limit: 20), (previous, next) {
      next.whenData((_) {
        // Fire-and-forget; errors are logged inside syncAfterHealthRefresh.
        syncAfterHealthRefresh();
      });
    });
    return 0;
  }

  /// Match workouts → adherence, then generate a post-run debrief if needed.
  Future<void> syncAfterHealthRefresh() async {
    try {
      await _applyAutoAdherence();
    } on Object catch (error, stackTrace) {
      _log.w(
        'Plan auto-adherence failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
    try {
      await ref.read(postRunDebriefProvider.notifier).checkLatestRun();
    } on Object catch (error, stackTrace) {
      _log.w(
        'Post-run debrief check failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _applyAutoAdherence() async {
    final plan = ref.read(trainingPlanDataProvider).value;
    if (plan == null || !plan.active) return;

    final runs = await ref.read(recentRunsProvider(days: 14, limit: 20).future);
    if (runs.isEmpty) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final alreadyMarked =
        prefs.getStringList(_autoMarkedWorkoutsKey)?.toSet() ?? {};

    final matches = _matchWorkouts(plan: plan, workouts: runs).where(
      (match) => !alreadyMarked.contains(match.workout.id),
    );
    if (matches.isEmpty) return;

    final markedIds = <String>{...alreadyMarked};
    for (final match in matches) {
      final current = ref.read(trainingPlanDataProvider).value;
      if (current == null) break;
      final day = current.dayFor(match.day.date);
      if (day == null || day.adherence != PlanAdherenceStatus.pending) {
        markedIds.add(match.workout.id);
        continue;
      }
      await ref.read(trainingPlanDataProvider.notifier).markAdherence(
            date: match.day.date,
            status: PlanAdherenceStatus.done,
            note: match.note,
          );
      markedIds.add(match.workout.id);
    }

    // Keep the list bounded.
    final stored = markedIds.toList();
    if (stored.length > 80) {
      stored.removeRange(0, stored.length - 80);
    }
    await prefs.setStringList(_autoMarkedWorkoutsKey, stored);
  }
}
