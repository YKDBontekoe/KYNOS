import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/cloud_consent_banner.dart';

void main() {
  testWidgets(
    'cloud consent banner shows Cancel and Allow actions on a narrow screen',
    (tester) async {
      var confirmed = false;
      var cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: CloudConsentBanner(
                enabledSourceLabels: const [
                  'Readiness & ACWR',
                  'Health metrics',
                  'Recent runs',
                  'Weekly momentum',
                  'Today insights',
                  'Training insights',
                  'Gait biomechanics',
                  'Athlete preferences',
                  'Post-run debrief',
                  'Daily check-ins',
                  'Coach memory',
                  'Wellbeing experiments',
                ],
                cloudDataLevelLabel: 'Full',
                onConfirm: () => confirmed = true,
                onCancel: () => cancelled = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Send to cloud coach?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Allow for this chat'), findsOneWidget);

      // Approve must remain hittable even with theme full-bleed FilledButtons.
      await tester.ensureVisible(find.text('Allow for this chat'));
      await tester.tap(find.text('Allow for this chat'));
      expect(confirmed, isTrue);
      expect(cancelled, isFalse);

      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    },
  );
}
