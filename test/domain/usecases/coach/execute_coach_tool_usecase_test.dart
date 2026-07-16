import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/domain/usecases/coach/build_coach_context_usecase.dart';
import 'package:kynos/domain/usecases/coach/execute_coach_tool_usecase.dart';

void main() {
  late _FakeHealthRepository health;
  late ExecuteCoachToolUseCase useCase;
  late CoachContext context;

  setUp(() {
    health = _FakeHealthRepository();
    useCase = ExecuteCoachToolUseCase(healthRepository: health);
    context = const BuildCoachContextUseCase().call(
      healthHistory: const [],
      recentRuns: const [],
    );
  });

  CoachContextPreferences allEnabled() => CoachContextPreferences.defaults;

  CoachContextPreferences onlyEnabled(Set<CoachDataSource> sources) =>
      CoachContextPreferences(enabledSources: sources);

  group('get_recent_runs', () {
    test('returns formatted recent runs', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(
          name: 'get_recent_runs',
          arguments: {'limit': 2},
        ),
        context: context,
        preferences: allEnabled(),
      );

      expect(result.isError, isFalse);
      expect(result.promptSummary, contains('Runs (last'));
      expect(result.displayLabel, contains('run'));
    });

    test('is disabled when recentRuns data source is off', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(name: 'get_recent_runs'),
        context: context,
        preferences: onlyEnabled({CoachDataSource.healthMetrics}),
      );

      expect(result.isError, isTrue);
      expect(result.promptSummary, contains('disabled'));
    });
  });

  group('get_run_detail', () {
    test('returns an error when run_id is missing', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(name: 'get_run_detail'),
        context: context,
        preferences: allEnabled(),
      );

      expect(result.isError, isTrue);
      expect(result.promptSummary, contains('run_id'));
    });

    test('summarises a run without leaking GPS coordinates', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(
          name: 'get_run_detail',
          arguments: {'run_id': 'r1'},
        ),
        context: context,
        preferences: allEnabled(),
      );

      expect(result.isError, isFalse);
      expect(result.promptSummary, isNot(contains('37.7')));
      expect(result.promptSummary, isNot(contains('-122')));
    });
  });

  group('get_health_trend', () {
    test('summarises a metric trend', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(
          name: 'get_health_trend',
          arguments: {'metric': 'hrv', 'days': 5},
        ),
        context: context,
        preferences: allEnabled(),
      );

      expect(result.isError, isFalse);
      expect(result.promptSummary, contains('Latest HRV'));
      expect(result.visualArtifacts, hasLength(1));
    });

    test('is disabled when healthMetrics data source is off', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(name: 'get_health_trend'),
        context: context,
        preferences: onlyEnabled({CoachDataSource.recentRuns}),
      );

      expect(result.isError, isTrue);
    });
  });

  group('get_training_load', () {
    test('summarises ACWR and weekly momentum from context', () async {
      final richContext = const BuildCoachContextUseCase().call(
        healthHistory: List.generate(
          28,
          (i) => HealthSummary(
            date: DateTime(2026, 6, 10).add(Duration(days: i)),
            runningWorkoutDistanceMeters: i >= 21 ? 10000 : 5000,
          ),
        ),
        recentRuns: const [],
      );

      final result = await useCase.call(
        toolCall: const CoachToolCall(name: 'get_training_load'),
        context: richContext,
        preferences: allEnabled(),
      );

      expect(result.isError, isFalse);
      expect(result.promptSummary, contains('ACWR'));
    });
  });

  group('get_personal_bests', () {
    test('reports no new personal bests with sparse history', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(name: 'get_personal_bests'),
        context: context,
        preferences: allEnabled(),
      );

      expect(result.isError, isFalse);
      expect(result.displayLabel, contains('No new PBs'));
    });
  });

  group('compute_pace_plan', () {
    test('computes an even-split pace for a target time', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(
          name: 'compute_pace_plan',
          arguments: {'distance_km': 10, 'target_time_minutes': 50},
        ),
        context: context,
        preferences: allEnabled(),
      );

      expect(result.isError, isFalse);
      expect(result.promptSummary, contains('5:00 /km'));
    });

    test('errors without a target time', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(
          name: 'compute_pace_plan',
          arguments: {'distance_km': 10},
        ),
        context: context,
        preferences: allEnabled(),
      );

      expect(result.isError, isTrue);
    });

    test('errors without distance_km', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(
          name: 'compute_pace_plan',
          arguments: {'target_time_minutes': 50},
        ),
        context: context,
        preferences: allEnabled(),
      );

      expect(result.isError, isTrue);
      expect(result.promptSummary, contains('distance_km'));
    });
  });

  group('get_health_trend metric validation', () {
    test('rejects unsupported metrics', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(
          name: 'get_health_trend',
          arguments: {'metric': 'calories'},
        ),
        context: context,
        preferences: allEnabled(),
      );

      expect(result.isError, isTrue);
      expect(result.promptSummary, contains('Unsupported metric'));
    });
  });

  group('propose_wellbeing_experiment', () {
    test('builds action text only from the safe catalog', () async {
      final result = await useCase.call(
        toolCall: const CoachToolCall(
          name: 'propose_wellbeing_experiment',
          arguments: {
            'title': 'Morning light',
            'action_id': 'morning_daylight',
            'hypothesis': 'Energy may feel steadier.',
            'duration_days': 7,
          },
        ),
        context: context,
        preferences: allEnabled(),
      );

      expect(result.isError, isFalse);
      expect(
        result.pendingActions.single.payload['action'],
        'Spend ten minutes in morning daylight.',
      );
    });

    test(
      'rejects arbitrary action text even when it contains safe words',
      () async {
        final result = await useCase.call(
          toolCall: const CoachToolCall(
            name: 'propose_wellbeing_experiment',
            arguments: {
              'title': 'Unsafe proposal',
              'action_id': 'take medication then walk',
              'duration_days': 7,
            },
          ),
          context: context,
          preferences: allEnabled(),
        );

        expect(result.isError, isTrue);
        expect(result.pendingActions, isEmpty);
      },
    );
  });

  test('unknown tool name returns an error result', () async {
    final result = await useCase.call(
      toolCall: const CoachToolCall(name: 'not_a_real_tool'),
      context: context,
      preferences: allEnabled(),
    );

    expect(result.isError, isTrue);
    expect(result.promptSummary, contains('Unknown tool'));
  });
}

