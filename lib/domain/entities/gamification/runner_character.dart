import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/earned_title.dart';

class RunnerCharacter {
  const RunnerCharacter({
    required this.characterClass,
    required this.level,
    required this.xp,
    required this.stats,
    this.earnedTitles = const [],
    this.activeTitle,
    required this.createdAt,
    required this.lastUpdated,
  });

  final CharacterClass characterClass;

  /// Current level (1–50).
  final int level;

  /// Cumulative XP ever earned.
  final int xp;

  final CharacterStats stats;
  final List<EarnedTitle> earnedTitles;

  /// Display title shown under class name.
  final String? activeTitle;

  final DateTime createdAt;
  final DateTime lastUpdated;

  // ── Level curve ────────────────────────────────────────────────────────────

  /// Cumulative XP required to reach [level].
  static int xpThreshold(int level) {
    if (level <= 1) return 0;
    return (100 * (level - 1) * (1 + (level - 1) * 0.15)).round();
  }

  int get xpForCurrentLevel => xpThreshold(level);
  int get xpForNextLevel => xpThreshold(level + 1);

  double get levelProgress {
    final span = xpForNextLevel - xpForCurrentLevel;
    if (span <= 0) return 1.0;
    return ((xp - xpForCurrentLevel) / span).clamp(0.0, 1.0);
  }

  int get xpToNextLevel => (xpForNextLevel - xp).clamp(0, xpForNextLevel);

  // ── Mutations ──────────────────────────────────────────────────────────────

  RunnerCharacter withXpGain(
    int amount, {
    Map<CharacterStatId, int>? statDeltas,
  }) {
    final newXp = xp + amount;
    var newLevel = level;
    while (xpThreshold(newLevel + 1) <= newXp && newLevel < 50) {
      newLevel++;
    }
    return copyWith(
      xp: newXp,
      level: newLevel,
      stats: statDeltas != null ? stats.applyDeltas(statDeltas) : null,
      lastUpdated: DateTime.now(),
    );
  }

  RunnerCharacter withTitle(EarnedTitle title) => copyWith(
        earnedTitles: [...earnedTitles, title],
        activeTitle: activeTitle ?? title.name,
        lastUpdated: DateTime.now(),
      );

  RunnerCharacter copyWith({
    CharacterClass? characterClass,
    int? level,
    int? xp,
    CharacterStats? stats,
    List<EarnedTitle>? earnedTitles,
    String? activeTitle,
    DateTime? lastUpdated,
  }) =>
      RunnerCharacter(
        characterClass: characterClass ?? this.characterClass,
        level: level ?? this.level,
        xp: xp ?? this.xp,
        stats: stats ?? this.stats,
        earnedTitles: earnedTitles ?? this.earnedTitles,
        activeTitle: activeTitle ?? this.activeTitle,
        createdAt: createdAt,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );

  // ── Serialisation ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'class_id': characterClass.id,
        'level': level,
        'xp': xp,
        'stats': stats.toJson(),
        'earned_titles':
            earnedTitles.map((t) => t.toJson()).toList(),
        'active_title': activeTitle,
        'created_at': createdAt.toIso8601String(),
        'last_updated': lastUpdated.toIso8601String(),
      };

  factory RunnerCharacter.fromJson(Map<String, dynamic> json) =>
      RunnerCharacter(
        characterClass: CharacterClass.fromId(
          json['class_id'] as String? ?? 'apex',
        ),
        level: (json['level'] as num?)?.toInt() ?? 1,
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        stats: CharacterStats.fromJson(
          json['stats'] as Map<String, dynamic>? ?? {},
        ),
        earnedTitles: (json['earned_titles'] as List<dynamic>?)
                ?.map((t) => EarnedTitle.fromJson(t as Map<String, dynamic>))
                .toList() ??
            const [],
        activeTitle: json['active_title'] as String?,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
        lastUpdated:
            DateTime.tryParse(json['last_updated'] as String? ?? '') ??
                DateTime.now(),
      );
}
