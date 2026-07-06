import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/features/dashboard/presentation/pages/run_route_page.dart';
import 'package:kynos/shared/providers/health_providers.dart';

void main() {
  final run = WorkoutSession(
    id: 'run-test-1',
    start: DateTime.utc(2026, 4, 20, 8),
    end: DateTime.utc(2026, 4, 20, 8, 40),
    workoutType: 'running',
    distanceMeters: 5000,
    energyKcal: 420,
    sourceName: 'Apple Watch',
  );

  final routePoints = List<WorkoutRoutePoint>.generate(51, (i) {
    return WorkoutRoutePoint(
      latitude: 51.5 + (i * 100) / 111000,
      longitude: -0.12,
      timestamp: run.start.add(Duration(seconds: i * 48)),
    );
  });

  Widget buildPage() {
    return ProviderScope(
      overrides: [
        runRouteProvider(workoutUuid: run.id).overrideWith(
          (ref) async => routePoints,
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: RunRoutePage(run: run),
      ),
    );
  }

  testWidgets('RunRoutePage renders summary metrics and split sections', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Avg Pace'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('PACE PROFILE'), findsOneWidget);
    expect(find.text('KILOMETER SPLITS'), findsOneWidget);
    expect(find.text('5.00'), findsOneWidget);
    expect(find.textContaining('Km '), findsWidgets);
    expect(find.text('All data stays on your device'), findsOneWidget);
  });
}
