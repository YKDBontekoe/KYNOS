import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/app/shell_navigation_scope.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/conversation_list_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/inference_settings_sheet.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

void showCoachNavigationSheet(
  BuildContext context, {
  required VoidCallback onExport,
  required VoidCallback onDeleteThread,
}) {
  final kynos = context.kynosTheme;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => CoachNavigationSheet(
      onExport: onExport,
      onDeleteThread: onDeleteThread,
      onClose: () => Navigator.pop(sheetContext),
      parentContext: context,
      background: kynos.background,
    ),
  );
}

/// Soft grouped navigation sheet for Coach.
class CoachNavigationSheet extends StatelessWidget {
  const CoachNavigationSheet({
    super.key,
    required this.onExport,
    required this.onDeleteThread,
    required this.onClose,
    required this.parentContext,
    required this.background,
  });

  final VoidCallback onExport;
  final VoidCallback onDeleteThread;
  final VoidCallback onClose;
  final BuildContext parentContext;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final shell = ShellNavigationScope.maybeOf(parentContext);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          0,
          Spacing.md,
          Spacing.md,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(Radius.xl),
            boxShadow: kynos.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              Spacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kynos.separator,
                      borderRadius: BorderRadius.circular(Radius.full),
                    ),
                  ),
                ),
                const Gap(Spacing.md),
                Text(
                  'Navigate',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                ),
                const Gap(Spacing.sm),
                _NavGroup(
                  children: [
                    _NavRow(
                      glyph: NavIconPaths.coach,
                      label: 'Conversations',
                      subtitle: 'Switch or start a chat',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onClose();
                        showConversationListSheet(parentContext);
                      },
                    ),
                    _NavRow(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Model & mode',
                      subtitle: 'Auto, on-device, or cloud',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onClose();
                        showInferenceSettingsSheet(
                          parentContext,
                          onExport: onExport,
                          onDeleteThread: onDeleteThread,
                        );
                      },
                    ),
                  ],
                ),
                const Gap(Spacing.sm),
                _NavGroup(
                  children: [
                    _NavRow(
                      glyph: NavIconPaths.health,
                      label: 'Health',
                      subtitle: 'Readiness, trends, and runs',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onClose();
                        shell?.goToBranch(1);
                      },
                    ),
                    _NavRow(
                      glyph: NavIconPaths.journey,
                      label: 'Journey',
                      subtitle: 'Progress, camp, and quests',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onClose();
                        shell?.goToBranch(2);
                      },
                    ),
                    _NavRow(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      subtitle: 'Privacy, models, and profile',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onClose();
                        parentContext.push(Routes.settings);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavGroup extends StatelessWidget {
  const _NavGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: kynos.card,
        borderRadius: BorderRadius.circular(Radius.lg),
        border: Border.all(color: kynos.separator.withValues(alpha: 0.55)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 64,
                color: kynos.separator.withValues(alpha: 0.7),
              ),
          ],
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.glyph,
    this.icon,
  }) : assert(glyph != null || icon != null);

  final NavIconDefinition? glyph;
  final IconData? icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm + 2,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kynos.purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(Radius.md),
                ),
                alignment: Alignment.center,
                child: glyph != null
                    ? CustomPaint(
                        size: const Size(20, 20),
                        painter: NavIconPainter(
                          pathData: glyph!.outline,
                          color: kynos.purple,
                          strokeWidth: 1.9,
                        ),
                      )
                    : Icon(icon, size: 20, color: kynos.purple),
              ),
              const Gap(Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: kynos.secondaryLabel,
                          ),
                    ),
                  ],
                ),
              ),
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
