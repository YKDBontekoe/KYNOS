import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';

/// Large-title page header shared by Health and Journey.
///
/// Intentionally not a second navigation bar — just page identity that scrolls
/// with content under the shared shell tab bar.
class KynosPageHeader extends StatelessWidget {
  const KynosPageHeader({
    super.key,
    required this.title,
    this.greeting,
    this.subtitle,
    this.onAskCoach,
  });

  final String title;
  final String? greeting;
  final String? subtitle;

  /// Kept for API compatibility; prefer the shell Coach tab for navigation.
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
            if (greeting != null) ...[
              Text(
                greeting!,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: kynos.secondaryLabel,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(Spacing.xs),
            ],
            Text(
              title,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                height: 1.05,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const Gap(Spacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: kynos.secondaryLabel,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
