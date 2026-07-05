import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/shared/widgets/glass_card.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_hero_banner.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';
import 'package:shimmer/shimmer.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  group('MetricTile', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MetricTile(
            label: 'Heart Rate',
            value: '72',
            unit: 'BPM',
          ),
        ),
      );

      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
      expect(find.text('BPM'), findsOneWidget);
    });

    testWidgets('renders shimmer when value is null', (tester) async {
      await tester.pumpWidget(
        _wrap(const MetricTile(label: 'Heart Rate', value: null)),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('KynosCard', () {
    testWidgets('handles onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          KynosCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });

  group('KynosSectionHeader', () {
    testWidgets('uppercases title', (tester) async {
      await tester.pumpWidget(
        _wrap(const KynosSectionHeader(title: 'Health Metrics')),
      );

      expect(find.text('HEALTH METRICS'), findsOneWidget);
    });
  });

  group('KynosHeroBanner', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const KynosHeroBanner(
            accentColor: Colors.blue,
            subtitle: 'Good morning',
            title: 'KYNOS',
          ),
        ),
      );

      expect(find.text('KYNOS'), findsOneWidget);
      expect(find.text('Good morning'), findsOneWidget);
    });
  });

  group('KynosChip', () {
    testWidgets('renders compact label', (tester) async {
      await tester.pumpWidget(
        _wrap(const KynosChip(label: 'Recovery')),
      );

      expect(find.text('Recovery'), findsOneWidget);
    });
  });

  group('KynosLoadingLine', () {
    testWidgets('renders shimmer skeleton', (tester) async {
      await tester.pumpWidget(
        _wrap(const KynosLoadingLine()),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('KynosSkeleton', () {
    testWidgets('renders shimmer block', (tester) async {
      await tester.pumpWidget(
        _wrap(const KynosSkeleton.tile()),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('GlassCard', () {
    testWidgets('applies BackdropFilter', (tester) async {
      await tester.pumpWidget(
        _wrap(const GlassCard(child: Text('Glass Content'))),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });
}
