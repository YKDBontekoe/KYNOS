import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/usecases/coach/build_proactive_health_agent_run_usecase.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

/// Card for a deterministic proactive health-agent run (risk, debrief, etc.).
class ProactiveHealthAgentCard extends StatelessWidget {
  const ProactiveHealthAgentCard({
    super.key,
    required this.run,
    required this.onAsk,
  });

  final ProactiveHealthAgentRun run;
  final ValueChanged<String> onAsk;

  String get _kindLabel => switch (run.kind) {
        ProactiveHealthAgentKind.morningPulse => 'Morning pulse',
        ProactiveHealthAgentKind.postRunDebrief => 'Post-run',
        ProactiveHealthAgentKind.riskRadar => 'Risk radar',
        ProactiveHealthAgentKind.experimentLoop => 'Experiment',
      };

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    // Morning pulse duplicates TodayDirectiveCard — skip on empty state.
    if (run.kind == ProactiveHealthAgentKind.morningPulse) {
      return const SizedBox.shrink();
    }

    return KynosCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KynosChip(label: _kindLabel),
              if (run.riskFlags.isNotEmpty) ...[
                const Gap(Spacing.xs),
                KynosChip.accent(label: 'Attention', color: kynos.stand),
              ],
            ],
          ),
          const Gap(Spacing.sm),
          Text(
            run.headline,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Gap(Spacing.xs),
          Text(
            run.detail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
          const Gap(Spacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onAsk(run.seedPrompt),
              child: const Text('Ask coach'),
            ),
          ),
        ],
      ),
    );
  }
}
