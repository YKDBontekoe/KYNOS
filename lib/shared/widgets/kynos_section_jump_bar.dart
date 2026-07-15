import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/core/theme/theme.dart';

/// Quiet section jump links — deliberately not a second tab bar.
class KynosSectionJumpBar extends StatelessWidget {
  const KynosSectionJumpBar({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return ColoredBox(
      color: kynos.background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.xs,
          Spacing.md,
          Spacing.sm,
        ),
        child: Row(
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(width: Spacing.md),
              _JumpLink(
                label: sections[i],
                selected: selectedIndex == i,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(i);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _JumpLink extends StatelessWidget {
  const _JumpLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? kynos.label : kynos.tertiaryLabel,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: -0.1,
                    ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: Motion.fast,
                curve: Motion.curve,
                height: 2,
                width: selected ? 18 : 0,
                decoration: BoxDecoration(
                  color: kynos.purple,
                  borderRadius: BorderRadius.circular(Radius.full),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
