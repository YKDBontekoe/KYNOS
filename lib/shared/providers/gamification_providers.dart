import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/character_repository.dart';
import 'package:kynos/domain/repositories/gamekit_repository.dart';
import 'package:kynos/domain/usecases/gamification/advance_weekly_summit_usecase.dart';
import 'package:kynos/domain/usecases/gamification/assign_character_class_usecase.dart';
import 'package:kynos/domain/usecases/gamification/build_camp_structure_usecase.dart';
import 'package:kynos/domain/usecases/gamification/compute_camp_resources_usecase.dart';
import 'package:kynos/domain/usecases/gamification/compute_xp_usecase.dart';
import 'package:kynos/domain/usecases/gamification/evaluate_quest_progress_usecase.dart';
import 'package:kynos/domain/usecases/gamification/expand_camp_tile_usecase.dart';
import 'package:kynos/domain/usecases/gamification/generate_camp_quests_usecase.dart';
import 'package:kynos/domain/usecases/gamification/resolve_expedition_usecase.dart';
import 'package:kynos/domain/usecases/gamification/rest_camp_usecase.dart';
import 'package:kynos/infrastructure/gamification/character_persistence_repository.dart';
import 'package:kynos/infrastructure/gamification/gamekit_repository_impl.dart';
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

final generateCampQuestsUseCaseProvider =
    Provider<GenerateCampQuestsUseCase>((ref) {
  return const GenerateCampQuestsUseCase();
});

final computeCampResourcesUseCaseProvider =
    Provider<ComputeCampResourcesUseCase>((ref) {
  return const ComputeCampResourcesUseCase();
});

final expandCampTileUseCaseProvider = Provider<ExpandCampTileUseCase>((ref) {
  return const ExpandCampTileUseCase();
});

final buildCampStructureUseCaseProvider =
    Provider<BuildCampStructureUseCase>((ref) {
  return const BuildCampStructureUseCase();
});

final restCampUseCaseProvider = Provider<RestCampUseCase>((ref) {
  return const RestCampUseCase();
});

final resolveExpeditionUseCaseProvider =
    Provider<ResolveExpeditionUseCase>((ref) {
  return const ResolveExpeditionUseCase();
});

final advanceWeeklySummitUseCaseProvider =
    Provider<AdvanceWeeklySummitUseCase>((ref) {
  return const AdvanceWeeklySummitUseCase();
});

final evaluateQuestProgressUseCaseProvider =
    Provider<EvaluateQuestProgressUseCase>((ref) {
  return const EvaluateQuestProgressUseCase();
});
