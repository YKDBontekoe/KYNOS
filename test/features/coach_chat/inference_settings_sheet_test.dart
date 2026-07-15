import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/inference_settings_sheet.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:kynos/shared/providers/shell_chrome_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('InferenceSettingsSheet renders soft groups and delete action', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: InferenceSettingsSheet(
              onExport: () {},
              onDeleteThread: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Model & mode'), findsOneWidget);
    expect(find.text('On-device model'), findsOneWidget);
    expect(find.text('Cloud model'), findsOneWidget);
    expect(find.text('Context sources'), findsOneWidget);
    expect(find.text('Attach focus run'), findsOneWidget);
    expect(find.text('Export chat'), findsOneWidget);
    expect(find.text('Delete thread'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
    expect(find.text('Pick'), findsOneWidget);
  });

  testWidgets('Model & mode sheet hides shell chrome while open', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              theme: AppTheme.dark,
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: FilledButton(
                        onPressed: () => showInferenceSettingsSheet(
                          context,
                          onExport: () {},
                          onDeleteThread: () {},
                        ),
                        child: const Text('Open sheet'),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    expect(container.read(shellChromeProvider), isTrue);

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Model & mode'), findsOneWidget);
    expect(find.text('Delete thread'), findsOneWidget);
    expect(container.read(shellChromeProvider), isFalse);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(find.text('Model & mode'), findsNothing);
    expect(container.read(shellChromeProvider), isTrue);
  });
}
