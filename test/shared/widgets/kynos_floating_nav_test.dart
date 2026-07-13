import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/shared/widgets/kynos_floating_nav.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

void main() {
  const items = [
    KynosFloatingNavItem(label: 'Coach', icon: NavIconPaths.coach),
    KynosFloatingNavItem(label: 'Health', icon: NavIconPaths.training),
    KynosFloatingNavItem(label: 'Journey', icon: NavIconPaths.character),
  ];

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('kynos_floating_nav_control')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('KynosFloatingNav', () {
    testWidgets('renders floating nav button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KynosFloatingNav(
              items: items,
              selectedIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(KynosFloatingNav), findsOneWidget);
      expect(find.byKey(const Key('kynos_floating_nav_control')), findsOneWidget);
    });

    testWidgets('expands options when tapping the fab', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KynosFloatingNav(
              items: items,
              selectedIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      await openMenu(tester);

      expect(find.byTooltip('Coach'), findsOneWidget);
      expect(find.byTooltip('Health'), findsOneWidget);
      expect(find.byTooltip('Journey'), findsOneWidget);
    });

    testWidgets('calls onSelected when tapping a different item', (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KynosFloatingNav(
              items: items,
              selectedIndex: selected,
              onSelected: (index) => selected = index,
            ),
          ),
        ),
      );

      await openMenu(tester);

      await tester.tap(find.byTooltip('Health'));
      await tester.pump();

      expect(selected, 1);
    });

    testWidgets('moves when dragged', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KynosFloatingNav(
              items: items,
              selectedIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      final control = find.byKey(const Key('kynos_floating_nav_control'));
      final initialRect = tester.getRect(control);
      await tester.drag(control, const Offset(80, -40), warnIfMissed: false);
      await tester.pump();

      expect(tester.getRect(control), isNot(equals(initialRect)));
    });
  });
}
