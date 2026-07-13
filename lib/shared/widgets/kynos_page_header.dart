import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/utils/date_label.dart';
import 'package:kynos/shared/widgets/liquid_glass_button.dart';

/// Apple Health–style large-title page header sliver group.
class KynosPageHeader extends StatelessWidget {
  const KynosPageHeader({
    super.key,
    required this.title,
    this.greeting,
    this.subtitle,
    this.onAskCoach,
    this.showSettings = true,
  });

  final String title;
  final String? greeting;
  final String? subtitle;
  final VoidCallback? onAskCoach;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final theme = Theme.of(context);

    return SliverMainAxisGroup(
      slivers: [
        SliverAppBar(
          backgroundColor: kynos.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          toolbarHeight: LayoutTokens.appBarToolbarHeight,
          titleSpacing: LayoutTokens.titleSpacing,
          title: Text(
            formatDateLabel(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: kynos.tertiaryLabel,
              letterSpacing: 0.2,
            ),
          ),
          actions: [
            if (onAskCoach != null)
              Padding(
                padding: const EdgeInsets.only(right: Spacing.xs),
                child: LiquidGlassButton(
                  label: 'Ask Coach',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: onAskCoach,
                ),
              ),
            if (showSettings)
              Padding(
                padding: const EdgeInsets.only(right: Spacing.sm),
                child: LiquidGlassIconButton(
                  icon: Icons.settings_outlined,
                  onPressed: () => context.push(Routes.settings),
                  tooltip: 'Settings',
                ),
              ),
          ],
        ),
        SliverToBoxAdapter(
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
                    ),
                  ),
                  const Gap(Spacing.xs),
                ],
                Text(
                  title,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.1,
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
        ),
      ],
    );
  }
}
