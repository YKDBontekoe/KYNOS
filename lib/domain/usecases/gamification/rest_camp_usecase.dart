import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';

class RestCampResult {
  const RestCampResult({
    required this.camp,
    this.failure,
  });

  final CampState camp;
  final String? failure;

  bool get isSuccess => failure == null;
}

class RestCampUseCase {
  const RestCampUseCase();

  RestCampResult call({
    required CampState camp,
    required int availableFocus,
    required DateTime now,
    double sleepHours = 0,
    double readiness = 60,
  }) {
    if (availableFocus < GamificationConstants.focusCostRest) {
      return RestCampResult(
        camp: camp,
        failure: 'Not enough Focus.',
      );
    }

    final today = DateTime(now.year, now.month, now.day);
    if (camp.lastRestDate != null &&
        camp.lastRestDate!.year == today.year &&
        camp.lastRestDate!.month == today.month &&
        camp.lastRestDate!.day == today.day) {
      return RestCampResult(
        camp: camp,
        failure: 'Already rested today.',
      );
    }

    final sleepBonus = (sleepHours / 8).clamp(0.0, 1.0) * 0.2;
    final readinessBonus = (readiness / 100) * 0.2;
    final newMultiplier = (1.0 + sleepBonus + readinessBonus)
        .clamp(1.0, GamificationConstants.maxRestMultiplier);

    final newFatigue = (camp.fatigue - GamificationConstants.fatigueReductionOnRest)
        .clamp(0, 100);

    return RestCampResult(
      camp: camp.copyWith(
        spentFocus: camp.spentFocus + GamificationConstants.focusCostRest,
        lastRestDate: today,
        restMultiplier: newMultiplier,
        fatigue: newFatigue,
        weeklyAltitude: camp.weeklyAltitude + 3,
      ),
    );
  }
}
