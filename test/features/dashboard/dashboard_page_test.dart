import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/entities/insights/insight_confidence.dart';
import 'package:kynos/domain/entities/insights/today_insights.dart';
import 'package:kynos/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/providers/health_providers.dart';

void main() {
  testWidgets('DashboardPage renders readiness and insight sections', (tester) async {
    final summary = HealthSummary(
      date: DateTime(2026, 4, 20),
      hrvMs: 55,
      rhrBpm: 58,
      sleepHours: 7.5,
      bloodOxygenPercent: 98,
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthSummaryProvider.overrideWith((ref) async => summary),
          todayInsightsStateProvider.overrideWith((ref) async => insightsState),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('KYNOS'), findsOneWidget);
    expect(find.text('READINESS'), findsOneWidget);
    expect(find.text('Solid readiness. Tempo work fits today.'), findsOneWidget);
    expect(find.text('Quick Changes'), findsOneWidget);
  });
}
