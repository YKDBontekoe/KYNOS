enum TrailNodeType { start, encounter, rest, treasure, boss }

extension TrailNodeTypeLabel on TrailNodeType {
  String get label => switch (this) {
        TrailNodeType.start => 'START',
        TrailNodeType.encounter => 'FIGHT',
        TrailNodeType.rest => 'REST',
        TrailNodeType.treasure => 'LOOT',
        TrailNodeType.boss => 'BOSS',
      };
}

class TrailNode {
  const TrailNode({
    required this.index,
    required this.type,
    required this.enemyId,
    this.resolved = false,
  });

  final int index;
  final TrailNodeType type;

  /// Stable enemy template id for encounter resolution.
  final String enemyId;
  final bool resolved;

  TrailNode copyWith({bool? resolved}) => TrailNode(
        index: index,
        type: type,
        enemyId: enemyId,
        resolved: resolved ?? this.resolved,
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'type': type.name,
        'enemy_id': enemyId,
        'resolved': resolved,
      };

  factory TrailNode.fromJson(Map<String, dynamic> json) => TrailNode(
        index: (json['index'] as num).toInt(),
        type: TrailNodeType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => TrailNodeType.encounter,
        ),
        enemyId: json['enemy_id'] as String? ?? 'trail_grunt',
        resolved: json['resolved'] as bool? ?? false,
      );
}
