import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';

abstract interface class CharacterRepository {
  Future<({RunnerCharacter? character, Failure? failure})> loadCharacter();
  Future<Failure?> saveCharacter(RunnerCharacter character);

  Future<({List<Quest> quests, Failure? failure})> loadTodayQuests();
  Future<Failure?> saveQuests(List<Quest> quests);

  Future<({CampState? camp, Failure? failure})> loadCampState();
  Future<Failure?> saveCampState(CampState camp);
}