class _FakeHealthRepository implements HealthRepository {
  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<bool> hasPermissions() async => true;

  @override
  Future<({WorkoutSession? workout, Failure? failure})> getWorkoutById({
    required String workoutId,
  }) async {
    if (workoutId != 'r1') return (workout: null, failure: null);
    return (
      workout: WorkoutSession(
        id: 'r1',
        start: DateTime(2026, 7, 6, 7),
        end: DateTime(2026, 7, 6, 7, 30),
        workoutType: 'run',
        distanceMeters: 5000,
        sourceName: 'test',
        startLatitude: 37.7749,
        startLongitude: -122.4194,
        endLatitude: 37.7849,
        endLongitude: -122.4094,
      ),
      failure: null,
    );
  }

  @override
  Future<({List<HealthSummary> summaries, Failure? failure})> getSummaries({
    required int days,
  }) async {
    return (
      summaries: List.generate(
        days,
        (i) => HealthSummary(
          date: DateTime(2026, 7, 1).subtract(Duration(days: i)),
          hrvMs: 50 + i.toDouble(),
        ),
      ),
      failure: null,
    );
  }

  @override
  Future<({List<WorkoutSession> runs, Failure? failure})> getRecentRuns({
    required int days,
    int limit = 30,
  }) async {
    return (
      runs: [
        WorkoutSession(
          id: 'r1',
          start: DateTime(2026, 7, 6, 7),
          end: DateTime(2026, 7, 6, 7, 30),
          workoutType: 'run',
          distanceMeters: 5000,
          sourceName: 'test',
        ),
        WorkoutSession(
          id: 'r2',
          start: DateTime(2026, 7, 4, 7),
          end: DateTime(2026, 7, 4, 7, 32),
          workoutType: 'run',
          distanceMeters: 5000,
          sourceName: 'test',
        ),
      ],
      failure: null,
    );
  }

  @override
  Future<({List<WorkoutRoutePoint> points, Failure? failure})> getRunRoute({
    required String workoutUuid,
  }) async {
    return (points: const <WorkoutRoutePoint>[], failure: null);
  }

  @override
  Future<({HealthSummary? summary, Failure? failure})> getToday() async {
    return (summary: null, failure: null);
  }
}
