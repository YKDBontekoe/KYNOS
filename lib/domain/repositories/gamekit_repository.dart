import 'package:kynos/core/errors/failures.dart';

abstract interface class GameKitRepository {
  bool get isSignedIn;

  Future<Failure?> signIn();

  Future<Failure?> submitScore({
    required String leaderboardId,
    required int score,
  });

  Future<Failure?> unlockAchievement({
    required String achievementId,
    double percentComplete = 100.0,
  });

  Future<void> showLeaderboard({required String leaderboardId});

  Future<void> showAchievements();
}

/// GameKit leaderboard IDs — must match values configured in App Store Connect.
abstract final class LeaderboardIds {
  static const weeklyDistance = 'kynos.leaderboard.weekly_distance';
  static const athleteScore = 'kynos.leaderboard.athlete_score';
  static const seasonRank = 'kynos.leaderboard.season_rank';
}

/// GameKit achievement IDs — must match values configured in App Store Connect.
abstract final class AchievementIds {
  static const firstRun = 'kynos.achievement.first_run';
  static const firstTenKm = 'kynos.achievement.first_10km';
  static const streak7 = 'kynos.achievement.streak_7';
  static const streak30 = 'kynos.achievement.streak_30';
  static const level5 = 'kynos.achievement.level_5';
  static const level10 = 'kynos.achievement.level_10';
  static const level25 = 'kynos.achievement.level_25';
  static const formMaster = 'kynos.achievement.form_master';
  static const ironWill = 'kynos.achievement.iron_will';
  static const ghostHunter = 'kynos.achievement.ghost_hunter';
}
