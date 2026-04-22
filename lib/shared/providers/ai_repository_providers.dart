import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/infrastructure/ai/on_device_ai_coach_repository.dart';
import 'package:kynos/infrastructure/ai/on_device_model_repository.dart';

/// Canonical singleton for the on-device AI coach.
///
/// Kept alive for the entire app lifetime; the repository owns model memory.
final aiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  final repo = OnDeviceAiCoachRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Canonical singleton for model lifecycle management (install / initialise).
final aiModelRepositoryProvider = Provider<AiModelRepository>((ref) {
  return OnDeviceModelRepository();
});
