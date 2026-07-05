import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';

bool _isRunDay(HealthSummary summary) => (summary.runningWorkoutCount ?? 0) > 0;

DateTime _dayStart(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// Consecutive run days ending at [asOf], using daily health summaries.
int computeRunStreakFromSummaries(
  List<HealthSummary> history, {
  DateTime? asOf,
}) {
  if (history.isEmpty) return 0;

  final anchor = _dayStart(asOf ?? DateTime.now());
  final byDay = <DateTime, HealthSummary>{};
  for (final sample in history) {
    byDay[_dayStart(sample.date)] = sample;
  }

  var streak = 0;
  var cursor = anchor;

  // Allow streak to start today or yesterday (rest day grace).
  if (!_isRunDay(byDay[cursor] ?? _emptySummary(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
  }

  while (true) {
    final sample = byDay[cursor];
    if (sample == null || !_isRunDay(sample)) break;
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return streak;
}

/// Consecutive calendar days with at least one run ending at [asOf].
int computeRunStreakFromRuns(
  List<WorkoutSession> runs, {
  DateTime? asOf,
}) {
  if (runs.isEmpty) return 0;

  final anchor = _dayStart(asOf ?? DateTime.now());
  final runDays = runs.map((r) => _dayStart(r.start)).toSet();

  var streak = 0;
  var cursor = anchor;

  if (!runDays.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }

  while (runDays.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return streak;
}

HealthSummary _emptySummary(DateTime date) => HealthSummary(date: date);
