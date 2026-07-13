import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/features/character/presentation/pages/character_page.dart';

void main() {
  testWidgets('CharacterPage renders app bar title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CharacterPage())),
    );

    await tester.pump();

    expect(find.text('JOURNEY'), findsOneWidget);
  });
}
