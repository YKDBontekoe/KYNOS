import 'package:flutter/material.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/legal/content/legal_documents.dart';
import 'package:kynos/features/legal/presentation/widgets/legal_document_view.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kynosTheme.background,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const LegalDocumentView(document: LegalDocuments.privacyPolicy),
    );
  }
}
