import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workout_session_lookup_provider.g.dart';

/// Resolves a [WorkoutSession] by id for deep-linked run routes.
@riverpod
Future<WorkoutSession?> workoutSessionById(Ref ref, String runId) async {
  final runs = await ref.watch(recentRunsProvider(days: 365, limit: 200).future);
  for (final run in runs) {
    if (run.id == runId) return run;
  }
  return null;
}
