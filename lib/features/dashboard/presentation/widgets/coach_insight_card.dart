import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/acwr.dart';
import 'package:kynos/features/dashboard/providers/today_insights_provider.dart';
import 'package:kynos/shared/widgets/animated_async_content.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';

/// Single consolidated coach insight card — action, changes, and load guardrail.
class CoachInsightCard extends ConsumerWidget {
  const CoachInsightCard({
    super.key,
    required this.todayInsightsState,
    required this.history,
    this.onAskCoach,
  });

  final AsyncValue<TodayInsightsState> todayInsightsState;
  final List<HealthSummary> history;
  final VoidCallback? onAskCoach;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedAsyncContent<TodayInsightsState>(
      value: todayInsightsState,
      loading: (_) => const KynosCard(
        child: KynosLoadingLine(label: 'Generating today insights...'),
      ),
      error: (_, _, _) => _RetryCard(
        message: 'Could not load today\'s insights.',
        onRetry: () => ref.invalidate(todayInsightsStateProvider),
      ),
      data: (context, state) {
        final insights = state.insights;
        if (insights == null) {
          if (state.failureMessage == null) {
            return _AcwrOnlyCard(history: history);
          }
          return _RetryCard(
            message: state.failureMessage!,
            onRetry: () => ref.invalidate(todayInsightsStateProvider),
          );
        }

        return _CoachInsightContent(
          actionNow: insights.actionNow,
          whatChanged: insights.whatChanged,
          riskFlags: insights.riskFlags,
          history: history,
          onAskCoach: onAskCoach,
        );
      },
    );
  }
}

class _CoachInsightContent extends StatelessWidget {
  const _CoachInsightContent({
    required this.actionNow,
    required this.whatChanged,
    required this.riskFlags,
    required this.history,
    this.onAskCoach,
  });

  final String actionNow;
  final List<String> whatChanged;
  final List<String> riskFlags;
  final List<HealthSummary> history;
  final VoidCallback? onAskCoach;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final acwr = computeAcwr(history);
    final elevated = isAcwrElevated(acwr);
    final chips = whatChanged.take(2).toList();

    return KynosCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 20, color: kynos.purple),
              const Gap(Spacing.sm),
              Expanded(
                child: Text(
                  actionNow,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const Gap(Spacing.md),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: chips
                  .map(
                    (c) => KynosChip.accent(
                      label: c,
                      color: kynos.purple,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (elevated && acwr != null) ...[
            const Gap(Spacing.md),
            KynosChip.accent(
              label:
                  'ACWR ${acwr.toStringAsFixed(2)} — ${acwrRiskLabel(acwr)}',
              color: kynos.move,
            ),
          ] else if (riskFlags.isNotEmpty &&
              !riskFlags.first.toLowerCase().contains('no strong')) ...[
            const Gap(Spacing.md),
            KynosChip.accent(
              label: riskFlags.first,
              color: kynos.energy,
            ),
          ],
          if (onAskCoach != null) ...[
            const Gap(Spacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onAskCoach,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  backgroundColor: kynos.purple.withValues(alpha: 0.10),
                  foregroundColor: kynos.purple,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Ask Coach'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AcwrOnlyCard extends StatelessWidget {
  const _AcwrOnlyCard({required this.history});

  final List<HealthSummary> history;

  @override
  Widget build(BuildContext context) {
    final acwr = computeAcwr(history);
    if (acwr == null) return const SizedBox.shrink();

    final kynos = context.kynosTheme;
    final elevated = isAcwrElevated(acwr);

    return KynosCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        children: [
          Icon(
            elevated ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: elevated ? kynos.move : kynos.exercise,
          ),
          const Gap(Spacing.sm),
          Expanded(
            child: Text(
              'ACWR ${acwr.toStringAsFixed(2)} — ${acwrRiskLabel(acwr)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryCard extends StatelessWidget {
  const _RetryCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      padding: const EdgeInsets.all(Spacing.lg),
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
