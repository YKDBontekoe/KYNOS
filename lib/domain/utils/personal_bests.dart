import 'package:kynos/domain/entities/health_summary.dart';

/// Finds short personal-best callouts for dashboard chips.
List<String> findPersonalBestCallouts(
  List<HealthSummary> history,
  HealthSummary? today, {
  int lookbackDays = 14,
}) {
  if (today == null || history.isEmpty) return const [];

  final cutoff = DateTime.now().subtract(Duration(days: lookbackDays));
  final recent = history.where((s) => s.date.isAfter(cutoff)).toList();
  if (recent.length < 2) return const [];

  final callouts = <String>[];

  final todayHrv = today.hrvMs;
  if (todayHrv != null) {
    final best = recent
        .map((s) => s.hrvMs)
        .whereType<double>()
        .fold<double?>(null, (best, v) => best == null || v > best ? v : best);
    if (best != null && todayHrv >= best - 0.5) {
      callouts.add('Best HRV in $lookbackDays days');
    }
  }

  final todaySleep = today.sleepHours;
  if (todaySleep != null) {
    final best = recent
        .map((s) => s.sleepHours)
        .whereType<double>()
        .fold<double?>(null, (best, v) => best == null || v > best ? v : best);
    if (best != null && todaySleep >= best - 0.1) {
      callouts.add('Best sleep in $lookbackDays days');
    }
  }

  return callouts.take(2).toList();
}

/// Days remaining until the next streak achievement milestone.
int? daysToStreakMilestone(int streak) {
  const milestones = [7, 30];
  for (final target in milestones) {
    if (streak < target) return target - streak;
  }
  return null;
}

/// Human-readable streak nudge for achievement proximity.
String? streakAchievementNudge(int streak) {
  final remaining = daysToStreakMilestone(streak);
  if (remaining == null || remaining > 3) return null;

  if (streak < 7) {
    return '$remaining day${remaining == 1 ? '' : 's'} to 7-day streak badge';
  }
  if (streak < 30) {
    return '$remaining day${remaining == 1 ? '' : 's'} to Iron Streak title';
  }
  return null;
}
