import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';

/// Token-aligned segmented control for chart range and metric pickers.
class KynosSegmentedControl<T> extends StatelessWidget {
  const KynosSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.labelBuilder,
  });

  final List<T> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T value)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: kynos.separator.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Radius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xs),
        child: Row(
          children: [
            for (var i = 0; i < segments.length; i++) ...[
              if (i > 0) const Gap(Spacing.xs),
              Expanded(
                child: _Segment(
                  label: labelBuilder?.call(segments[i]) ?? segments[i].toString(),
                  selected: segments[i] == selected,
                  onTap: () {
                    if (segments[i] == selected) return;
                    HapticFeedback.selectionClick();
                    onChanged(segments[i]);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
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
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.curve,
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          decoration: BoxDecoration(
            color: selected ? kynos.card : Colors.transparent,
            borderRadius: BorderRadius.circular(Radius.full),
            boxShadow: selected ? kynos.cardShadow : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? kynos.label : kynos.secondaryLabel,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
