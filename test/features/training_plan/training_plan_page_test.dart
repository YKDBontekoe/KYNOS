import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/repositories/training_plan_repository.dart';
import 'package:kynos/features/training_plan/presentation/pages/training_plan_page.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:kynos/shared/providers/training_plan_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('TrainingPlanPage empty state offers build CTA', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          trainingPlanRepositoryProvider.overrideWithValue(
            _FakeTrainingPlanRepository(plan: null),
          ),
        ],
        child: const MaterialApp(home: TrainingPlanPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Training plan'), findsWidgets);
    expect(find.text('Build my plan'), findsOneWidget);
  });

  testWidgets('TrainingPlanPage renders week calendar for active plan', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final monday = DateTime(2026, 7, 13);
    final plan = TrainingPlan(
      id: 'p1',
      title: 'Race prep',
      goal: 'half marathon',
      startDate: monday,
      weeks: 1,
      createdAt: monday,
      weeklyVolumeTargetKm: 40,
      days: [
        for (var i = 0; i < 7; i++)
          PlanDay(
            date: monday.add(Duration(days: i)),
            sessionType: i == 1 || i == 5
                ? PlanSessionType.rest
                : PlanSessionType.easy,
            title: i == 1 || i == 5 ? 'Rest' : 'Easy run',
            targetDistanceKm: i == 1 || i == 5 ? null : 6,
          ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          trainingPlanRepositoryProvider.overrideWithValue(
            _FakeTrainingPlanRepository(plan: plan),
          ),
        ],
        child: const MaterialApp(home: TrainingPlanPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Race prep'), findsOneWidget);
    expect(find.text('half marathon'), findsOneWidget);
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('Ask coach'), findsOneWidget);
  });
}

class _FakeTrainingPlanRepository implements TrainingPlanRepository {
  _FakeTrainingPlanRepository({required this.plan});

  final TrainingPlan? plan;

  @override
  Future<({TrainingPlan? value, Failure? failure})> loadActive() async =>
      (value: plan, failure: null);

  @override
  Future<({bool? value, Failure? failure})> save(TrainingPlan plan) async =>
      (value: true, failure: null);

  @override
  Future<({bool? value, Failure? failure})> clear() async =>
      (value: true, failure: null);
}
