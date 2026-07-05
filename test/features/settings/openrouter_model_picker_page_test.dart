import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/openrouter_model.dart';
import 'package:kynos/domain/entities/openrouter_model_filters.dart';
import 'package:kynos/features/settings/presentation/pages/openrouter_model_picker_page.dart';
import 'package:kynos/features/settings/providers/openrouter_models_provider.dart';
import 'package:kynos/features/settings/providers/settings_provider.dart';

void main() {
  const longDescription = 'This model has an intentionally long description. '
      'It explains architecture, benchmarks, intended usage, safety behavior, '
      'pricing notes, latency expectations, context-window caveats, and routing '
      'details. The description keeps going so the modal content must scroll '
      'while the primary Select model button remains pinned and reachable for '
      'users with large text scales. '
      'Additional details describe multilingual capabilities, code generation, '
      'reasoning tradeoffs, prompt formatting recommendations, and deployment '
      'constraints across mobile and web clients.';

  const model = OpenRouterModel(
    id: 'test/very-long-description-model',
    name: 'Long Description Model',
    contextLength: 128000,
    pricing: OpenRouterModelPricing(prompt: '0', completion: '0'),
    description: longDescription,
  );

  testWidgets(
    'model detail sheet keeps select action visible with long descriptions',
    (tester) async {
      tester.view.physicalSize = const Size(390, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            openRouterCatalogProvider.overrideWithValue(
              const OpenRouterCatalogState(
                filters: OpenRouterModelFilters(
                  sort: OpenRouterModelSort.mostPopular,
                  category: OpenRouterModelFilters.defaultCategory,
                ),
              ),
            ),
            openRouterCatalogDataProvider.overrideWith(
              (ref) async => (models: const [model], error: null),
            ),
            settingsProvider.overrideWithValue(
              const SettingsState(
                isDarkMode: false,
                languageCode: 'en',
                cloudTasksEnabled: false,
                cloudDataLevel: CloudDataLevel.minimal,
                selectedCloudModelId: null,
                selectedCloudModelName: null,
              ),
            ),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(390, 640),
                textScaler: TextScaler.linear(2),
              ),
              child: const OpenRouterModelPickerPage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Long Description Model'));
      await tester.pumpAndSettle();

      expect(find.text('Description'), findsOneWidget);
      expect(find.text(longDescription), findsOneWidget);
      expect(find.text('Select model'), findsOneWidget);
      expect(tester.getBottomLeft(find.text('Select model')).dy, lessThan(640));
    },
  );
}
