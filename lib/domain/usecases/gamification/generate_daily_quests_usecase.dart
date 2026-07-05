import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';

class GenerateDailyQuestsUseCase {
  const GenerateDailyQuestsUseCase({
    required AiCoachRepository aiCoachRepository,
    required AiModelRepository aiModelRepository,
  })  : _aiCoachRepository = aiCoachRepository,
        _aiModelRepository = aiModelRepository;

  final AiCoachRepository _aiCoachRepository;
  final AiModelRepository _aiModelRepository;

  Future<({List<Quest> quests, Failure? failure, bool usedModel})> call({
    required RunnerCharacter character,
    required double readinessScore,
  }) async {
    final base = _buildDeterministicQuests(
      character: character,
      readiness: readinessScore,
    );
    final refined =
        await _tryRefineWithModel(character: character, readiness: readinessScore, baseQuests: base);
    return (quests: refined ?? base, failure: null, usedModel: refined != null);
  }

  List<Quest> _buildDeterministicQuests({
    required RunnerCharacter character,
    required double readiness,
  }) {
    final weakStat = character.stats.weakest;
    final now = DateTime.now();
    final expires =
        DateTime(now.year, now.month, now.day, 23, 59, 59);

    return [
      _questForStat(
        stat: weakStat,
        classId: character.characterClass.id,
        readiness: readiness,
        now: now,
        expires: expires,
      ),
      _healthMetricQuest(readiness: readiness, now: now, expires: expires),
    ];
  }

  Quest _healthMetricQuest({
    required double readiness,
    required DateTime now,
    required DateTime expires,
  }) {
    final id = 'daily_health_${now.millisecondsSinceEpoch}';
    final useSteps = now.day.isEven;
    final difficulty = readiness >= 60
        ? QuestDifficulty.normal
        : QuestDifficulty.easy;
    final xp = difficulty == QuestDifficulty.normal ? 150 : 100;

    if (useSteps) {
      final target = readiness >= 60 ? 8000.0 : 6000.0;
      return Quest(
        id: id,
        type: QuestType.daily,
        difficulty: difficulty,
        title: 'Step Patrol',
        narrative: 'Every step fuels the trail. Walk the path today.',
        objective: 'Reach ${target.toInt()} steps today.',
        status: QuestStatus.active,
        xpReward: xp,
        statRewards: {CharacterStatId.endurance: 2, CharacterStatId.willpower: 1},
        generatedAt: now,
        expiresAt: expires,
        measurableObjective: QuestObjective(
          kind: QuestObjectiveKind.steps,
          target: target,
        ),
      );
    }

    final target = readiness >= 60 ? 400.0 : 300.0;
    return Quest(
      id: id,
      type: QuestType.daily,
      difficulty: difficulty,
      title: 'Calorie Forge',
      narrative: 'Burn energy. Build stamina for the fights ahead.',
      objective: 'Burn ${target.toInt()} active calories today.',
      status: QuestStatus.active,
      xpReward: xp,
      statRewards: {CharacterStatId.strength: 2, CharacterStatId.recovery: 1},
      generatedAt: now,
      expiresAt: expires,
      measurableObjective: QuestObjective(
        kind: QuestObjectiveKind.activeCalories,
        target: target,
      ),
    );
  }

