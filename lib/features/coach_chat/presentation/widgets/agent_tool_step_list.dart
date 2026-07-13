import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';

/// Shows the agentic tool calls the coach made while composing a reply.
///
/// Each step animates from a running spinner to a success/error state as the
/// tool resolves, giving the athlete visibility into what data the coach
/// looked up instead of a hidden black box.
class AgentToolStepList extends StatelessWidget {
  const AgentToolStepList({super.key, required this.steps});

  final List<CoachToolStep> steps;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final step in steps) _AgentToolStepRow(step: step),
        ],
      ),
    );
  }
}

class _AgentToolStepRow extends StatelessWidget {
  const _AgentToolStepRow({required this.step});

  final CoachToolStep step;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final label = step.displayLabel ?? step.toolName;
    final color = switch (step.status) {
      CoachToolStatus.running => kynos.purple,
      CoachToolStatus.success => kynos.exercise,
      CoachToolStatus.error => kynos.secondaryLabel,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: switch (step.status) {
              CoachToolStatus.running => SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: color,
                  ),
                ),
              CoachToolStatus.success =>
                Icon(Icons.check_circle_rounded, size: 14, color: color),
              CoachToolStatus.error =>
                Icon(Icons.info_outline_rounded, size: 14, color: color),
            },
          ),
          const Gap(Spacing.xs),
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: Motion.fast,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: kynos.secondaryLabel,
                    fontWeight: FontWeight.w500,
                  ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
