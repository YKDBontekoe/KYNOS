import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/repositories/character_repository.dart';
import 'package:kynos/features/character/providers/quest_provider.dart';
import 'package:kynos/shared/providers/daily_quests_provider.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockCharacterRepository extends Mock implements CharacterRepository {}

Quest _testQuest() {
  final now = DateTime(2026, 7, 6);
  return Quest(
    id: 'q1',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    title: 'Test',
    narrative: 'Narrative',
    objective: 'Run',
    status: QuestStatus.active,
    xpReward: 10,
    statRewards: const {},
    generatedAt: now,
    expiresAt: now.add(const Duration(days: 1)),
  );
}

void main() {
  test('completeQuest surfaces StorageFailure when saveQuests fails', () async {
    final repo = _MockCharacterRepository();
    final quest = _testQuest();

    when(() => repo.loadCharacter()).thenAnswer(
      (_) async => (character: null, failure: null),
    );
    when(() => repo.saveQuests(any())).thenAnswer(
      (_) async => const StorageFailure('disk full'),
    );

    final container = ProviderContainer(
      overrides: [
        characterRepositoryProvider.overrideWithValue(repo),
        dailyQuestsProvider.overrideWith((ref) async => [quest]),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(questProvider.notifier);
    await notifier.completeQuest('q1');

    final state = container.read(questProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<StorageFailure>());
  });
}