  Quest _questForStat({
    required CharacterStatId stat,
    required String classId,
    required double readiness,
    required DateTime now,
    required DateTime expires,
  }) {
    final id = 'daily_${now.millisecondsSinceEpoch}';
    final difficulty = readiness >= 70
        ? QuestDifficulty.hard
        : readiness >= 50
            ? QuestDifficulty.normal
            : QuestDifficulty.easy;

    final xp = switch (difficulty) {
      QuestDifficulty.easy => 120,
      QuestDifficulty.normal => 180,
      QuestDifficulty.hard => 260,
      QuestDifficulty.legendary => 400,
    };

    return switch (stat) {
      CharacterStatId.form => Quest(
          id: id,
          type: QuestType.daily,
          difficulty: difficulty,
          title: 'Steel Cadence',
          narrative:
              'Your stride wavers. Today you forge it into something that never will.',
          objective: readiness >= 60
              ? 'Run 6 km maintaining cadence above 170 spm for at least half the distance.'
              : 'Run 20 minutes focusing on cadence. Hit 165+ spm consistently.',
          status: QuestStatus.active,
          xpReward: xp,
          statRewards: {CharacterStatId.form: 4, CharacterStatId.endurance: 1},
          generatedAt: now,
          expiresAt: expires,
        ),
      CharacterStatId.endurance => Quest(
          id: id,
          type: QuestType.daily,
          difficulty: difficulty,
          title: 'The Long March',
          narrative:
              'Endurance is not built in a single run. But it is built today.',
          objective: readiness >= 60
              ? 'Complete a run of 60+ minutes at easy aerobic pace.'
              : 'Run 30–40 minutes at conversational pace. No heroics today.',
          status: QuestStatus.active,
          xpReward: xp,
          statRewards: {CharacterStatId.endurance: 4, CharacterStatId.recovery: 1},
          generatedAt: now,
          expiresAt: expires,
        ),
      CharacterStatId.speed => Quest(
          id: id,
          type: QuestType.daily,
          difficulty: difficulty,
          title: 'Strike Fast',
          narrative: 'Speed fades when untrained. Today it sharpens.',
          objective: readiness >= 60
              ? 'Run 5 km with 4 × 400 m at sub-5:00/km pace. Full recovery between reps.'
              : 'Run 3 × 1 min at fast effort with 2 min easy jog between.',
          status: QuestStatus.active,
          xpReward: xp,
          statRewards: {CharacterStatId.speed: 4, CharacterStatId.strength: 1},
          generatedAt: now,
          expiresAt: expires,
        ),
      CharacterStatId.strength => Quest(
          id: id,
          type: QuestType.daily,
          difficulty: difficulty,
          title: 'Power Circuit',
          narrative: 'The engine needs work. Today you rebuild it.',
          objective: readiness >= 60
              ? 'Run 8 km with 3 × 5 min at threshold effort (RPE 7–8). Strong finish.'
              : 'Run 5 km with 2 × 3 min at moderate effort. Controlled power.',
          status: QuestStatus.active,
          xpReward: xp,
          statRewards: {CharacterStatId.strength: 4, CharacterStatId.endurance: 1},
          generatedAt: now,
          expiresAt: expires,
        ),
      CharacterStatId.recovery => Quest(
          id: id,
          type: QuestType.daily,
          difficulty: QuestDifficulty.easy,
          title: 'Restoration Protocol',
          narrative:
              'Recovery is not the absence of training. It is training.',
          objective:
              'Run 25–35 minutes at very easy pace (HR below 135 bpm). No pushing.',
          status: QuestStatus.active,
          xpReward: 100,
          statRewards: {
            CharacterStatId.recovery: 4,
            CharacterStatId.willpower: 1,
          },
          generatedAt: now,
          expiresAt: expires,
        ),
      CharacterStatId.willpower => Quest(
          id: id,
          type: QuestType.daily,
          difficulty: QuestDifficulty.hard,
          title: 'The Unbroken',
          narrative:
              'The mind quits long before the body does. Prove yours wrong today.',
          objective:
              'Complete any run today regardless of how you feel. Minimum 20 minutes.',
          status: QuestStatus.active,
          xpReward: 200,
          statRewards: {CharacterStatId.willpower: 5},
          generatedAt: now,
          expiresAt: expires,
        ),
    };
  }

  Future<List<Quest>?> _tryRefineWithModel({
    required RunnerCharacter character,
    required double readiness,
    required List<Quest> baseQuests,
  }) async {
    try {
      await _aiModelRepository.initialize();
      if (!_aiModelRepository.hasActiveModel) return null;

      final quest = baseQuests.first;
      final prompt = StringBuffer()
        ..writeln(
          'Rewrite this quest in the voice of ${character.characterClass.name}.',
        )
        ..writeln('Class lore: ${character.characterClass.lore}')
        ..writeln('Readiness today: ${readiness.round()}/100')
        ..writeln(
          'Weakest stat: ${character.stats.weakest.fullName}',
        )
        ..writeln(
          'Model size is small: keep all output short and punchy. No long explanations.',
        )
        ..writeln('Return EXACTLY these keys, one per line:')
        ..writeln('TITLE: short quest name (max 4 words)')
        ..writeln('NARRATIVE: one atmospheric sentence in the class voice')
        ..writeln('OBJECTIVE: concrete specific training goal')
        ..writeln('')
        ..writeln('Current:')
        ..writeln('TITLE: ${quest.title}')
        ..writeln('NARRATIVE: ${quest.narrative}')
        ..writeln('OBJECTIVE: ${quest.objective}');

      await _aiCoachRepository.resetSession();
      final buffer = StringBuffer();
      await for (final chunk
          in _aiCoachRepository.chat(userMessage: prompt.toString())) {
        buffer.write(chunk);
      }

      final refined = _parseModelOutput(buffer.toString(), quest);
      return refined != null ? [refined] : null;
    } catch (_) {
      return null;
    }
  }

  Quest? _parseModelOutput(String raw, Quest base) {
    String? take(String key) {
      final match =
          RegExp('$key\\s*:(.*)', multiLine: true).firstMatch(raw);
      return match?.group(1)?.trim();
    }

    final title = take('TITLE');
    final narrative = take('NARRATIVE');
    final objective = take('OBJECTIVE');

    if (title == null ||
        narrative == null ||
        objective == null ||
        title.isEmpty ||
        narrative.isEmpty ||
        objective.isEmpty) {
      return null;
    }

    return base.copyWith(title: title, narrative: narrative, objective: objective);
  }
}
