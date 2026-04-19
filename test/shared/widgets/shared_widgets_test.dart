import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/shared/widgets/glass_card.dart';
import 'package:kynos/shared/widgets/glow_text.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('MetricTile Tests', () {
    testWidgets('renders label and value correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricTile(
              label: 'Heart Rate',
              value: '72',
              unit: 'BPM',
            ),
          ),
        ),
      );

      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
      expect(find.text('BPM'), findsOneWidget);
    });

    testWidgets('renders loading shimmer when value is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricTile(
              label: 'Heart Rate',
              value: null,
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('KynosCard Tests', () {
    testWidgets('renders child and handles onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KynosCard(
              onTap: () => tapped = true,
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });

  group('GlowText Tests', () {
    testWidgets('renders text with shadows', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlowText('Glow Me'),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Glow Me'));
      expect(textWidget.style?.shadows, isNotEmpty);
      expect(textWidget.style?.shadows?.length, 3);
    });
  });

  group('GlassCard Tests', () {
    testWidgets('renders child and applies BackdropFilter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Glass Content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });
}
