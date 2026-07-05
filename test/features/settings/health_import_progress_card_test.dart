import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/features/settings/presentation/widgets/health_import_progress_card.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  testWidgets('HealthImportProgressCard shows file name and message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: HealthImportProgressCard(
            fileName: 'export.zip',
            message: 'Reading and parsing your Apple Health export.',
          ),
        ),
      ),
    );

    expect(find.text('export.zip'), findsOneWidget);
    expect(
      find.text('Reading and parsing your Apple Health export.'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(Shimmer), findsOneWidget);
  });
}
