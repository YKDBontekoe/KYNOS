import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';

/// Compact empty-state footer with a single primary action and optional secondary.
///
/// Use inside cards that have no data yet so the empty state always teaches the
/// next step instead of only showing dashes.
class KynosEmptyCta extends StatelessWidget {
  const KynosEmptyCta({
    super.key,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.icon = Icons.add_circle_outline_rounded,
  });

  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: kynos.secondaryLabel,
              ),
        ),
        const Gap(Spacing.md),
        FilledButton.icon(
          onPressed: onPrimary,
          icon: Icon(icon, size: 18),
          label: Text(primaryLabel),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          ),
        ),
        if (secondaryLabel != null && onSecondary != null) ...[
          const Gap(Spacing.xs),
          TextButton(
            onPressed: onSecondary,
            child: Text(secondaryLabel!),
          ),
        ],
      ],
    );
  }
}
