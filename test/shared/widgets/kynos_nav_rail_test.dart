import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/shared/widgets/kynos_nav_rail.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

void main() {
  const items = [
    KynosNavRailItem(label: 'Coach', icon: NavIconPaths.coach),
    KynosNavRailItem(label: 'Health', icon: NavIconPaths.training),
    KynosNavRailItem(label: 'Journey', icon: NavIconPaths.character),
  ];

  group('KynosNavRail', () {
    testWidgets('renders all rail items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KynosNavRail(
              items: items,
              selectedIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(KynosNavRail), findsOneWidget);
      expect(find.byTooltip('Coach'), findsOneWidget);
      expect(find.byTooltip('Health'), findsOneWidget);
      expect(find.byTooltip('Journey'), findsOneWidget);
    });

    testWidgets('calls onSelected when tapping a different item', (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KynosNavRail(
              items: items,
              selectedIndex: selected,
              onSelected: (index) => selected = index,
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Health'));
      await tester.pump();

      expect(selected, 1);
    });
  });
}
