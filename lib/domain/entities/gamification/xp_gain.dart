import 'package:kynos/domain/entities/gamification/character_stats.dart';

/// Represents a single XP award event with optional stat deltas.
class XpGain {
  const XpGain({
    required this.amount,
    required this.source,
    required this.earnedAt,
    this.statDeltas,
  });

  final int amount;

  /// Human-readable source label, e.g. 'run_completed', 'daily_quest', 'streak'.
  final String source;

  final DateTime earnedAt;

  /// Per-stat point increments to apply alongside the XP gain.
  final Map<CharacterStatId, int>? statDeltas;
}
