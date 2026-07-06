import 'package:kynos/core/constants/gamification_constants.dart';
import 'package:kynos/domain/entities/gamification/camp_resources.dart';
import 'package:kynos/domain/entities/gamification/camp_state.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/domain/utils/readiness_score.dart' as readiness;

class ComputeCampResourcesUseCase {
  const ComputeCampResourcesUseCase();

  CampResources call({
    HealthSummary? summary,
    required CampState camp,
    double? readinessOverride,
  }) {
    if (summary == null) {
      return CampResources(
        totalMomentum: GamificationConstants.practiceMomentum,
        totalFuel: GamificationConstants.practiceFuel,
        totalFocus: GamificationConstants.practiceFocus,
        totalSpirit: GamificationConstants.practiceSpirit,
        spentMomentum: camp.spentMomentum,
        spentFuel: camp.spentFuel,
        spentFocus: camp.spentFocus,
        spentSpirit: camp.spentSpirit,
        restMultiplier: camp.restMultiplier,
      );
    }

    final readinessScore = readinessOverride ??
        readiness.readinessScoreOrDefault(summary);

    final steps = summary.steps ?? 0;
    final exerciseMin = (summary.exerciseMinutes ?? 0).round();
    var momentum = (steps ~/ GamificationConstants.stepsPerMomentum) +
        (exerciseMin ~/ GamificationConstants.exerciseMinPerMomentum);
    momentum = _applyMultiplier(
      momentum,
      GamificationConstants.maxMomentum,
      camp.restMultiplier,
    );

    final calories = summary.activeCalories ?? 0;
    var fuel = (calories ~/ GamificationConstants.caloriesPerFuel).toInt();
    fuel = _applyMultiplier(
      fuel,
      GamificationConstants.maxFuel,
      camp.restMultiplier,
    );

    final sleepHours = summary.sleepHours ?? 0;
    var focus = (sleepHours / GamificationConstants.sleepHoursPerFocus)
        .floor();
    focus += (readinessScore / 10 * GamificationConstants.readinessFocusBonus)
        .floor();
    focus = _applyMultiplier(
      focus,
      GamificationConstants.maxFocus,
      camp.restMultiplier,
    );

    final runCount = summary.runningWorkoutCount ?? 0;
    var spirit = runCount * GamificationConstants.spiritPerRun;
    spirit = spirit.clamp(0, GamificationConstants.maxSpirit);

    return CampResources(
      totalMomentum: momentum,
      totalFuel: fuel,
      totalFocus: focus,
      totalSpirit: spirit,
      spentMomentum: camp.spentMomentum,
      spentFuel: camp.spentFuel,
      spentFocus: camp.spentFocus,
      spentSpirit: camp.spentSpirit,
      restMultiplier: camp.restMultiplier,
    );
  }

  int _applyMultiplier(int value, int max, double multiplier) {
    final boosted = (value * multiplier).round();
    return boosted.clamp(0, (max * multiplier).round());
  }
}
