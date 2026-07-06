import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/expedition_event.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/domain/entities/workout_session.dart';

class ResolveExpeditionResult {
  const ResolveExpeditionResult({
    required this.event,
    this.failure,
  });

  final ExpeditionEvent event;
  final String? failure;

  bool get isSuccess => failure == null;
}

class ResolveExpeditionUseCase {
  const ResolveExpeditionUseCase();

  ResolveExpeditionResult call({
    required RunnerCharacter character,
    required WorkoutSession run,
    required bool expeditionUsedToday,
  }) {
    if (expeditionUsedToday) {
      return const ResolveExpeditionResult(
        event: ExpeditionEvent(
          title: 'Expedition Complete',
          narrative: '',
          xpReward: 0,
        ),
        failure: 'Expedition already launched today.',
      );
    }

    final distanceKm = (run.distanceMeters ?? 0) / 1000;
    final durationMin = run.duration.inMinutes;

    var xp = GamificationConstants.expeditionXpBase +
        (distanceKm * GamificationConstants.expeditionXpPerKm).round();
    xp = (xp * (1 + character.level * 0.02)).round();

    final statDeltas = <CharacterStatId, int>{};
    if (distanceKm >= 5) {
      statDeltas[CharacterStatId.endurance] = 2;
    }
    if (durationMin >= 30) {
      statDeltas[CharacterStatId.willpower] = 1;
    }
    if (distanceKm >= 3) {
      statDeltas[character.stats.weakest] = 1;
    }

    final className = character.characterClass.name;
    final narrative = distanceKm >= 5
        ? '$className led a long push through alpine switchbacks — ${distanceKm.toStringAsFixed(1)} km logged.'
        : '$className scouted the ridgeline on a crisp $durationMin-minute run.';

    return ResolveExpeditionResult(
      event: ExpeditionEvent(
        title: 'Summit Scout',
        narrative: narrative,
        xpReward: xp,
        statDeltas: statDeltas,
        summitBonus: GamificationConstants.expeditionSummitBonus,
      ),
    );
  }
}
