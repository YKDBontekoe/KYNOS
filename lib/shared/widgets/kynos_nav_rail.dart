import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/liquid_glass_tokens.dart';
import 'package:kynos/core/theme/motion.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/shared/widgets/liquid_glass_surface.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

/// Configuration for a single destination in [KynosNavRail].
@immutable
class KynosNavRailItem {
  const KynosNavRailItem({required this.label, required this.icon});

  final String label;
  final NavIconDefinition icon;
}

/// Left-edge Liquid Glass navigation rail — icon-forward, coach-first layout.
class KynosNavRail extends StatelessWidget {
  const KynosNavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<KynosNavRailItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  void _handleTap(int index) {
    if (index == selectedIndex) return;
    HapticFeedback.selectionClick();
    onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return RepaintBoundary(
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: LayoutTokens.shellRailWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: tokens.Spacing.md,
              horizontal: tokens.Spacing.xs,
            ),
            child: LiquidGlassSurface(
              borderRadius: tokens.Radius.xl,
              blurSigma: LiquidGlassTokens.navBlurSigma,
              padding: const EdgeInsets.symmetric(vertical: tokens.Spacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Gap(tokens.Spacing.xs),
                    _RailItem(
                      icon: items[i].icon,
                      label: items[i].label,
                      selected: selectedIndex == i,
                      onTap: () => _handleTap(i),
                      accent: kynos.purple,
                      unselected: kynos.navUnselected,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accent,
    required this.unselected,
  });

  final NavIconDefinition icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  final Color unselected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? accent : unselected;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 400),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: Motion.navItem,
            curve: Motion.curve,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tokens.Radius.lg),
              color: selected ? accent.withValues(alpha: 0.14) : Colors.transparent,
            ),
            child: Center(
              child: AnimatedScale(
                scale: selected ? 1.06 : 1.0,
                duration: Motion.navItem,
                curve: Motion.curve,
                child: CustomPaint(
                  size: const Size(24, 24),
                  painter: NavIconPainter(
                    pathData: selected ? icon.filled : icon.outline,
                    color: color,
                    strokeWidth: 2.0,
                    filled: selected,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
