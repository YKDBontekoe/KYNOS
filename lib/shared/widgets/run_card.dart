import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/constants/hero_tags.dart';
import 'package:kynos/shared/utils/run_date_label.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

/// Workout session card — shared across training and run history.
class RunCard extends StatelessWidget {
  const RunCard({super.key, required this.run});

  final WorkoutSession run;

  void _openRoute(BuildContext context) {
    context.push('${Routes.runRoute}/${run.id}', extra: run);
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final distanceKm =
        run.distanceMeters == null ? null : run.distanceMeters! / 1000;
    final pace = _pacePerKm(run.duration, run.distanceMeters);

    return KynosCard(
      onTap: () => _openRoute(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: kynos.stand,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(Spacing.sm),
              Expanded(
                child: Hero(
                  tag: RunHeroTags.date(run.id),
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      formatRunHeroDateLabel(run.start),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  run.sourceName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const Gap(Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.xs,
            children: [
              KynosChip.metric(
                label: 'Distance',
                value: distanceKm == null
                    ? '—'
                    : '${distanceKm.toStringAsFixed(2)} km',
              ),
              KynosChip.metric(
                label: 'Duration',
                value: _durationLabel(run.duration),
              ),
              if (pace != null) KynosChip.metric(label: 'Pace', value: pace),
              if (run.energyKcal != null)
                KynosChip.metric(
                  label: 'Calories',
                  value: '${run.energyKcal!.round()} kcal',
                ),
            ],
          ),
          const Gap(Spacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _openRoute(context),
              icon: const Icon(Icons.map_rounded, size: 16),
              label: const Text('View Route In App'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 48),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _durationLabel(Duration duration) {
  final h = duration.inHours;
  final m = duration.inMinutes % 60;
  final s = duration.inSeconds % 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String? _pacePerKm(Duration duration, double? distanceMeters) {
  if (distanceMeters == null || distanceMeters <= 0) return null;
  final paceSeconds = duration.inSeconds / (distanceMeters / 1000);
  final paceMin = paceSeconds ~/ 60;
  final paceSec = (paceSeconds % 60).round();
  return '$paceMin:${paceSec.toString().padLeft(2, '0')} /km';
}
