import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:kynos/shared/providers/workout_session_lookup_provider.dart';
import 'package:kynos/shared/utils/url_opener.dart';
import 'package:kynos/shared/widgets/kynos_inline_error_card.dart';
import 'package:kynos/shared/widgets/kynos_skeleton.dart';
import 'package:kynos/shared/widgets/run_card.dart';

class RunRoutePage extends ConsumerWidget {
  const RunRoutePage({super.key, this.run, this.runId})
      : assert(run != null || runId != null);

  final WorkoutSession? run;
  final String? runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final resolvedRun = run;
    if (resolvedRun != null) {
      return _RunRouteScaffold(run: resolvedRun);
    }

    final lookup = ref.watch(workoutSessionByIdProvider(runId!));
    return lookup.when(
      loading: () => Scaffold(
        backgroundColor: kynos.background,
        appBar: _runRouteAppBar(context),
        body: const Padding(
          padding: EdgeInsets.all(tokens.Spacing.md),
          child: KynosSkeleton.tile(height: 300),
        ),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: kynos.background,
        appBar: _runRouteAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(tokens.Spacing.md),
          child: KynosInlineErrorCard(
            message: 'Could not load this run.',
            onRetry: () => ref.invalidate(workoutSessionByIdProvider(runId!)),
          ),
        ),
      ),
      data: (session) {
        if (session == null) {
          return Scaffold(
            backgroundColor: kynos.background,
            appBar: _runRouteAppBar(context),
            body: const Center(child: Text('Run not found on this device.')),
          );
        }
        return _RunRouteScaffold(run: session);
      },
    );
  }
}

AppBar _runRouteAppBar(BuildContext context, {WorkoutSession? run}) {
  final kynos = context.kynosTheme;
  return AppBar(
    title: run != null
        ? Hero(
            tag: RunHeroTags.date(run.id),
            child: Material(
              color: Colors.transparent,
              child: Text(_runDateLabel(run.start)),
            ),
          )
        : const Text('Run Route'),
    backgroundColor: kynos.background,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(Routes.dashboard);
        }
      },
    ),
  );
}

class _RunRouteScaffold extends ConsumerWidget {
  const _RunRouteScaffold({required this.run});

  final WorkoutSession run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final routeAsync = ref.watch(runRouteProvider(workoutUuid: run.id));

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: _runRouteAppBar(context, run: run),
      body: routeAsync.when(
        data: (points) => _RouteContent(run: run, points: points),
        loading: () => const Padding(
          padding: EdgeInsets.all(tokens.Spacing.md),
          child: KynosSkeleton.tile(height: 300),
        ),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(tokens.Spacing.md),
          child: KynosInlineErrorCard(
            message: 'Could not load the workout route. Try again in a moment.',
            onRetry: () => ref.invalidate(runRouteProvider(workoutUuid: run.id)),
          ),
        ),
      ),
    );
  }
}

class _RouteContent extends StatelessWidget {
  const _RouteContent({required this.run, required this.points});

  final WorkoutSession run;
  final List<WorkoutRoutePoint> points;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final hasPoints = points.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: hasPoints
              ? _AppleRouteMap(points: points)
              : _UnavailableMapPlaceholder(points: points),
        ),
        Container(
          color: kynos.card,
          width: double.infinity,
          padding: const EdgeInsets.all(tokens.Spacing.md),
          child: Wrap(
            spacing: tokens.Spacing.md,
            runSpacing: tokens.Spacing.sm,
            children: [
              _chip(context, 'Date', _runDateLabel(run.start)),
              _chip(context, 'Duration', _durationLabel(run.duration)),
              _chip(
                context,
                'Distance',
                run.distanceMeters == null
                    ? '—'
                    : '${(run.distanceMeters! / 1000).toStringAsFixed(2)} km',
              ),
              _chip(context, 'Points', points.length.toString()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, String value) {
    final kynos = context.kynosTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: tokens.Spacing.sm,
        vertical: tokens.Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: kynos.background,
        borderRadius: BorderRadius.circular(tokens.Radius.md),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _AppleRouteMap extends StatelessWidget {
  const _AppleRouteMap({required this.points});

  final List<WorkoutRoutePoint> points;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return _UnavailableMapPlaceholder(points: points);
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
  const _UnavailableMapPlaceholder({required this.points});

  final List<WorkoutRoutePoint> points;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final first = points.isNotEmpty ? points.first : null;
    final mapsUrl = first == null
        ? null
        : 'https://www.google.com/maps/search/?api=1&query=${first.latitude},${first.longitude}';

    return ColoredBox(
      color: kynos.separator.withValues(alpha: 0.35),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(tokens.Spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No in-app map on this platform.\n'
                'KYNOS reads HKWorkoutRoute on iOS when present.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (mapsUrl != null) ...[
                const Gap(tokens.Spacing.md),
                FilledButton.icon(
                  onPressed: () => openExternalUrl(mapsUrl),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Open in Maps'),
                ),
              ],
            ],
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
