import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  testWidgets('DashboardPage renders hero banner', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pump();

    expect(find.text('KYNOS'), findsOneWidget);
  });
}
