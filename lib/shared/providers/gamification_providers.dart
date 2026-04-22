import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/character_repository.dart';
import 'package:kynos/domain/repositories/gamekit_repository.dart';
import 'package:kynos/domain/usecases/gamification/assign_character_class_usecase.dart';
import 'package:kynos/domain/usecases/gamification/compute_xp_usecase.dart';
import 'package:kynos/domain/usecases/gamification/generate_daily_quests_usecase.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/infrastructure/gamification/character_persistence_repository.dart';
import 'package:kynos/infrastructure/gamification/gamekit_repository_impl.dart';
import 'package:kynos/shared/providers/health_repository_provider.dart';

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterPersistenceRepository();
});

final gameKitRepositoryProvider = Provider<GameKitRepository>((ref) {
  return GameKitRepositoryImpl();
});

final assignCharacterClassUseCaseProvider =
    Provider<AssignCharacterClassUseCase>((ref) {
  return AssignCharacterClassUseCase(
    healthRepository: ref.watch(sharedHealthRepositoryProvider),
  );
});

final computeXpUseCaseProvider = Provider<ComputeXpUseCase>((ref) {
  return const ComputeXpUseCase();
});

final generateDailyQuestsUseCaseProvider =
    Provider<GenerateDailyQuestsUseCase>((ref) {
  return GenerateDailyQuestsUseCase(
    aiCoachRepository: ref.watch(aiCoachRepositoryProvider),
    aiModelRepository: ref.watch(aiModelRepositoryProvider),
  );
});
