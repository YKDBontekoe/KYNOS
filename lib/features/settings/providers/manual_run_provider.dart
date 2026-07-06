import 'package:kynos/core/constants/imported_workout_ids.dart';
import 'package:kynos/domain/entities/workout_session.dart';
import 'package:kynos/shared/providers/health_import_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manual_run_provider.g.dart';

class ManualRunState {
  const ManualRunState({
    required this.start,
    this.isSaving = false,
    this.error,
    this.saveSucceeded = false,
    this.errorToken = 0,
  });

  final DateTime start;
  final bool isSaving;
  final String? error;
  final bool saveSucceeded;
  final int errorToken;

  ManualRunState copyWith({
    DateTime? start,
    bool? isSaving,
    String? error,
    bool? saveSucceeded,
    int? errorToken,
    bool clearError = false,
  }) {
    return ManualRunState(
      start: start ?? this.start,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      saveSucceeded: saveSucceeded ?? this.saveSucceeded,
      errorToken: errorToken ?? this.errorToken,
    );
  }
}

@riverpod
class ManualRun extends _$ManualRun {
  @override
  ManualRunState build() {
    return ManualRunState(
      start: DateTime.now().subtract(const Duration(hours: 1)),
    );
  }

  void setStart(DateTime start) {
    state = state.copyWith(start: start, clearError: true);
  }

  void _emitError(String message) {
    state = state.copyWith(
      error: message,
      errorToken: state.errorToken + 1,
    );
  }

  Future<void> saveRun({
    required int durationMinutes,
    required double distanceKm,
    double? calories,
  }) async {
    if (durationMinutes <= 0) {
      _emitError('Enter a valid duration in minutes.');
      return;
    }
    if (distanceKm <= 0) {
      _emitError('Enter a valid distance in km.');
      return;
    }

    state = state.copyWith(isSaving: true, clearError: true, saveSucceeded: false);

    final workout = WorkoutSession(
      id: ImportedWorkoutIds.generate(),
      start: state.start,
      end: state.start.add(Duration(minutes: durationMinutes)),
      workoutType: 'running',
      distanceMeters: distanceKm * 1000,
      energyKcal: calories,
      sourceName: 'Manual entry',
    );

    final useCase = ref.read(importWorkoutUseCaseProvider);
    final result = await useCase(workout: workout);

    if (result.failure != null) {
      state = state.copyWith(
        isSaving: false,
        error: result.failure!.message,
        errorToken: state.errorToken + 1,
      );
      return;
    }

    invalidateHealthProviders(ref);

    state = state.copyWith(isSaving: false, saveSucceeded: true);
  }
}
