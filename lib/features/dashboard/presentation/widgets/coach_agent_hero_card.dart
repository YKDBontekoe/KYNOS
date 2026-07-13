import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

/// Home-screen entry point into the agentic coach — KYNOS's core surface.
///
/// Surfaces a live insight line plus one-tap prompts that showcase the
/// coach's tool-calling capabilities (looking up runs, trends, and pacing
/// math) instead of a static, one-shot Q&A box.
class CoachAgentHeroCard extends StatelessWidget {
  const CoachAgentHeroCard({
    super.key,
    required this.insightLine,
    required this.onAskCoach,
  });

  final String insightLine;
  final void Function(String message, CoachSeedTopic topic) onAskCoach;

  static const _prompts = <(String, CoachSeedTopic)>[
    ("How's my training load?", CoachSeedTopic.readiness),
    ('Plan my pace for a 10K', CoachSeedTopic.training),
    ('Any personal bests lately?', CoachSeedTopic.metric),
  ];

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final theme = Theme.of(context);

    return Semantics(
      label: 'KYNOS Coach, agentic AI trained on your data. $insightLine',
      button: true,
      child: KynosCard(
        elevated: true,
        padding: const EdgeInsets.all(tokens.Spacing.lg),
        onTap: () => onAskCoach('', CoachSeedTopic.general),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 20, color: kynos.purple),
                const Gap(tokens.Spacing.sm),
                Text('KYNOS Coach', style: theme.textTheme.titleMedium),
                const Gap(tokens.Spacing.sm),
                KynosChip.accent(label: 'Agentic', color: kynos.purple),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: kynos.tertiaryLabel,
                ),
              ],
            ),
            const Gap(tokens.Spacing.sm),
            Text(
              insightLine,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: kynos.secondaryLabel,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(tokens.Spacing.md),
            Wrap(
              spacing: tokens.Spacing.sm,
              runSpacing: tokens.Spacing.sm,
              children: [
                for (final (label, topic) in _prompts)
                  _PromptChip(
                    label: label,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onAskCoach(label, topic);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.Radius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: tokens.Spacing.md,
            vertical: tokens.Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: kynos.purple.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(tokens.Radius.full),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: kynos.purple,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
