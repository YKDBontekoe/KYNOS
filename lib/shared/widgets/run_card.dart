import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

/// Workout session card — shared across training and run history.
class RunCard extends StatelessWidget {
  const RunCard({super.key, required this.run});

  final WorkoutSession run;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final distanceKm =
        run.distanceMeters == null ? null : run.distanceMeters! / 1000;
    final pace = _pacePerKm(run.duration, run.distanceMeters);

    return KynosCard(
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
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: Text(
                  _runDateLabel(run.start),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                run.sourceName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Wrap(
            spacing: tokens.Spacing.sm,
            runSpacing: tokens.Spacing.xs,
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
          const Gap(tokens.Spacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.push(Routes.runRoute, extra: run),
              icon: const Icon(Icons.map_rounded, size: 16),
              label: const Text('View Route In App'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _runDateLabel(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
