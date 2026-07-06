import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/usecases/gamification/generate_daily_quests_usecase.dart';

import '../../../support/fake_ai_repositories.dart';

void main() {
  group('GenerateDailyQuestsUseCase', () {
    final character = RunnerCharacter(
      characterClass: const Apex(),
      level: 3,
      xp: 500,
      stats: const CharacterStats(
        strength: 15,
        endurance: 12,
        speed: 18,
        form: 10,
        recovery: 14,
        willpower: 11,
      ),
      earnedTitles: const [],
      activeTitle: null,
      createdAt: DateTime(2026, 1, 1),
      lastUpdated: DateTime(2026, 4, 20),
    );

    test('returns deterministic quest when model is unavailable', () async {
      final useCase = GenerateDailyQuestsUseCase(
        aiCoachRepository: FakeAiCoachRepository(),
        aiModelRepository: FakeAiModelRepository(hasActiveModel: false),
      );

      final result = await useCase(
        character: character,
        readinessScore: 65,
      );

      expect(result.failure, isNull);
      expect(result.usedModel, isFalse);
      expect(result.quests, hasLength(2));
      expect(result.quests.first.title, isNotEmpty);
      expect(result.quests.last.measurableObjective, isNotNull);
    });
  });
}
