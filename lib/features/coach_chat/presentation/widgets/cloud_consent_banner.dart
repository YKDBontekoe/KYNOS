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
              'Sources: ${enabledSourceLabels.join(', ')}. '
              'Health context is sent to your OpenRouter model.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Gap(Spacing.sm),
            Row(
              children: [
                TextButton(onPressed: onCancel, child: const Text('Cancel')),
                const Spacer(),
                FilledButton(
                  onPressed: onConfirm,
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
