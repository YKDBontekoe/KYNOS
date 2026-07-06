import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';

class AdvanceWeeklySummitUseCase {
  const AdvanceWeeklySummitUseCase();

  CampState call({
    required CampState camp,
    required DateTime reference,
    int bonusAltitude = 0,
  }) {
    var updated = camp.forCurrentWeek(reference);
    final isSunday = reference.weekday == DateTime.sunday;
    final sundayBonus =
        isSunday ? GamificationConstants.sundaySummitBonus : 0;

    if (bonusAltitude > 0 || sundayBonus > 0) {
      updated = updated.copyWith(
        weeklyAltitude: updated.weeklyAltitude + bonusAltitude + sundayBonus,
      );
    }

    if (updated.weeklyGoal != GamificationConstants.weeklySummitGoal) {
      updated = updated.copyWith(
        weeklyGoal: GamificationConstants.weeklySummitGoal,
      );
    }

    return updated;
  }
}
