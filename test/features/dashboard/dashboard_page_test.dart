import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';

void main() {
  final summary = HealthSummary(
    date: DateTime(2026, 4, 20),
    hrvMs: 55,
    rhrBpm: 58,
    sleepHours: 7.5,
    bloodOxygenPercent: 98,
    activeCalories: 420,
    exerciseMinutes: 35,
    runningWorkoutCount: 1,
    runningWorkoutDistanceMeters: 5200,
  );

  const insightsState = TodayInsightsState(
    insights: TodayInsights(
      readinessBrief: 'Solid readiness. Tempo work fits today.',
      whatChanged: <String>['Recovery improved to 55 ms (+4 vs yesterday).'],
      riskFlags: <String>['No strong risk signal today.'],
      actionNow: 'Run quality as planned. Start controlled.',
      actionTonight: 'Hydrate and hit protein to support tomorrow.',
      evidence: <String>['Recovery 55 ms', 'Resting pulse 58 bpm'],
      confidence: InsightConfidence.high,
    ),
    usedModel: false,
    failureMessage: null,
  );

  List<dynamic> defaultOverrides({
    required Future<HealthSummary?> Function(Ref ref) health,
    required Future<TodayInsightsState> Function(Ref ref) insights,
    List<HealthSummary> history = const [],
  }) {
    return [
      healthSummaryProvider.overrideWith(health),
      todayInsightsStateProvider.overrideWith(insights),
      healthHistoryProvider(days: 7).overrideWith((ref) async => history),
      recentRunsProvider(days: 30, limit: 1).overrideWith((ref) async => const []),
      dailyQuestsProvider.overrideWith((ref) async => const []),
    ];
  }

  Widget buildDashboard({required List<dynamic> providerOverrides}) {
    return ProviderScope(
      overrides: providerOverrides.cast(),
      child: const MaterialApp(home: DashboardPage()),
    );
  }

  testWidgets('DashboardPage renders readiness and insight sections', (tester) async {
    await tester.pumpWidget(
      buildDashboard(
        providerOverrides: defaultOverrides(
          health: (ref) async => summary,
          insights: (ref) async => insightsState,
          history: [summary],
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('KYNOS'), findsOneWidget);
    expect(find.text('READINESS'), findsOneWidget);
    expect(find.text('Solid readiness. Tempo work fits today.'), findsOneWidget);
    expect(find.text('Quick Changes'), findsOneWidget);
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('Ask Coach'), findsOneWidget);
  });

  testWidgets('DashboardPage shows loading shimmer for metrics', (tester) async {
    await tester.pumpWidget(
      buildDashboard(
        providerOverrides: defaultOverrides(
          health: (ref) => Completer<HealthSummary?>().future,
          insights: (ref) async => insightsState,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Loading readiness...'), findsOneWidget);
  });

  testWidgets('DashboardPage shows insight failure with retry', (tester) async {
    const failedState = TodayInsightsState(
      insights: null,
      usedModel: false,
      failureMessage: 'Could not generate today insights.',
    );

    await tester.pumpWidget(
      buildDashboard(
        providerOverrides: defaultOverrides(
          health: (ref) async => summary,
          insights: (ref) async => failedState,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Could not generate today insights.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('DashboardPage pull-to-refresh triggers reload', (tester) async {
    var loadCount = 0;

    await tester.pumpWidget(
      buildDashboard(
        providerOverrides: defaultOverrides(
          health: (ref) async {
            loadCount++;
            return summary;
          },
          insights: (ref) async => insightsState,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(loadCount, 1);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(loadCount, greaterThan(1));
  });
}

