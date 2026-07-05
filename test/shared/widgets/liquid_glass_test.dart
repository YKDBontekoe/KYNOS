import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/shared/widgets/liquid_glass_button.dart';
import 'package:kynos/shared/widgets/liquid_glass_surface.dart';

Widget _wrap(Widget child, {ThemeData? theme}) => MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('LiquidGlassSurface', () {
    testWidgets('applies BackdropFilter and ColorFiltered vibrancy', (tester) async {
      await tester.pumpWidget(
        _wrap(const LiquidGlassSurface(child: Text('Glass'))),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);
      expect(find.text('Glass'), findsOneWidget);
    });

    testWidgets('onAccent mode renders without vibrancy when disabled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LiquidGlassSurface(
            onAccent: true,
            applyVibrancy: false,
            child: Text('Accent'),
          ),
        ),
      );

      expect(find.byType(ColorFiltered), findsNothing);
      expect(find.text('Accent'), findsOneWidget);
    });
  });

  group('LiquidGlassButton', () {
    testWidgets('invokes onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          LiquidGlassButton(
            label: 'Ask Coach',
            onPressed: () => tapped = true,
            onAccent: true,
          ),
        ),
      );

      await tester.tap(find.text('Ask Coach'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('LiquidGlassIconButton', () {
    testWidgets('renders icon with semantics', (tester) async {
      await tester.pumpWidget(
        _wrap(
          LiquidGlassIconButton(
            icon: Icons.settings_outlined,
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ),
      );

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    });
  });
}
