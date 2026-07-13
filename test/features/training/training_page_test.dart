import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/features/training/presentation/pages/training_page.dart';

void main() {
  testWidgets('TrainingPage renders health hub header', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TrainingPage())),
    );

    await tester.pump();

    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });
}
