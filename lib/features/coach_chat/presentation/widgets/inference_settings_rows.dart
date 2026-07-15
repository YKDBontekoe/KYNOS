import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;

/// Soft inset group — rounded continuous surface with hairline dividers.
class InferenceSheetGroup extends StatelessWidget {
  const InferenceSheetGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kynos.card,
        borderRadius: BorderRadius.circular(tokens.Radius.hero),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.Radius.hero),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class InferenceSheetDivider extends StatelessWidget {
  const InferenceSheetDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.kynosTheme.separator;
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: Spacing.md,
      endIndent: Spacing.md,
      color: color.withValues(alpha: 0.55),
    );
  }
}

class InferenceModelRow extends StatelessWidget {
  const InferenceModelRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.sm,
        Spacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(Spacing.xs),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: kynos.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          const Gap(Spacing.sm),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: kynos.stand,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.Radius.full),
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class InferenceActionRow extends StatelessWidget {
  const InferenceActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.foreground,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final color = foreground ?? kynos.label;
    final iconColor = foreground ?? kynos.secondaryLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const Gap(Spacing.md),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (foreground == null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: kynos.tertiaryLabel,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
