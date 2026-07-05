import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/adventure_session.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';

abstract interface class CharacterRepository {
  Future<({RunnerCharacter? character, Failure? failure})> loadCharacter();
  Future<Failure?> saveCharacter(RunnerCharacter character);

  Future<({List<Quest> quests, Failure? failure})> loadTodayQuests();
  Future<Failure?> saveQuests(List<Quest> quests);

  Future<({AdventureSession? session, Failure? failure})> loadAdventureSession();
  Future<Failure?> saveAdventureSession(AdventureSession session);
}
