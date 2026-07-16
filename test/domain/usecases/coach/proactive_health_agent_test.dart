import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/cloud_llm_endpoint.dart';
import 'package:kynos/domain/entities/coach/coach_context.dart';
import 'package:kynos/domain/entities/coach/today_directive.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/domain/usecases/coach/build_morning_fact_pack_usecase.dart';
import 'package:kynos/domain/usecases/coach/build_proactive_health_agent_run_usecase.dart';

void main() {
  group('CloudLlmEndpoint', () {
    test('normalizes trailing slashes', () {
      expect(
        CloudLlmEndpoint.normalizeBaseUrl('https://api.openai.com/v1/'),
        'https://api.openai.com/v1',
      );
    });

    test('detects OpenRouter preset', () {
      expect(
        CloudLlmEndpoint.isOpenRouter(CloudLlmEndpoint.openRouterBaseUrl),
        isTrue,
      );
      expect(
        CloudLlmEndpoint.isOpenRouter('https://api.openai.com/v1'),
        isFalse,
      );
    });
  });

  group('BuildMorningFactPackUseCase', () {
    test('builds compact morning prompt under 220 chars', () {
      final pack = const BuildMorningFactPackUseCase().call(
        context: CoachContext(
          readinessScore: 68,
          readinessSummary: 'Moderate',
          acwr: 1.1,
          healthHistory: [
            HealthSummary(
              date: DateTime(2026, 7, 16),
              sleepHours: 7.2,
              hrvMs: 48,
            ),
          ],
          todayDirective: const TodayDirective(
            headline: 'Easy 8 km',
            detail: 'Keep conversational',
            source: TodayDirectiveSource.plan,
            rationale: ['readiness ok'],
            sessionType: PlanSessionType.easy,
          ),
        ),
      );

      expect(pack.readinessBand, 'moderate');
      expect(pack.acwrBand, 'productive');
      expect(pack.promptBlock.startsWith('MORNING:'), isTrue);
      expect(pack.promptBlock.length, lessThanOrEqualTo(220));
      expect(pack.hasRisk, isFalse);
    });

    test('flags elevated ACWR as risk', () {
      final pack = const BuildMorningFactPackUseCase().call(
        context: const CoachContext(
          readinessScore: 40,
          readinessSummary: 'Low',
          acwr: 1.45,
        ),
      );
      expect(pack.hasRisk, isTrue);
      expect(pack.acwrBand, 'elevated');
    });
  });

  group('BuildProactiveHealthAgentRunUseCase', () {
    test('morning pulse always present; risk when ACWR high', () {
      const useCase = BuildProactiveHealthAgentRunUseCase();
      final context = CoachContext(
        readinessScore: 42,
        readinessSummary: 'Low',
        acwr: 1.5,
        recentRuns: [
          WorkoutSession(
            id: 'r1',
            start: DateTime(2026, 7, 15, 7),
            end: DateTime(2026, 7, 15, 8),
            workoutType: 'running',
            distanceMeters: 10000,
            sourceName: 'test',
          ),
        ],
      );

      final runs = useCase.buildHomeRuns(context: context);
      expect(
        runs.any((r) => r.kind == ProactiveHealthAgentKind.morningPulse),
        isTrue,
      );
      expect(
        runs.any((r) => r.kind == ProactiveHealthAgentKind.riskRadar),
        isTrue,
      );
      expect(
        runs.any((r) => r.kind == ProactiveHealthAgentKind.postRunDebrief),
        isTrue,
      );
    });
  });
}
