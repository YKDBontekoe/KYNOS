import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/infrastructure/ai/ai_infrastructure_providers.dart';

/// Shared mediator for the AI coach repository.
///
/// Features consume this provider instead of importing the infrastructure
/// binding directly, keeping the Feature → Domain ← Infrastructure rule intact.
final sharedAiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  return ref.watch(aiCoachRepositoryProvider);
});

/// Shared mediator for the AI model lifecycle repository.
final sharedAiModelRepositoryProvider = Provider<AiModelRepository>((ref) {
  return ref.watch(aiModelRepositoryProvider);
});
