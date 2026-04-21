import 'dart:convert';

import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/repositories/character_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterPersistenceRepository implements CharacterRepository {
  static const _characterKey = 'kynos_runner_character_v1';
  static const _questsKey = 'kynos_daily_quests_v1';

  @override
  Future<({RunnerCharacter? character, Failure? failure})>
      loadCharacter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_characterKey);
      if (json == null) return (character: null, failure: null);
      final character = RunnerCharacter.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      return (character: character, failure: null);
    } catch (e) {
      return (
        character: null,
        failure: StorageFailure('Failed to load character: $e'),
      );
    }
  }

  @override
  Future<Failure?> saveCharacter(RunnerCharacter character) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_characterKey, jsonEncode(character.toJson()));
      return null;
    } catch (e) {
      return StorageFailure('Failed to save character: $e');
    }
  }

  @override
  Future<({List<Quest> quests, Failure? failure})> loadTodayQuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_questsKey);
      if (json == null) return (quests: const <Quest>[], failure: null);

      final list = jsonDecode(json) as List<dynamic>;
      final quests = list
          .map((q) => Quest.fromJson(q as Map<String, dynamic>))
          .toList();

      // Only return quests generated today
      final today = DateTime.now();
      final todayQuests = quests.where((q) {
        final d = q.generatedAt;
        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day;
      }).toList();

      return (quests: todayQuests, failure: null);
    } catch (e) {
      return (
        quests: const <Quest>[],
        failure: StorageFailure('Failed to load quests: $e'),
      );
    }
  }

  @override
  Future<Failure?> saveQuests(List<Quest> quests) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _questsKey,
        jsonEncode(quests.map((q) => q.toJson()).toList()),
      );
      return null;
    } catch (e) {
      return StorageFailure('Failed to save quests: $e');
    }
  }
}
