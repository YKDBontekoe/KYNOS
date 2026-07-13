import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

/// Expandable section for progressive disclosure on long scroll surfaces.
class KynosCollapsibleSection extends StatefulWidget {
  const KynosCollapsibleSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<KynosCollapsibleSection> createState() =>
      _KynosCollapsibleSectionState();
}

class _KynosCollapsibleSectionState extends State<KynosCollapsibleSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return KynosCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _expanded = !_expanded);
            },
            borderRadius: BorderRadius.circular(Radius.lg),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: kynos.tertiaryLabel,
                                letterSpacing: 0.6,
                              ),
                        ),
                        if (widget.subtitle != null) ...[
                          const Gap(Spacing.xs),
                          Text(
                            widget.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: kynos.secondaryLabel,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: Motion.fast,
                    curve: Motion.curve,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: kynos.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                0,
                Spacing.md,
                Spacing.md,
              ),
              child: widget.child,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: Motion.fast,
          ),
        ],
      ),
    );
  }
}
