import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/utils/metric_trends.dart';
import 'package:kynos/domain/utils/personal_bests.dart';
import 'package:kynos/domain/utils/run_streak.dart';
import 'package:kynos/domain/utils/weekly_momentum.dart';

void main() {
  group('computeMetricDelta', () {
    test('returns improved when HRV increases', () {
      final delta = computeMetricDelta(
        today: 60,
        baseline: 55,
        higherIsBetter: true,
      );

      expect(delta?.improved, isTrue);
      expect(delta?.direction, TrendDirection.up);
      expect(delta?.delta, 5);
    });

    test('returns not improved when resting pulse increases', () {
      final delta = computeMetricDelta(
        today: 65,
        baseline: 58,
        higherIsBetter: false,
      );

      expect(delta?.improved, isFalse);
      expect(delta?.direction, TrendDirection.up);
    });

    test('returns null when values missing', () {
      expect(
        computeMetricDelta(today: null, baseline: 50, higherIsBetter: true),
        isNull,
      );
    });
  });

  group('formatMetricDeltaSublabel', () {
    test('prefers yesterday delta over 7-day average', () {
      final label = formatMetricDeltaSublabel(
        vsYesterday: const MetricDelta(
          delta: 4,
          pct: 7,
          direction: TrendDirection.up,
          improved: true,
        ),
        vs7DayAvg: const MetricDelta(
          delta: 2,
          pct: 3,
          direction: TrendDirection.up,
          improved: true,
        ),
        unit: 'ms',
      );

      expect(label, '+4 ms vs yesterday');
    });
  });

  group('computeRunStreakFromSummaries', () {
    test('counts consecutive run days', () {
      final now = DateTime(2026, 4, 20);
      final history = [
        HealthSummary(
          date: now,
          runningWorkoutCount: 1,
        ),
        HealthSummary(
          date: now.subtract(const Duration(days: 1)),
          runningWorkoutCount: 1,
        ),
        HealthSummary(
          date: now.subtract(const Duration(days: 2)),
          runningWorkoutCount: 1,
        ),
        HealthSummary(
          date: now.subtract(const Duration(days: 3)),
          runningWorkoutCount: 0,
        ),
      ];

      expect(
        computeRunStreakFromSummaries(history, asOf: now),
        3,
      );
    });
  });

  group('computeRunStreakFromRuns', () {
    test('counts streak from workout sessions', () {
      final now = DateTime(2026, 4, 20, 8);
      final runs = [
        WorkoutSession(
          id: '1',
          start: now,
          end: now.add(const Duration(minutes: 30)),
          workoutType: 'running',
          sourceName: 'HealthKit',
        ),
        WorkoutSession(
          id: '2',
          start: now.subtract(const Duration(days: 1, hours: 2)),
          end: now.subtract(const Duration(days: 1)),
          workoutType: 'running',
          sourceName: 'HealthKit',
        ),
      ];

      expect(computeRunStreakFromRuns(runs, asOf: now), 2);
    });
  });

  group('computeWeeklyMomentum', () {
    test('computes week-over-week distance delta', () {
      final now = DateTime.now();
      final history = <HealthSummary>[
        for (var i = 0; i < 7; i++)
          HealthSummary(
            date: now.subtract(Duration(days: i)),
            runningWorkoutDistanceMeters: 5000,
            runningWorkoutCount: 1,
            activeCalories: 300,
          ),
        for (var i = 7; i < 14; i++)
          HealthSummary(
            date: now.subtract(Duration(days: i)),
            runningWorkoutDistanceMeters: 2500,
            runningWorkoutCount: 1,
            activeCalories: 200,
          ),
      ];

      final momentum = computeWeeklyMomentum(history);

      expect(momentum.thisWeekDistanceKm, closeTo(35, 0.1));
      expect(momentum.distanceDeltaPct, closeTo(100, 1));
      expect(momentum.distanceGoalProgress, closeTo(1.0, 0.01));
    });
  });

  group('findPersonalBestCallouts', () {
    test('flags best HRV in lookback window', () {
      final today = DateTime.now();
      final history = [
        HealthSummary(date: today, hrvMs: 72),
        HealthSummary(
          date: today.subtract(const Duration(days: 1)),
          hrvMs: 60,
        ),
        HealthSummary(
          date: today.subtract(const Duration(days: 2)),
          hrvMs: 58,
        ),
      ];

      final callouts = findPersonalBestCallouts(history, history.first);

      expect(callouts, contains('Best HRV in 14 days'));
    });
  });

  group('streakAchievementNudge', () {
    test('nudges when close to 7-day milestone', () {
      expect(streakAchievementNudge(5), '2 days to 7-day streak badge');
    });

    test('returns null when far from milestone', () {
      expect(streakAchievementNudge(1), isNull);
    });
  });
}
