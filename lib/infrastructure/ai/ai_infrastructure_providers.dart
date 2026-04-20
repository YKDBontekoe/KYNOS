import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/infrastructure/ai/on_device_ai_coach_repository.dart';
import 'package:kynos/infrastructure/ai/on_device_model_repository.dart';

/// Provides the [AiCoachRepository] singleton.
///
/// Kept alive for the app lifetime; the repository manages model memory.
/// Disposed automatically when the [ProviderContainer] is destroyed.
final aiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  final repo = OnDeviceAiCoachRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Provides the [AiModelRepository] singleton.
final aiModelRepositoryProvider = Provider<AiModelRepository>((ref) {
  return OnDeviceModelRepository();
});
