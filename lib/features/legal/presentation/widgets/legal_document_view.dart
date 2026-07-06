import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/legal/models/legal_document.dart';
import 'package:kynos/shared/utils/url_opener.dart';
import 'package:kynos/shared/widgets/kynos_privacy_footer.dart';

/// Scrollable renderer for bundled legal documents.
class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({
    required this.document,
    super.key,
  });

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      children: [
        Text(
          'Effective ${document.effectiveDate}',
          style: textTheme.bodySmall?.copyWith(color: kynos.secondaryLabel),
        ),
        const Gap(tokens.Spacing.lg),
        for (final section in document.sections) ...[
          Text(
            section.title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(tokens.Spacing.sm),
          Text(
            section.body,
            style: textTheme.bodyMedium?.copyWith(
              color: kynos.label,
              height: 1.5,
            ),
          ),
          const Gap(tokens.Spacing.lg),
        ],
        if (document.externalUrl case final url?) ...[
          Center(
            child: TextButton.icon(
              onPressed: () => _openExternal(context, url, document.title),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('View online version'),
            ),
          ),
          const Gap(tokens.Spacing.md),
        ],
        const KynosPrivacyFooter(),
        const Gap(tokens.Spacing.xl),
      ],
    );
  }

  Future<void> _openExternal(
    BuildContext context,
    String url,
    String label,
  ) async {
    final opened = await openExternalUrl(url);
    if (!context.mounted) return;
    if (!opened) showUrlLaunchError(context, label);
  }
}
