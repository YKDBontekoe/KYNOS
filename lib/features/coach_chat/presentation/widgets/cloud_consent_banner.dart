import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';

class CloudConsentBanner extends StatelessWidget {
  const CloudConsentBanner({
    super.key,
    required this.enabledSourceLabels,
    required this.cloudDataLevelLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  final List<String> enabledSourceLabels;
  final String cloudDataLevelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final sourceSummary = enabledSourceLabels.isEmpty
        ? 'none selected'
        : enabledSourceLabels.join(', ');

    return Material(
      color: kynos.stand.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Send to cloud coach?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Gap(Spacing.xs),
            Text(
              'Data level: $cloudDataLevelLabel. '
              'Sources: $sourceSummary. '
              'Health context is sent to your cloud model.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Gap(Spacing.sm),
            // Theme FilledButtons use an infinite min width (full-bleed CTAs).
            // Override here so Cancel + Approve can share a Row on narrow screens.
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: Spacing.sm,
              overflowSpacing: Spacing.xs,
              children: [
                TextButton(onPressed: onCancel, child: const Text('Cancel')),
                FilledButton(
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.sm,
                    ),
                  ),
                  child: const Text('Allow for this chat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
