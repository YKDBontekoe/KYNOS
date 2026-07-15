import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/core/theme/theme.dart';

/// Sticky horizontal chips for jumping between sections on long scroll pages.
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(width: Spacing.xs),
            _JumpChip(
              label: sections[i],
              selected: selectedIndex == i,
              accent: kynos.purple,
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(i);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _JumpChip extends StatelessWidget {
  const _JumpChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.curve,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.16)
              : kynos.card,
          borderRadius: BorderRadius.circular(Radius.full),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.28)
                : kynos.separator,
          ),
          boxShadow: selected ? null : kynos.cardShadow,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? accent : kynos.label,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
