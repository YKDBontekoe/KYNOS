import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/domain/entities/gamification/camp_resources.dart';
import 'package:kynos/features/character/presentation/widgets/camp_resources_bar.dart';

void main() {
  testWidgets('CampResourcesBar shows four resource labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: CampResourcesBar(
            resources: CampResources(
              totalMomentum: 5,
              totalFuel: 5,
              totalFocus: 3,
              totalSpirit: 0,
              spentMomentum: 0,
              spentFuel: 0,
              spentFocus: 0,
              spentSpirit: 0,
            ),
          ),
        ),
      ),
    );

    expect(find.text('MOMENTUM'), findsOneWidget);
    expect(find.text('FUEL'), findsOneWidget);
    expect(find.text('FOCUS'), findsOneWidget);
    expect(find.text('SPIRIT'), findsOneWidget);
  });
}
