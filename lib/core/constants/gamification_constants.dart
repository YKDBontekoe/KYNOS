/// Gameplay tuning for the Trail Run character mini-game.
abstract final class GamificationConstants {
  static const int maxMovePoints = 20;
  static const int stepsPerMovePoint = 500;
  static const int maxStamina = 50;
  static const int caloriesPerStamina = 25;
  static const int practiceMovePoints = 3;
  static const int practiceStamina = 8;

  static const int trailNodeCount = 7;
  static const int enemyBaseHp = 40;
  static const int enemyHpPerLevel = 8;

  static const int encounterXpEasy = 50;
  static const int encounterXpNormal = 90;
  static const int encounterXpHard = 120;
  static const int encounterXpBoss = 150;

  static const int treasureXp = 40;
  static const int restStaminaRecovery = 6;
}
