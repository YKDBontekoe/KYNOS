import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/domain/catalog/on_device_model_catalog.dart';
import 'package:kynos/features/settings/presentation/widgets/on_device_model_card.dart';

void main() {
  testWidgets('OnDeviceModelCard renders capability chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: OnDeviceModelCard(
            model: OnDeviceModelCatalog.gemma4E2b,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Gemma 4 E2B'), findsOneWidget);
    expect(find.text('Best on-device coach quality'), findsOneWidget);
    expect(find.text('Thinking'), findsOneWidget);
    expect(find.text('Vision'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
  });
}
