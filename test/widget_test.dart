import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kynos/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const KynosApp(),
    ));
    expect(find.byType(KynosApp), findsOneWidget);
  });
}
