import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/widgets/insight_expandable_card.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

/// Today's AI insight cards — quick changes, risks, and actions.
class TodayInsightCards extends ConsumerWidget {
  const TodayInsightCards({
    super.key,
    required this.todayInsightsState,
    this.onAskCoach,
  });

  final AsyncValue<TodayInsightsState> todayInsightsState;
  final VoidCallback? onAskCoach;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return todayInsightsState.when(
      loading: () => const KynosCard(
        child: KynosLoadingLine(label: 'Generating today insights...'),
      ),
      error: (_, _) => _InsightsRetryCard(
        message: 'Could not load today\'s insights.',
        onRetry: () => ref.invalidate(todayInsightsStateProvider),
      ),
      data: (state) {
        final insights = state.insights;
        if (insights == null) {
          if (state.failureMessage == null) {
            return const SizedBox.shrink();
          }
          return _InsightsRetryCard(
            message: state.failureMessage!,
            onRetry: () => ref.invalidate(todayInsightsStateProvider),
          );
        }

        return Column(
          children: [
            InsightExpandableCard(
              title: 'Quick Changes',
              icon: Icons.compare_arrows_rounded,
              lines: insights.whatChanged,
            ),
            const Gap(Spacing.md),
            InsightExpandableCard(
              title: 'Top Risks',
              icon: Icons.warning_amber_rounded,
              lines: insights.riskFlags,
            ),
            const Gap(Spacing.md),
            ActionCompactCard(
              actionNow: insights.actionNow,
              actionTonight: insights.actionTonight,
              evidence: insights.evidence,
              onAskCoach: onAskCoach,
            ),
          ],
        );
      },
    );
  }
}

class _InsightsRetryCard extends StatelessWidget {
  const _InsightsRetryCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const Gap(Spacing.sm),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
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
    this.onAskCoach,
  });

  final String actionNow;
  final String actionTonight;
  final List<String> evidence;
  final VoidCallback? onAskCoach;

  @override
  State<ActionCompactCard> createState() => _ActionCompactCardState();
}

class _ActionCompactCardState extends State<ActionCompactCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

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
          const Gap(Spacing.sm),
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              const KynosChip(label: 'Now'),
              const KynosChip(label: 'Tonight'),
              if (widget.evidence.isNotEmpty)
                KynosChip(label: '${widget.evidence.length} signals'),
              if (widget.onAskCoach != null)
                TextButton(
                  onPressed: widget.onAskCoach,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs,
                    ),
                    backgroundColor: kynos.purple.withValues(alpha: 0.10),
                    foregroundColor: kynos.purple,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Ask coach about this'),
                ),
            ],
          ),
          if (_expanded) ...[
            const Gap(Spacing.sm),
            ActionRow(
              icon: Icons.play_arrow_rounded,
              label: 'Now',
              value: widget.actionNow,
            ),
            const Gap(Spacing.xs),
            ActionRow(
              icon: Icons.nights_stay_rounded,
              label: 'Tonight',
              value: widget.actionTonight,
            ),
            if (widget.evidence.isNotEmpty) ...[
              const Gap(Spacing.sm),
              Text(
                widget.evidence.join(' • '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kynos.tertiaryLabel,
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
    final kynos = context.kynosTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: kynos.secondaryLabel),
        const Gap(Spacing.xs),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: kynos.secondaryLabel,
              ),
        ),
        const Gap(Spacing.xs),
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
