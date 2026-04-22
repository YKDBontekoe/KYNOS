import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/biomechanics_repository.dart';
import 'package:kynos/shared/providers/biomechanics_provider.dart';

class NexusLabState {
  NexusLabState({
    required this.coefficients,
    this.calibrationSummary,
    this.sampleCount = 0,
    this.calibratedAt,
  });

  final ({double? b0, double? b1, double? b2}) coefficients;
  final String? calibrationSummary;
  final int sampleCount;
  final DateTime? calibratedAt;

  NexusLabState copyWith({
    ({double? b0, double? b1, double? b2})? coefficients,
    String? calibrationSummary,
    int? sampleCount,
    DateTime? calibratedAt,
  }) {
    return NexusLabState(
      coefficients: coefficients ?? this.coefficients,
      calibrationSummary: calibrationSummary ?? this.calibrationSummary,
      sampleCount: sampleCount ?? this.sampleCount,
      calibratedAt: calibratedAt ?? this.calibratedAt,
    );
  }
}

class NexusLabNotifier extends AsyncNotifier<NexusLabState> {
  @override
  Future<NexusLabState> build() async {
    final BiomechanicsRepository repository = ref.read(
      biomechanicsRepositoryProvider,
    );
    if (kIsWeb) {
      return NexusLabState(coefficients: repository.coefficients);
    }
    final restoreFailure = await repository.restore();
    if (restoreFailure != null) {
      throw restoreFailure;
    }
    return NexusLabState(coefficients: repository.coefficients);
  }

  Future<void> calibrate() async {
    state = const AsyncLoading();

    final useCase = ref.read(calibrateGaitModelUseCaseProvider);
    final result = await useCase();

    if (result.failure != null) {
      state = AsyncError(result.failure!, StackTrace.current);
      return;
    }

    state = AsyncData(
      NexusLabState(
        coefficients: result.coefficients,
        calibrationSummary: result.calibrationSummary,
        sampleCount: result.sampleCount,
        calibratedAt: DateTime.now(),
      ),
    );
  }
}

final nexusLabNotifierProvider =
    AsyncNotifierProvider<NexusLabNotifier, NexusLabState>(
      NexusLabNotifier.new,
    );
