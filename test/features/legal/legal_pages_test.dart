import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/features/legal/content/legal_documents.dart';
import 'package:kynos/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:kynos/features/legal/presentation/pages/terms_of_service_page.dart';
import 'package:kynos/features/legal/presentation/widgets/legal_document_view.dart';

const _tallViewport = Size(800, 2400);

void main() {
  group('LegalDocuments', () {
    test('privacy policy includes core sections', () {
      final titles = LegalDocuments.privacyPolicy.sections
          .map((section) => section.title)
          .toList();

      expect(titles, contains('On-Device Processing'));
      expect(titles, contains('Optional Cloud Features'));
    });

    test('terms of service includes medical disclaimer', () {
      final titles = LegalDocuments.termsOfService.sections
          .map((section) => section.title)
          .toList();

      expect(titles, contains('Not Medical Advice'));
      expect(titles, contains('AI Coaching'));
    });
  });

  testWidgets('PrivacyPolicyPage renders bundled content', (tester) async {
    await tester.binding.setSurfaceSize(_tallViewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: PrivacyPolicyPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.textContaining('Effective'), findsOneWidget);
    expect(find.text('On-Device Processing'), findsOneWidget);
    expect(find.text('View online version'), findsOneWidget);
  });

  testWidgets('TermsOfServicePage renders bundled content', (tester) async {
    await tester.binding.setSurfaceSize(_tallViewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: TermsOfServicePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Not Medical Advice'), findsOneWidget);
    expect(find.text('All data stays on your device'), findsOneWidget);
  });

  testWidgets('LegalDocumentView renders every section', (tester) async {
    const document = LegalDocuments.privacyPolicy;

    await tester.binding.setSurfaceSize(_tallViewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LegalDocumentView(document: document),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final section in document.sections) {
      expect(find.text(section.title), findsOneWidget);
    }
  });
}
