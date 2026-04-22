import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

/// Compact card summarising a single run. Used by both the Training tab
/// and the Run History screen.
class RunCard extends StatelessWidget {
  const RunCard({super.key, required this.run});

  final WorkoutSession run;

  @override
  Widget build(BuildContext context) {
    final distanceKm = run.distanceMeters == null
        ? null
        : run.distanceMeters! / 1000;
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
                decoration: const BoxDecoration(
                  color: AppTheme.stand,
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
              _Chip(
                label: 'Distance',
                value: distanceKm == null
                    ? '—'
                    : '${distanceKm.toStringAsFixed(2)} km',
              ),
              _Chip(label: 'Duration', value: _durationLabel(run.duration)),
              if (pace != null) _Chip(label: 'Pace', value: pace),
              if (run.energyKcal != null)
                _Chip(
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: tokens.Spacing.sm,
        vertical: tokens.Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(tokens.Radius.md),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.tertiaryLabel,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.dmMono(
                fontSize: 12,
                color: AppTheme.label,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
  final paceMinutes = paceSeconds ~/ 60;
  final paceRemainderSeconds = (paceSeconds % 60).round();
  return '$paceMinutes:${paceRemainderSeconds.toString().padLeft(2, '0')} /km';
}
