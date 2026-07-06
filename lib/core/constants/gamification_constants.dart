/// Gameplay tuning for Summit Camp.
abstract final class GamificationConstants {
  // ── Resource accrual ───────────────────────────────────────────────────────
  static const int maxMomentum = 15;
  static const int stepsPerMomentum = 400;
  static const int exerciseMinPerMomentum = 2;

  static const int maxFuel = 20;
  static const int caloriesPerFuel = 20;

  static const int maxFocus = 10;
  static const double sleepHoursPerFocus = 1.0;
  static const double readinessFocusBonus = 0.5; // per 10 readiness pts

  static const int maxSpirit = 9;
  static const int spiritPerRun = 3;

  static const int practiceMomentum = 3;
  static const int practiceFuel = 4;
  static const int practiceFocus = 2;
  static const int practiceSpirit = 0;

  // ── Camp actions ───────────────────────────────────────────────────────────
  static const int momentumPerTileExpand = 2;
  static const int focusCostRest = 3;
  static const int spiritCostExpedition = 3;
  static const double maxRestMultiplier = 1.5;
  static const int fatigueReductionOnRest = 5;
  static const int weeklySummitGoal = 100;
  static const int sundaySummitBonus = 10;

  // ── Expedition rewards ─────────────────────────────────────────────────────
  static const int expeditionXpBase = 60;
  static const int expeditionXpPerKm = 15;
  static const int expeditionSummitBonus = 5;

  // ── Quest targets ──────────────────────────────────────────────────────────
  static const double questStepsEasy = 6000;
  static const double questStepsNormal = 8000;
  static const double questCaloriesEasy = 300;
  static const double questCaloriesNormal = 400;
  static const double questExerciseMinEasy = 20;
  static const double questExerciseMinNormal = 30;
  static const double questSleepEasy = 6.5;
  static const double questSleepNormal = 7.5;
}
