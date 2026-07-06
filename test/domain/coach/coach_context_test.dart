import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/usecases/coach/build_coach_context_usecase.dart';
import 'package:kynos/domain/utils/coach_context_formatter.dart';
import 'package:kynos/domain/utils/weekly_momentum.dart';

void main() {
  group('BuildCoachContextUseCase', () {
    const useCase = BuildCoachContextUseCase();

    test('computes readiness and ACWR from health history', () {
      final history = List.generate(
        28,
        (i) => HealthSummary(
          date: DateTime(2026, 6, 10).add(Duration(days: i)),
          hrvMs: (50 + i).toDouble(),
          rhrBpm: 50,
          sleepHours: 7,
          runningWorkoutDistanceMeters: 5000,
        ),
      );

      final context = useCase.call(
        healthHistory: history,
        recentRuns: const [],
      );

      expect(context.readinessScore, greaterThan(0));
      expect(context.acwr, isNotNull);
      expect(context.acwrRiskLabel, isNotNull);
    });

    test('prioritizes focus run from seed', () {
      final runA = WorkoutSession(
        id: 'a',
        start: DateTime(2026, 7, 5, 8),
        end: DateTime(2026, 7, 5, 9),
        workoutType: 'run',
        distanceMeters: 5000,
        sourceName: 'test',
      );
      final runB = WorkoutSession(
        id: 'b',
        start: DateTime(2026, 7, 6, 8),
        end: DateTime(2026, 7, 6, 9),
        workoutType: 'run',
        distanceMeters: 8000,
        sourceName: 'test',
      );

      final context = useCase.call(
        healthHistory: const [],
        recentRuns: [runB, runA],
        seed: const CoachChatSeedData(
          runId: 'a',
          topic: CoachSeedTopic.run,
        ),
      );

      expect(context.recentRuns.first.id, 'a');
      expect(context.focusRunId, 'a');
      expect(context.seedTopic, CoachSeedTopic.run);
    });

    test('includes active quests only', () {
      final quests = [
        Quest(
          id: '1',
          type: QuestType.daily,
          difficulty: QuestDifficulty.normal,
          title: 'Morning miles',
          narrative: 'Run',
          objective: 'Run 5km',
          status: QuestStatus.active,
          xpReward: 50,
          statRewards: const {},
          generatedAt: DateTime(2026, 7, 6),
          expiresAt: DateTime(2026, 7, 7),
        ),
        Quest(
          id: '2',
          type: QuestType.daily,
          difficulty: QuestDifficulty.easy,
          title: 'Done',
          narrative: 'Done',
          objective: 'Rest',
          status: QuestStatus.completed,
          xpReward: 10,
          statRewards: const {},
          generatedAt: DateTime(2026, 7, 5),
          expiresAt: DateTime(2026, 7, 6),
          completedAt: DateTime(2026, 7, 5),
        ),
      ];

      final context = useCase.call(
        healthHistory: const [],
        recentRuns: const [],
        activeQuests: quests,
      );

      expect(context.activeQuests, hasLength(1));
      expect(context.activeQuests.first.id, '1');
    });
  });

  group('CoachContextFormatter', () {
    test('includes readiness and health metrics', () {
      final context = BuildCoachContextUseCase().call(
        healthHistory: [
          HealthSummary(
            date: DateTime(2026, 7, 6),
            hrvMs: 55,
            rhrBpm: 48,
            sleepHours: 8,
            runningWorkoutDistanceMeters: 6000,
          ),
        ],
        recentRuns: [
          WorkoutSession(
            id: 'r1',
            start: DateTime(2026, 7, 6, 7),
            end: DateTime(2026, 7, 6, 8),
            workoutType: 'run',
            distanceMeters: 6000,
            sourceName: 'health',
          ),
        ],
        todayInsights: const TodayInsights(
          readinessBrief: 'Solid recovery',
          whatChanged: [],
          riskFlags: [],
          actionNow: 'Easy aerobic run',
          actionTonight: 'Sleep 8h',
          evidence: [],
          confidence: InsightConfidence.high,
        ),
        weeklyMomentum: const WeeklyMomentum(
          thisWeekDistanceKm: 12,
          thisWeekRuns: 2,
          thisWeekActiveKcal: 800,
          distanceGoalKm: 30,
          distanceGoalProgress: 0.4,
        ),
      );

      final formatted = CoachContextFormatter.formatForPrompt(context);

      expect(formatted, contains('Readiness:'));
      expect(formatted, contains('Health metrics:'));
      expect(formatted, contains('Recent runs:'));
      expect(formatted, contains('Weekly goal:'));
      expect(formatted, contains('Today insight:'));
      expect(CoachContextFormatter.containsNoGpsLeakage(formatted), isTrue);
    });

    test('does not leak GPS coordinates from runs with route data', () {
      final context = BuildCoachContextUseCase().call(
        healthHistory: const [],
        recentRuns: [
          WorkoutSession(
            id: 'r1',
            start: DateTime(2026, 7, 6, 7),
            end: DateTime(2026, 7, 6, 8),
            workoutType: 'run',
            distanceMeters: 5000,
            sourceName: 'health',
            startLatitude: 37.7749,
            startLongitude: -122.4194,
            endLatitude: 37.7849,
            endLongitude: -122.4094,
          ),
        ],
      );

      final formatted = CoachContextFormatter.formatForPrompt(context);

      expect(formatted, isNot(contains('37.77')));
      expect(formatted, isNot(contains('-122')));
      expect(CoachContextFormatter.containsNoGpsLeakage(formatted), isTrue);
    });

    test('respects character limit', () {
      final longHistory = List.generate(
        14,
        (i) => HealthSummary(
          date: DateTime(2026, 7, 1).add(Duration(days: i)),
          hrvMs: 50,
          rhrBpm: 50,
          sleepHours: 7,
          runningWorkoutDistanceMeters: 10000,
          steps: 15000,
          activeCalories: 500,
          exerciseMinutes: 60,
        ),
      );

      final context = BuildCoachContextUseCase().call(
        healthHistory: longHistory,
        recentRuns: List.generate(
          5,
          (i) => WorkoutSession(
            id: '$i',
            start: DateTime(2026, 7, 1).add(Duration(days: i)),
            end: DateTime(2026, 7, 1).add(Duration(days: i, hours: 1)),
            workoutType: 'run',
            distanceMeters: 10000,
            sourceName: 'test',
          ),
        ),
        todayInsights: TodayInsights(
          readinessBrief: 'A' * 200,
          whatChanged: const ['change'],
          riskFlags: const ['risk'],
          actionNow: 'B' * 200,
          actionTonight: 'C' * 200,
          evidence: const ['evidence'],
          confidence: InsightConfidence.medium,
        ),
      );

      final formatted = CoachContextFormatter.formatForPrompt(context);
      expect(formatted.length, lessThanOrEqualTo(2048));
    });
  });
}
