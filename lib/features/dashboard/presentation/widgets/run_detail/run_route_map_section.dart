import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/workout_route_point.dart';
import 'package:kynos/features/dashboard/presentation/widgets/run_detail/route_polyline_painter.dart';
import 'package:kynos/shared/utils/url_opener.dart';

const _mapHeight = 260.0;

/// Hero map section — native iOS map or privacy-first polyline preview.
class RunRouteMapSection extends StatelessWidget {
  const RunRouteMapSection({
    super.key,
    required this.points,
  });

  final List<WorkoutRoutePoint> points;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        tokens.Spacing.md,
        tokens.Spacing.sm,
        tokens.Spacing.md,
        tokens.Spacing.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.Radius.lg),
        child: Container(
          height: _mapHeight,
          decoration: BoxDecoration(
            color: kynos.card,
            boxShadow: kynos.cardShadow,
          ),
          child: points.isEmpty
              ? _EmptyMapPlaceholder()
              : _RouteMapBody(points: points),
        ),
      ),
    );
  }
}

class _RouteMapBody extends StatelessWidget {
  const _RouteMapBody({required this.points});

  final List<WorkoutRoutePoint> points;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return _AppleRouteMap(points: points);
    }
    return _PolylineMap(points: points);
  }
}

class _PolylineMap extends StatelessWidget {
  const _PolylineMap({required this.points});

  final List<WorkoutRoutePoint> points;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return CustomPaint(
      painter: RoutePolylinePainter(
        points: points,
        lineColor: kynos.stand,
        startColor: kynos.exercise,
        endColor: kynos.energy,
        gridColor: kynos.separator.withValues(alpha: 0.35),
        markerBorderColor: kynos.card,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _AppleRouteMap extends StatelessWidget {
  const _AppleRouteMap({required this.points});

  final List<WorkoutRoutePoint> points;

  @override
  Widget build(BuildContext context) {
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

class _EmptyMapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return ColoredBox(
      color: kynos.separator.withValues(alpha: 0.2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(tokens.Spacing.md),
          child: Text(
            'Summary metrics only — no GPS route on this run.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
        ),
      ),
    );
  }
}

/// External maps link shown below polyline preview on non-iOS platforms.
class RunRouteExternalMapsButton extends StatelessWidget {
  const RunRouteExternalMapsButton({super.key, required this.points});

  final List<WorkoutRoutePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }

    final first = points.first;
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${first.latitude},${first.longitude}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: tokens.Spacing.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => openExternalUrl(mapsUrl),
          icon: const Icon(Icons.map_outlined, size: 18),
          label: const Text('Open in Maps'),
        ),
      ),
    );
  }
}
