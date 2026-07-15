import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/utils/date_label.dart';

/// Apple Health–style large-title header for the legacy Today tab.
class DashboardHeaderSliver extends StatelessWidget {
  const DashboardHeaderSliver({
    super.key,
    required this.greeting,
    required this.subtitle,
    this.onAskCoach,
  });

  final String greeting;
  final String subtitle;
  final VoidCallback? onAskCoach;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          LayoutTokens.titleSpacing,
          Spacing.sm,
          LayoutTokens.titleSpacing,
          Spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDateLabel(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: kynos.tertiaryLabel,
                letterSpacing: 0.2,
              ),
            ),
            const Gap(Spacing.xs),
            Text(
              greeting,
              style: theme.textTheme.labelLarge?.copyWith(
                color: kynos.secondaryLabel,
              ),
            ),
            const Gap(Spacing.xs),
            Text(
              'Summary',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const Gap(Spacing.sm),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: kynos.secondaryLabel,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
