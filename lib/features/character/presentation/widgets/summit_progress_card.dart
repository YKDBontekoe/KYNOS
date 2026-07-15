import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/shared/widgets/animated_progress_bar.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class SummitProgressCard extends StatelessWidget {
  const SummitProgressCard({super.key, required this.camp});

  final CampState camp;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final isSunday = DateTime.now().weekday == DateTime.sunday;

    return KynosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'WEEKLY SUMMIT',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Spacer(),
              if (isSunday)
                Text(
                  'SUMMIT PUSH',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: kynos.energy,
                        fontWeight: FontWeight.w700,
                      ),
                ),
            ],
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            'Complete runs this week to climb toward the summit goal.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
          const Gap(tokens.Spacing.sm),
          AnimatedProgressBar(
            value: camp.summitProgress,
            minHeight: 10,
            backgroundColor: kynos.separator,
            valueColor: kynos.move,
            borderRadius: 5,
          ),
          const Gap(tokens.Spacing.xs),
          Row(
            children: [
              Text(
                '${camp.weeklyAltitude} m',
                style: kynos.metricValueStyle.copyWith(fontSize: 18),
              ),
              Text(
                ' / ${camp.weeklyGoal} m',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kynos.secondaryLabel,
                    ),
              ),
              const Spacer(),
              if (camp.summitReached)
                Icon(Icons.flag_rounded, color: kynos.exercise, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
