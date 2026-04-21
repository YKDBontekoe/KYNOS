import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'character_provider.g.dart';

/// Loads the persisted [RunnerCharacter], creating one via class assignment
/// if this is the athlete's first session.
///
/// Kept alive so the character is available app-wide without re-fetching.
@Riverpod(keepAlive: true)
Future<RunnerCharacter?> runnerCharacter(RunnerCharacterRef ref) async {
  final repo = ref.read(characterRepositoryProvider);
  final loadResult = await repo.loadCharacter();

  if (loadResult.failure != null) return null;
  if (loadResult.character != null) return loadResult.character;

  // First launch: analyse health history and assign a class.
  final assignUseCase = ref.read(assignCharacterClassUseCaseProvider);
  final assignResult = await assignUseCase();

  if (assignResult.failure != null || assignResult.character == null) {
    return null;
  }

  await repo.saveCharacter(assignResult.character!);
  return assignResult.character;
}
