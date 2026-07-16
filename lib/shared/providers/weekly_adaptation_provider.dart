import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/usecases/coach/build_weekly_adaptation_action_usecase.dart';
import 'package:kynos/domain/utils/acwr.dart';
import 'package:kynos/domain/utils/readiness_score.dart';
import 'package:kynos/domain/utils/training_plan_week.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:kynos/shared/providers/training_plan_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weekly_adaptation_provider.g.dart';

/// Surfaces a confirmable weekly plan-protection action when due.
@Riverpod(keepAlive: true)
class WeeklyAdaptation extends _$WeeklyAdaptation {
  static const dismissedWeekKey = 'weekly_adaptation_dismissed_week';
  static const _buildAction = BuildWeeklyAdaptationActionUseCase();

  @override
  PendingCoachAction? build() {
    final plan = ref.watch(trainingPlanDataProvider).value;
    if (plan == null || !plan.active) return null;

    final prefs = ref.watch(sharedPreferencesProvider);
    final dismissed = prefs.getString(dismissedWeekKey);
    final history = ref.watch(healthHistoryProvider(days: 28)).value ?? [];
    final sorted = List.of(history)..sort((a, b) => b.date.compareTo(a.date));
    final readiness = readinessScore(sorted.firstOrNull);
    final acwr = computeAcwr(sorted);

    return _buildAction(
      plan: plan,
      readinessScore: readiness > 0 ? readiness : null,
      acwr: acwr,
      alreadyNudgedWeekKey: dismissed,
    );
  }

  Future<void> dismiss() async {
    await _markWeekHandled();
    state = null;
  }

  /// Call after the user confirms the pending action so we don't re-nudge.
  Future<void> markConfirmed() async {
    await _markWeekHandled();
    state = null;
  }

  Future<void> _markWeekHandled() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final weekKey = _weekKey(DateTime.now());
    await prefs.setString(dismissedWeekKey, weekKey);
  }

  String _weekKey(DateTime date) {
    final start = planWeekStart(date);
    return '${start.year.toString().padLeft(4, '0')}-'
        '${start.month.toString().padLeft(2, '0')}-'
        '${start.day.toString().padLeft(2, '0')}';
  }
}
