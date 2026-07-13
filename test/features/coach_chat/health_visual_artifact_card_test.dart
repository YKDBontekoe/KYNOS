import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_metric.dart';
import 'package:kynos/domain/entities/health/health_visual_artifact.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/health_visual_artifact_card.dart';

void main() {
  final end = DateTime(2026, 7, 13);
  final artifact = HealthVisualArtifact.trend(
    meta: HealthArtifactMeta(
      id: 'sleep-trend',
      title: 'Sleep and energy',
      explanation: 'A local view of available observations.',
      start: end.subtract(const Duration(days: 6)),
      end: end,
      confidence: FindingConfidence.moderate,
      evidenceReferences: const ['Health data', 'Daily check-in'],
      limitations: const ['Two observations are missing.'],
    ),
    series: [
      HealthSeries(
        id: 'sleep',
        label: 'Sleep',
        metric: HealthMetric.sleep,
        unit: 'h',
        baseline: 7.3,
        points: [
          for (var index = 0; index < 7; index++)
            HealthDataPoint(
              date: end.subtract(Duration(days: 6 - index)),
              value: 6.5 + index * 0.15,
            ),
        ],
      ),
    ],
  );

  testWidgets('offers chart, accessible table, provenance, and follow-up', (
    tester,
  ) async {
    String? followUp;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: HealthVisualArtifactCard(
              artifact: artifact,
              onExplore: (value) => followUp = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sleep and energy'), findsOneWidget);
    expect(find.textContaining('Two observations'), findsOneWidget);
    expect(find.byType(Semantics), findsWidgets);

    await tester.tap(find.byTooltip('Show accessible table'));
    await tester.pump();
    expect(find.text('7/7'), findsOneWidget);
    expect(find.text('6.5 h'), findsOneWidget);

    await tester.tap(find.text('Ask KYNOS'));
    expect(followUp, contains('Sleep and energy'));
  });

  testWidgets('does not fall back to old points for an empty range', (
    tester,
  ) async {
    final oldArtifact = HealthVisualArtifact.trend(
      meta: artifact.meta,
      series: [
        HealthSeries(
          id: 'old-sleep',
          label: 'Sleep',
          metric: HealthMetric.sleep,
          unit: 'h',
          points: [HealthDataPoint(date: DateTime(2025, 1, 1), value: 7.0)],
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HealthVisualArtifactCard(
            artifact: oldArtifact,
            onExplore: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.text('No data available for the selected range.'),
      findsOneWidget,
    );
  });
}
