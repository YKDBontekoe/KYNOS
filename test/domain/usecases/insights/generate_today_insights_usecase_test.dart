import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/usecases/insights/generate_today_insights_usecase.dart';

import '../../../support/fake_ai_repositories.dart';

void main() {
  group('GenerateTodayInsightsUseCase', () {
    test('returns deterministic insights when model is unavailable', () async {
      final today = HealthSummary(
        date: DateTime(2026, 4, 20),
        hrvMs: 38,
        rhrBpm: 63,
        sleepHours: 6.2,
        bloodOxygenPercent: 97,
        runningWorkoutDistanceMeters: 7200,
        steps: 10720,
      );
      final yesterday = HealthSummary(
        date: DateTime(2026, 4, 19),
        hrvMs: 44,
        rhrBpm: 58,
        sleepHours: 7.1,
      );

      final useCase = GenerateTodayInsightsUseCase(
        healthRepository: _FakeHealthRepository(
          today: today,
          history: <HealthSummary>[yesterday, today],
        ),
        aiCoachRepository: FakeAiCoachRepository(),
        aiModelRepository: FakeAiModelRepository(hasActiveModel: false),
      );

      final result = await useCase();

      expect(result.failure, isNull);
      expect(result.usedModel, isFalse);
      expect(result.insights, isNotNull);
      expect(result.insights!.whatChanged, isNotEmpty);
      expect(result.insights!.riskFlags, isNotEmpty);
      expect(result.insights!.actionNow, isNotEmpty);
      expect(result.insights!.actionTonight, isNotEmpty);
    });

    test('returns failure when no today health summary exists', () async {
      final useCase = GenerateTodayInsightsUseCase(
        healthRepository: _FakeHealthRepository(
          today: null,
          history: const <HealthSummary>[],
        ),
        aiCoachRepository: FakeAiCoachRepository(),
        aiModelRepository: FakeAiModelRepository(hasActiveModel: false),
      );

      final result = await useCase();

      expect(result.insights, isNull);
      expect(result.failure, isA<HealthDataFailure>());
      expect(result.usedModel, isFalse);
    });
  });
}

class _FakeHealthRepository implements HealthRepository {
  _FakeHealthRepository({
    required this.today,
    required List<HealthSummary> history,
  }) : _history = history;

  final HealthSummary? today;
  final List<HealthSummary> _history;

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    return (summaries: _history, failure: null);
  }

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    return (summary: today, failure: null);
  }

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<bool> hasPermissions() async => true;

  @override
  Future<({WorkoutSession? workout, Failure? failure})> getWorkoutById({
    required String workoutId,
  }) async =>
      (workout: null, failure: null);

  @override
  Future<({Failure? failure, List<WorkoutSession> runs})> getRecentRuns({
    required int days,
    int limit = 30,
  }) async {
    return (runs: const <WorkoutSession>[], failure: null);
  }

  @override
  Future<({Failure? failure, List<WorkoutRoutePoint> points})> getRunRoute({
    required String workoutUuid,
  }) async {
    return (points: const <WorkoutRoutePoint>[], failure: null);
  }
}
