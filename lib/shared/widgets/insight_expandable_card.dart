import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/motion.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/shared/utils/insight_text_formatter.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

/// Expandable insight card showing compact chips and detail lines.
class InsightExpandableCard extends StatefulWidget {
  const InsightExpandableCard({
    super.key,
    required this.title,
    required this.icon,
    required this.lines,
    this.evidence = const [],
    this.extraChips = const [],
    this.expandButtonLabel = 'Details',
    this.collapseButtonLabel = 'Hide',
  });

  final String title;
  final IconData icon;
  final List<String> lines;
  final List<String> evidence;
  final List<String> extraChips;
  final String expandButtonLabel;
  final String collapseButtonLabel;

  @override
  State<InsightExpandableCard> createState() => _InsightExpandableCardState();
}

class _InsightExpandableCardState extends State<InsightExpandableCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 14, color: AppTheme.secondaryLabel),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _expanded
                      ? widget.collapseButtonLabel
                      : widget.expandButtonLabel,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Wrap(
            spacing: tokens.Spacing.xs,
            runSpacing: tokens.Spacing.xs,
            children: [
              for (final line in widget.lines.take(2))
                KynosChip(
                  label: InsightTextFormatter.compactChipLabel(line),
                ),
              for (final chip in widget.extraChips)
                KynosChip(label: chip),
              if (widget.evidence.isNotEmpty)
                KynosChip(label: '${widget.evidence.length} signals'),
            ],
          ),
          AnimatedSize(
            duration: Motion.medium,
            curve: Motion.curve,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(tokens.Spacing.sm),
                      for (final line in widget.lines.take(3)) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.secondaryLabel,
                                height: 1.4,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                line,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const Gap(tokens.Spacing.xs),
                      ],
                      if (widget.evidence.isNotEmpty) ...[
                        const Gap(tokens.Spacing.xs),
                        Text(
                          widget.evidence.join(' • '),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.tertiaryLabel,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Expandable card for a single insight text with metadata chips.
class InsightTextExpandableCard extends StatefulWidget {
  const InsightTextExpandableCard({
    super.key,
    required this.title,
    required this.icon,
    required this.text,
    this.extraChips = const [],
  });

  final String title;
  final IconData icon;
  final String text;
  final List<String> extraChips;

  @override
  State<InsightTextExpandableCard> createState() =>
      _InsightTextExpandableCardState();
}

class _InsightTextExpandableCardState extends State<InsightTextExpandableCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 14, color: AppTheme.secondaryLabel),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(_expanded ? 'Hide' : 'Details'),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Wrap(
            spacing: tokens.Spacing.xs,
            runSpacing: tokens.Spacing.xs,
            children: [
              KynosChip(
                label: InsightTextFormatter.compactChipLabel(widget.text),
              ),
              for (final chip in widget.extraChips)
                KynosChip(label: chip),
            ],
          ),
          AnimatedSize(
            duration: Motion.medium,
            curve: Motion.curve,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(tokens.Spacing.sm),
                      Text(
                        widget.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
