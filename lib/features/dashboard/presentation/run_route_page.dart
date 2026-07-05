import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/features/dashboard/providers/health_provider.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';

class RunRoutePage extends ConsumerWidget {
  final WorkoutSession run;

  const RunRoutePage({super.key, required this.run});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(runRouteProvider(workoutUuid: run.id));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Run Route'),
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: routeAsync.when(
        data: (points) => _RouteContent(run: run, points: points),
        loading: () => const Padding(
          padding: EdgeInsets.all(tokens.Spacing.md),
          child: KynosSkeleton.tile(height: 300),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(tokens.Spacing.md),
            child: Text(
              'Could not load workout route: $error',
              style: const TextStyle(color: AppTheme.move),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteContent extends StatelessWidget {
  final WorkoutSession run;
  final List<WorkoutRoutePoint> points;

  const _RouteContent({required this.run, required this.points});

  @override
  Widget build(BuildContext context) {
    final hasPoints = points.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: hasPoints
              ? _AppleRouteMap(points: points)
              : const _UnavailableMapPlaceholder(),
        ),
        Container(
          color: AppTheme.card,
          width: double.infinity,
          padding: const EdgeInsets.all(tokens.Spacing.md),
          child: Wrap(
            spacing: tokens.Spacing.md,
            runSpacing: tokens.Spacing.sm,
            children: [
              _chip('Date', _runDateLabel(run.start)),
              _chip('Duration', _durationLabel(run.duration)),
              _chip(
                'Distance',
                run.distanceMeters == null
                    ? '—'
                    : '${(run.distanceMeters! / 1000).toStringAsFixed(2)} km',
              ),
              _chip('Points', points.length.toString()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: tokens.Spacing.sm,
        vertical: tokens.Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(tokens.Radius.md),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _AppleRouteMap extends StatelessWidget {
  final List<WorkoutRoutePoint> points;

  const _AppleRouteMap({required this.points});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const _UnavailableMapPlaceholder();
    }

    final payload = <String, dynamic>{
      'points': points
          .map((p) => <String, dynamic>{
                'latitude': p.latitude,
                'longitude': p.longitude,
                'timestamp': p.timestamp?.toIso8601String(),
              })
          .toList(),
    };

    return UiKitView(
      viewType: 'kynos/apple_route_map',
      creationParams: payload,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

class _UnavailableMapPlaceholder extends StatelessWidget {
  const _UnavailableMapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.separator.withValues(alpha: 0.35),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.Spacing.md),
          child: Text(
            'No route coordinates available for this run yet.\nKYNOS reads HKWorkoutRoute on iOS when present.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

String _runDateLabel(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _durationLabel(Duration duration) {
  final h = duration.inHours;
  final m = duration.inMinutes % 60;
  final s = duration.inSeconds % 60;
  if (h > 0) {
    return '${h}h ${m}m';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
