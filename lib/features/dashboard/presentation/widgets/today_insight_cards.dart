import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/widgets/insight_expandable_card.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

/// Today's AI insight cards — quick changes, risks, and actions.
class TodayInsightCards extends StatelessWidget {
  const TodayInsightCards({super.key, required this.todayInsightsState});

  final AsyncValue<TodayInsightsState> todayInsightsState;

  @override
  Widget build(BuildContext context) {
    return todayInsightsState.when(
      loading: () => const KynosCard(
        child: KynosLoadingLine(label: 'Generating today insights...'),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        final insights = state.insights;
        if (insights == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            InsightExpandableCard(
              title: 'Quick Changes',
              icon: Icons.compare_arrows_rounded,
              lines: insights.whatChanged,
            ),
            const Gap(tokens.Spacing.md),
            InsightExpandableCard(
              title: 'Top Risks',
              icon: Icons.warning_amber_rounded,
              lines: insights.riskFlags,
            ),
            const Gap(tokens.Spacing.md),
            ActionCompactCard(
              actionNow: insights.actionNow,
              actionTonight: insights.actionTonight,
              evidence: insights.evidence,
            ),
          ],
        );
      },
    );
  }
}

/// Expandable quick-actions card with Now / Tonight recommendations.
class ActionCompactCard extends StatefulWidget {
  const ActionCompactCard({
    super.key,
    required this.actionNow,
    required this.actionTonight,
    required this.evidence,
  });

  final String actionNow;
  final String actionTonight;
  final List<String> evidence;

  @override
  State<ActionCompactCard> createState() => _ActionCompactCardState();
}

class _ActionCompactCardState extends State<ActionCompactCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(_expanded ? 'Hide' : 'Open'),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Wrap(
            spacing: tokens.Spacing.xs,
            runSpacing: tokens.Spacing.xs,
            children: [
              const KynosChip(label: 'Now'),
              const KynosChip(label: 'Tonight'),
              if (widget.evidence.isNotEmpty)
                KynosChip(label: '${widget.evidence.length} signals'),
            ],
          ),
          if (_expanded) ...[
            const Gap(tokens.Spacing.sm),
            ActionRow(
              icon: Icons.play_arrow_rounded,
              label: 'Now',
              value: widget.actionNow,
            ),
            const Gap(tokens.Spacing.xs),
            ActionRow(
              icon: Icons.nights_stay_rounded,
              label: 'Tonight',
              value: widget.actionTonight,
            ),
            if (widget.evidence.isNotEmpty) ...[
              const Gap(tokens.Spacing.sm),
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
        ],
      ),
    );
  }
}

/// Single labelled action row inside [ActionCompactCard].
class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.secondaryLabel),
        const Gap(tokens.Spacing.xs),
        Text(
          '$label:',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryLabel,
          ),
        ),
        const Gap(tokens.Spacing.xs),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
