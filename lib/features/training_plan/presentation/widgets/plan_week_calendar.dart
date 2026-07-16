import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/domain/utils/training_plan_week.dart';
import 'package:kynos/features/training_plan/presentation/widgets/plan_week_day_cell.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

/// Mon–Sun week calendar for an active [TrainingPlan].
class PlanWeekCalendar extends StatelessWidget {
  const PlanWeekCalendar({
    super.key,
    required this.plan,
    required this.referenceDate,
    this.onDayTap,
  });

  final TrainingPlan plan;
  final DateTime referenceDate;
  final void Function(DateTime date, PlanDay? day)? onDayTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final dates = planWeekDates(referenceDate);
    final slots = planWeekSlots(plan, referenceDate);
    final counts = planWeekAdherenceCounts(plan, referenceDate);
    final today = planDayKey(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KynosSectionHeader(title: 'This week'),
        const Gap(Spacing.sm),
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: [
            KynosChip.metric(label: 'Done', value: '${counts.done}'),
            KynosChip.metric(label: 'Skipped', value: '${counts.skipped}'),
            KynosChip.metric(label: 'Pending', value: '${counts.pending}'),
          ],
        ),
        const Gap(Spacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cellWidth = (width - Spacing.sm) / 2;
            return Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                for (var i = 0; i < dates.length; i++)
                  SizedBox(
                    width: cellWidth,
                    height: 148,
                    child: PlanWeekDayCell(
                      date: dates[i],
                      day: slots[i],
                      isToday: dates[i] == today,
                      onTap: onDayTap == null
                          ? null
                          : () => onDayTap!(dates[i], slots[i]),
                    ),
                  ),
              ],
            );
          },
        ),
        if (plan.weeklyVolumeTargetKm != null) ...[
          const Gap(Spacing.md),
          Text(
            'Weekly volume target · '
            '${plan.weeklyVolumeTargetKm!.toStringAsFixed(0)} km',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
        ],
      ],
    );
  }
}
