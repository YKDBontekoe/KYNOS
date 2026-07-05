import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/colors.dart';
import 'package:kynos/shared/widgets/kynos_bottom_nav.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

Widget _wrap(Widget child, {ThemeData? theme}) => MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Scaffold(bottomNavigationBar: child),
    );

void main() {
  const items = [
    KynosBottomNavItem(label: 'Today', icon: NavIconPaths.today),
    KynosBottomNavItem(label: 'Training', icon: NavIconPaths.training),
    KynosBottomNavItem(label: 'Character', icon: NavIconPaths.character),
  ];

  group('KynosBottomNav', () {
    testWidgets('renders all tab labels', (tester) async {
      await tester.pumpWidget(
        _wrap(
          KynosBottomNav(
            items: items,
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Training'), findsOneWidget);
      expect(find.text('Character'), findsOneWidget);
    });

    testWidgets('tapping Training invokes onSelected with index 1', (tester) async {
      int? selected;
      await tester.pumpWidget(
        _wrap(
          KynosBottomNav(
            items: items,
            selectedIndex: 0,
            onSelected: (i) => selected = i,
          ),
        ),
      );

      await tester.tap(find.text('Training'));
      await tester.pump();

      expect(selected, 1);
    });

    testWidgets('tapping the already-selected tab does not invoke onSelected',
        (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        _wrap(
          KynosBottomNav(
            items: items,
            selectedIndex: 0,
            onSelected: (_) => tapCount++,
          ),
        ),
      );

      await tester.tap(find.text('Today'));
      await tester.pump();

      expect(tapCount, 0);
    });

    testWidgets('selected tab is marked in semantics', (tester) async {
      await tester.pumpWidget(
        _wrap(
          KynosBottomNav(
            items: items,
            selectedIndex: 1,
            onSelected: (_) {},
          ),
        ),
      );

      final trainingSemantics = tester.getSemantics(find.text('Training'));
      expect(
        trainingSemantics.flagsCollection.isSelected,
        Tristate.isTrue,
      );

      final todaySemantics = tester.getSemantics(find.text('Today'));
      expect(
        todaySemantics.flagsCollection.isSelected,
        Tristate.isFalse,
      );
    });

    testWidgets('selected tab icon uses stand color and filled style',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          KynosBottomNav(
            items: items,
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );

      NavIconPainter? selectedPainter;
      for (final paint in tester.widgetList<CustomPaint>(
        find.byType(CustomPaint),
      )) {
        if (paint.painter is NavIconPainter) {
          selectedPainter = paint.painter! as NavIconPainter;
          break;
        }
      }

      expect(selectedPainter, isNotNull);
      expect(selectedPainter!.color, KynosColors.stand);
      expect(selectedPainter.filled, isTrue);
    });

    testWidgets('unselected tab icon uses outline style', (tester) async {
      await tester.pumpWidget(
        _wrap(
          KynosBottomNav(
            items: items,
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );

      final painters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((w) => w.painter)
          .whereType<NavIconPainter>()
          .toList();

      expect(painters.length, greaterThanOrEqualTo(3));
      expect(painters.where((p) => !p.filled).length, 2);
    });

    testWidgets('renders in dark theme with glass border', (tester) async {
      await tester.pumpWidget(
        _wrap(
          KynosBottomNav(
            items: items,
            selectedIndex: 0,
            onSelected: (_) {},
          ),
          theme: AppTheme.dark,
        ),
      );

      expect(find.byType(KynosBottomNav), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('light mode golden', (tester) async {
      await tester.pumpWidget(
        _wrap(
          KynosBottomNav(
            items: items,
            selectedIndex: 1,
            onSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/kynos_bottom_nav_light.png'),
      );
    });

    testWidgets('dark mode golden', (tester) async {
      await tester.pumpWidget(
        _wrap(
          KynosBottomNav(
            items: items,
            selectedIndex: 1,
            onSelected: (_) {},
          ),
          theme: AppTheme.dark,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/kynos_bottom_nav_dark.png'),
      );
    });
  });
}
