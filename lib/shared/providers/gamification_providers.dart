import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/character_repository.dart';
import 'package:kynos/domain/repositories/gamekit_repository.dart';
import 'package:kynos/domain/usecases/gamification/assign_character_class_usecase.dart';
import 'package:kynos/domain/usecases/gamification/compute_activity_resources_usecase.dart';
import 'package:kynos/domain/usecases/gamification/compute_xp_usecase.dart';
import 'package:kynos/domain/usecases/gamification/evaluate_quest_progress_usecase.dart';
import 'package:kynos/domain/usecases/gamification/generate_daily_quests_usecase.dart';
import 'package:kynos/domain/usecases/gamification/generate_daily_trail_usecase.dart';
import 'package:kynos/domain/usecases/gamification/resolve_encounter_turn_usecase.dart';
import 'package:kynos/infrastructure/gamification/character_persistence_repository.dart';
import 'package:kynos/infrastructure/gamification/gamekit_repository_impl.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterPersistenceRepository();
});

final gameKitRepositoryProvider = Provider<GameKitRepository>((ref) {
  return GameKitRepositoryImpl();
});

final assignCharacterClassUseCaseProvider =
    Provider<AssignCharacterClassUseCase>((ref) {
  return AssignCharacterClassUseCase(
    healthRepository: ref.watch(healthRepositoryProvider),
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

final computeActivityResourcesUseCaseProvider =
    Provider<ComputeActivityResourcesUseCase>((ref) {
  return const ComputeActivityResourcesUseCase();
});

final generateDailyTrailUseCaseProvider =
    Provider<GenerateDailyTrailUseCase>((ref) {
  return const GenerateDailyTrailUseCase();
});

final resolveEncounterTurnUseCaseProvider =
    Provider<ResolveEncounterTurnUseCase>((ref) {
  return const ResolveEncounterTurnUseCase();
});

final evaluateQuestProgressUseCaseProvider =
    Provider<EvaluateQuestProgressUseCase>((ref) {
  return const EvaluateQuestProgressUseCase();
});
