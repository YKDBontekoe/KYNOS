import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/usecases/insights/generate_training_insights_usecase.dart';

void main() {
  group('GenerateTrainingInsightsUseCase', () {
    test(
      'returns deterministic training insights when model is unavailable',
      () async {
        final history = <HealthSummary>[
          HealthSummary(
            date: DateTime(2026, 4, 14),
            runningWorkoutDistanceMeters: 5100,
            sleepHours: 7.2,
            hrvMs: 52,
            rhrBpm: 56,
          ),
          HealthSummary(
            date: DateTime(2026, 4, 18),
            runningWorkoutDistanceMeters: 8400,
            sleepHours: 6.5,
            hrvMs: 43,
            rhrBpm: 60,
          ),
          HealthSummary(
            date: DateTime(2026, 4, 20),
            sleepHours: 6.1,
            hrvMs: 36,
            rhrBpm: 65,
          ),
        ];

        final runs = <WorkoutSession>[
          WorkoutSession(
            id: 'run-1',
            start: DateTime(2026, 4, 19, 8),
            end: DateTime(2026, 4, 19, 8, 45),
            workoutType: 'running',
            distanceMeters: 9000,
            sourceName: 'Watch',
          ),
        ];

        final useCase = GenerateTrainingInsightsUseCase(
          healthRepository: _FakeHealthRepository(
            today: history.last,
            history: history,
            runs: runs,
          ),
          aiCoachRepository: _FakeAiCoachRepository(),
          aiModelRepository: _FakeAiModelRepository(hasActiveModel: false),
        );

        final result = await useCase();

        expect(result.failure, isNull);
        expect(result.usedModel, isFalse);
        expect(result.insights, isNotNull);
        expect(result.insights!.sessionIntent, contains('Intent:'));
        expect(result.insights!.adjustmentHints, isNotEmpty);
        expect(result.insights!.postSessionDebrief, isNotEmpty);
      },
    );

    test('propagates failure from health repository', () async {
      final useCase = GenerateTrainingInsightsUseCase(
        healthRepository: _FakeHealthRepository(
          today: null,
          history: const <HealthSummary>[],
          runs: const <WorkoutSession>[],
          summariesFailure: const HealthDataFailure('history error'),
        ),
        aiCoachRepository: _FakeAiCoachRepository(),
        aiModelRepository: _FakeAiModelRepository(hasActiveModel: false),
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
    required List<WorkoutSession> runs,
    this.summariesFailure,
    this.runsFailure,
    this.todayFailure,
  }) : _history = history,
       _runs = runs;

  final HealthSummary? today;
  final List<HealthSummary> _history;
  final List<WorkoutSession> _runs;
  final Failure? summariesFailure;
  final Failure? runsFailure;
  final Failure? todayFailure;

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    return (summaries: _history, failure: summariesFailure);
  }

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    return (summary: today, failure: todayFailure);
  }

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<({Failure? failure, List<WorkoutSession> runs})> getRecentRuns({
    required int days,
    int limit = 30,
  }) async {
    return (runs: _runs, failure: runsFailure);
  }

  @override
  Future<({Failure? failure, List<WorkoutRoutePoint> points})> getRunRoute({
    required String workoutUuid,
  }) async {
    return (points: const <WorkoutRoutePoint>[], failure: null);
  }
}

class _FakeAiCoachRepository implements AiCoachRepository {
  @override
  bool get isReady => true;

  @override
  Stream<AiChunk> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
  }) async* {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> resetSession() async {}
}

class _FakeAiModelRepository implements AiModelRepository {
  _FakeAiModelRepository({required this.hasActiveModel});

  @override
  final bool hasActiveModel;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> installFromNetwork({required String url, String? token}) async {}
}
