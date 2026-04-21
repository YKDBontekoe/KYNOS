import 'package:flutter/services.dart';
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/repositories/gamekit_repository.dart';

class GameKitRepositoryImpl implements GameKitRepository {
  static const _channel = MethodChannel('kynos/gamekit');

  bool _signedIn = false;

  @override
  bool get isSignedIn => _signedIn;

  @override
  Future<Failure?> signIn() async {
    try {
      final success =
          await _channel.invokeMethod<bool>('signIn') ?? false;
      _signedIn = success;
      return success ? null : const StorageFailure('GameKit sign-in failed');
    } on PlatformException catch (e) {
      return StorageFailure(e.message ?? 'GameKit sign-in error');
    }
  }

  @override
  Future<Failure?> submitScore({
    required String leaderboardId,
    required int score,
  }) async {
    if (!_signedIn) return null;
    try {
      await _channel.invokeMethod<void>('submitScore', {
        'leaderboard_id': leaderboardId,
        'score': score,
      });
      return null;
    } on PlatformException catch (e) {
      return StorageFailure(e.message ?? 'Score submission failed');
    }
  }

  @override
  Future<Failure?> unlockAchievement({
    required String achievementId,
    double percentComplete = 100.0,
  }) async {
    if (!_signedIn) return null;
    try {
      await _channel.invokeMethod<void>('unlockAchievement', {
        'achievement_id': achievementId,
        'percent_complete': percentComplete,
      });
      return null;
    } on PlatformException catch (e) {
      return StorageFailure(e.message ?? 'Achievement unlock failed');
    }
  }

  @override
  Future<void> showLeaderboard({required String leaderboardId}) async {
    if (!_signedIn) return;
    try {
      await _channel.invokeMethod<void>('showLeaderboard', {
        'leaderboard_id': leaderboardId,
      });
    } on PlatformException {
      // Non-fatal UI operation
    }
  }

  @override
  Future<void> showAchievements() async {
    if (!_signedIn) return;
    try {
      await _channel.invokeMethod<void>('showAchievements');
    } on PlatformException {
      // Non-fatal UI operation
    }
  }
}
