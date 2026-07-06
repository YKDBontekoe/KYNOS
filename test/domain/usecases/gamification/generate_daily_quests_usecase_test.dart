import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/ai_task_kind.dart';
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/domain/usecases/gamification/generate_daily_quests_usecase.dart';

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
        aiCoachRepository: _FakeAiCoachRepository(),
        aiModelRepository: _FakeAiModelRepository(hasActiveModel: false),
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

class _FakeAiCoachRepository implements AiCoachRepository {
  @override
  bool get isReady => false;

  @override
  AiInferenceBackend lastBackend = AiInferenceBackend.onDevice;

  @override
  Stream<String> chat({
    required String userMessage,
    List<HealthSummary>? healthContext,
    AiTaskKind taskKind = AiTaskKind.coachChat,
    int estimatedPromptTokens = 0,
    AiInferenceBackend? preferredBackend,
  }) async* {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> resetSession() async {}
}

class _FakeAiModelRepository implements AiModelRepository {
  _FakeAiModelRepository({required this.hasActiveModel});

  @override
  final bool hasActiveModel;

  @override
  Future<void> initialize({String? huggingFaceToken}) async {}

  @override
  Future<void> installFromNetwork({required String url, String? token}) async {}
}
