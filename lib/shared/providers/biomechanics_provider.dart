import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/biomechanics_repository.dart';
import 'package:kynos/domain/usecases/nexus_lab/calibrate_gait_model_usecase.dart';
import 'package:kynos/infrastructure/ai/biomechanics/on_device_biomechanics_repository.dart';
import 'package:kynos/shared/providers/health_providers.dart';

final biomechanicsRepositoryProvider = Provider<BiomechanicsRepository>((ref) {
  final repository = OnDeviceBiomechanicsRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final calibrateGaitModelUseCaseProvider = Provider<CalibrateGaitModelUseCase>((
  ref,
) {
  return CalibrateGaitModelUseCase(
    healthRepository: ref.watch(healthRepositoryProvider),
    biomechanicsRepository: ref.watch(biomechanicsRepositoryProvider),
  );
});
