import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workout_session_lookup_provider.g.dart';

/// Resolves a [WorkoutSession] by id for deep-linked run routes.
@riverpod
Future<WorkoutSession?> workoutSessionById(Ref ref, String runId) async {
  final repository = ref.watch(healthRepositoryProvider);
  final result = await repository.getWorkoutById(workoutId: runId);
  if (result.failure != null) {
    throw result.failure!;
  }
  return result.workout;
}
