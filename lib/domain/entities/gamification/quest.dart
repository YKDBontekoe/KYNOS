import 'package:kynos/domain/entities/gamification/character_stats.dart';

enum QuestType { daily, epic, arc, boss }

enum QuestStatus { active, completed, failed, expired }

enum QuestDifficulty { easy, normal, hard, legendary }

enum QuestObjectiveKind {
  steps,
  activeCalories,
  runMinutes,
  runDistanceKm,
  manual,
}

class QuestObjective {
  const QuestObjective({
    required this.kind,
    required this.target,
  });

  final QuestObjectiveKind kind;
  final double target;

  bool get isMeasurable => kind != QuestObjectiveKind.manual;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'target': target,
      };

  factory QuestObjective.fromJson(Map<String, dynamic> json) => QuestObjective(
        kind: QuestObjectiveKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => QuestObjectiveKind.manual,
        ),
        target: (json['target'] as num?)?.toDouble() ?? 0,
      );
}

extension QuestTypeLabel on QuestType {
  String get label => switch (this) {
        QuestType.daily => 'DAILY',
        QuestType.epic => 'EPIC',
        QuestType.arc => 'ARC',
        QuestType.boss => 'BOSS',
      };
}

extension QuestDifficultyLabel on QuestDifficulty {
  String get label => switch (this) {
        QuestDifficulty.easy => 'EASY',
        QuestDifficulty.normal => 'NORMAL',
        QuestDifficulty.hard => 'HARD',
        QuestDifficulty.legendary => 'LEGENDARY',
      };
}

class Quest {
  const Quest({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.title,
    required this.narrative,
    required this.objective,
    required this.status,
    required this.xpReward,
    required this.statRewards,
    required this.generatedAt,
    required this.expiresAt,
    this.titleReward,
    this.completedAt,
    this.measurableObjective,
  });

  final String id;
  final QuestType type;
  final QuestDifficulty difficulty;

  /// Short quest name shown as header.
  final String title;

  /// AI-generated atmospheric flavor sentence in the character's voice.
  final String narrative;

  /// Concrete, actionable training goal for the session.
  final String objective;

  final QuestStatus status;
  final int xpReward;
  final Map<CharacterStatId, int> statRewards;
  final DateTime generatedAt;
  final DateTime expiresAt;

  /// Title ID unlocked on completion (optional).
  final String? titleReward;
  final DateTime? completedAt;

  /// When set, progress is computed from health data instead of manual completion.
  final QuestObjective? measurableObjective;

  bool get isExpired =>
      DateTime.now().isAfter(expiresAt) && status == QuestStatus.active;

  Quest copyWith({
    String? title,
    String? narrative,
    String? objective,
    QuestStatus? status,
    DateTime? completedAt,
    QuestObjective? measurableObjective,
  }) =>
      Quest(
        id: id,
        type: type,
        difficulty: difficulty,
        title: title ?? this.title,
        narrative: narrative ?? this.narrative,
        objective: objective ?? this.objective,
        status: status ?? this.status,
        xpReward: xpReward,
        statRewards: statRewards,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
        titleReward: titleReward,
        completedAt: completedAt ?? this.completedAt,
        measurableObjective: measurableObjective ?? this.measurableObjective,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'difficulty': difficulty.name,
        'title': title,
        'narrative': narrative,
        'objective': objective,
        'status': status.name,
        'xp_reward': xpReward,
        'stat_rewards': statRewards.map((k, v) => MapEntry(k.name, v)),
        'generated_at': generatedAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'title_reward': titleReward,
        'completed_at': completedAt?.toIso8601String(),
        if (measurableObjective != null)
          'measurable_objective': measurableObjective!.toJson(),
      };

  factory Quest.fromJson(Map<String, dynamic> json) {
    final raw = json['stat_rewards'] as Map<String, dynamic>? ?? {};
    final statRewards = <CharacterStatId, int>{};
    for (final entry in raw.entries) {
      final stat = CharacterStatId.values
          .where((s) => s.name == entry.key)
          .firstOrNull;
      if (stat != null) {
        statRewards[stat] = (entry.value as num).toInt();
      }
    }
    return Quest(
      id: json['id'] as String,
      type: QuestType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => QuestType.daily,
      ),
      difficulty: QuestDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => QuestDifficulty.normal,
      ),
      title: json['title'] as String,
      narrative: json['narrative'] as String,
      objective: json['objective'] as String,
      status: QuestStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => QuestStatus.active,
      ),
      xpReward: (json['xp_reward'] as num).toInt(),
      statRewards: statRewards,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      titleReward: json['title_reward'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      measurableObjective: json['measurable_objective'] != null
          ? QuestObjective.fromJson(
              json['measurable_objective'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
