import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/liquid_glass_surface.dart';
import 'package:kynos/shared/widgets/nav_icon.dart';

/// Floating liquid-glass navigation dock for shell destinations.
class KynosTabBar extends StatelessWidget {
  const KynosTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.onSettings,
  });

  final List<KynosTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final destinations = <_DockDestination>[
      for (var i = 0; i < items.length; i++)
        _DockDestination.tab(
          label: items[i].label,
          icon: items[i].icon,
          selected: selectedIndex == i,
          onTap: () {
            HapticFeedback.selectionClick();
            // Always forward — shell uses re-taps for initialLocation reset.
            onSelected(i);
          },
        ),
      if (onSettings != null)
        _DockDestination.settings(
          onTap: () {
            HapticFeedback.selectionClick();
            onSettings!();
          },
        ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        0,
        Spacing.md,
        bottom + LayoutTokens.floatingTabBarMargin,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radius.full),
          boxShadow: [
            BoxShadow(
              color: kynos.label.withValues(alpha: 0.10),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: kynos.label.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LiquidGlassSurface(
          borderRadius: Radius.full,
          blurSigma: LiquidGlassTokens.navBlurSigma,
          border: Border.all(
            color: LiquidGlassTokens.borderColor(
              Theme.of(context).brightness,
            ),
          ),
          child: SizedBox(
            height: LayoutTokens.floatingTabBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
              child: Row(
                children: [
                  for (final destination in destinations)
                    Expanded(child: destination),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class KynosTabItem {
  const KynosTabItem({required this.label, required this.icon});

  final String label;
  final NavIconDefinition icon;
}

class _DockDestination extends StatelessWidget {
  const _DockDestination.tab({
    required this.label,
    required NavIconDefinition icon,
    required this.selected,
    required this.onTap,
  })  : _iconData = null,
        _glyph = icon;

  const _DockDestination.settings({
    required this.onTap,
  })  : label = 'Settings',
        selected = false,
        _glyph = null,
        _iconData = Icons.settings_outlined;

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final NavIconDefinition? _glyph;
  final IconData? _iconData;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final color = selected ? kynos.purple : kynos.secondaryLabel;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 400),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: AnimatedContainer(
            duration: Motion.fast,
            curve: Motion.curve,
            margin: const EdgeInsets.symmetric(
              horizontal: Spacing.xs,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: selected ? kynos.purple.withValues(alpha: 0.16) : null,
              borderRadius: BorderRadius.circular(Radius.full),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: kynos.purple.withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_glyph != null)
                  CustomPaint(
                    size: const Size(22, 22),
                    painter: NavIconPainter(
                      pathData: selected ? _glyph.filled : _glyph.outline,
                      color: color,
                      strokeWidth: selected ? 2.1 : 1.8,
                      filled: selected,
                    ),
                  )
                else
                  Icon(_iconData, size: 22, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 10,
                        letterSpacing: -0.1,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
