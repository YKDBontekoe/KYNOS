import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/training_plan.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

/// One day cell in the plan week calendar.
class PlanWeekDayCell extends StatelessWidget {
  const PlanWeekDayCell({
    super.key,
    required this.date,
    required this.day,
    required this.isToday,
    this.onTap,
  });

  final DateTime date;
  final PlanDay? day;
  final bool isToday;
  final VoidCallback? onTap;

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final label = _weekdayLabels[date.weekday - 1];
    final sessionLabel = day == null
        ? '—'
        : _sessionShort(day!.sessionType);
    final title = day?.title ?? 'No session';
    final adherence = day?.adherence;

    return KynosCard(
      elevated: isToday,
      padding: const EdgeInsets.all(Spacing.sm),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isToday ? kynos.stand : kynos.secondaryLabel,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                '${date.day}',
                style: kynos.metricValueStyle.copyWith(fontSize: 14),
              ),
            ],
          ),
          const Gap(Spacing.xs),
          Text(
            sessionLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Gap(Spacing.xs),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
          if (day?.targetDistanceKm != null) ...[
            const Gap(Spacing.xs),
            Text(
              '${day!.targetDistanceKm!.toStringAsFixed(1)} km',
              style: kynos.metricValueStyle.copyWith(fontSize: 12),
            ),
          ],
          const Spacer(),
          if (adherence != null)
            KynosChip(label: _adherenceLabel(adherence)),
        ],
      ),
    );
  }

  String _sessionShort(PlanSessionType type) => switch (type) {
        PlanSessionType.rest => 'Rest',
        PlanSessionType.easy => 'Easy',
        PlanSessionType.longRun => 'Long',
        PlanSessionType.tempo => 'Tempo',
        PlanSessionType.intervals => 'Ints',
        PlanSessionType.recovery => 'Recov',
        PlanSessionType.race => 'Race',
      };

  String _adherenceLabel(PlanAdherenceStatus status) => switch (status) {
        PlanAdherenceStatus.pending => 'Pending',
        PlanAdherenceStatus.done => 'Done',
        PlanAdherenceStatus.skipped => 'Skipped',
        PlanAdherenceStatus.swapped => 'Swapped',
      };
}
