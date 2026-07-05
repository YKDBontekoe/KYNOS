import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/features/settings/presentation/pages/health_import_page.dart';

void main() {
  testWidgets('HealthImportPage shows import guidance', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HealthImportPage(),
        ),
      ),
    );

    expect(find.text('Import Health Data'), findsOneWidget);
    expect(find.text('Choose export.zip or GPX'), findsOneWidget);
    expect(find.textContaining('Sideloaded apps'), findsOneWidget);
    expect(find.text('Processing file…'), findsNothing);
  });
}
