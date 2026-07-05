import 'package:kynos/domain/entities/gamification/activity_resources.dart';
import 'package:kynos/domain/entities/gamification/encounter_state.dart';
import 'package:kynos/domain/entities/gamification/trail_node.dart';

class AdventureSession {
  const AdventureSession({
    required this.date,
    required this.nodes,
    required this.currentIndex,
    required this.spentMovePoints,
    required this.spentStamina,
    this.activeEncounter,
    this.trailCompleted = false,
    this.bonusMoveUsed = false,
  });

  final DateTime date;
  final List<TrailNode> nodes;
  final int currentIndex;
  final int spentMovePoints;
  final int spentStamina;
  final EncounterState? activeEncounter;
  final bool trailCompleted;
  final bool bonusMoveUsed;

  TrailNode? get currentNode =>
      currentIndex >= 0 && currentIndex < nodes.length
          ? nodes[currentIndex]
          : null;

  bool get atTrailEnd => currentIndex >= nodes.length - 1;

  AdventureSession copyWith({
    List<TrailNode>? nodes,
    int? currentIndex,
    int? spentMovePoints,
    int? spentStamina,
    EncounterState? activeEncounter,
    bool clearEncounter = false,
    bool? trailCompleted,
    bool? bonusMoveUsed,
  }) =>
      AdventureSession(
        date: date,
        nodes: nodes ?? this.nodes,
        currentIndex: currentIndex ?? this.currentIndex,
        spentMovePoints: spentMovePoints ?? this.spentMovePoints,
        spentStamina: spentStamina ?? this.spentStamina,
        activeEncounter:
            clearEncounter ? null : (activeEncounter ?? this.activeEncounter),
        trailCompleted: trailCompleted ?? this.trailCompleted,
        bonusMoveUsed: bonusMoveUsed ?? this.bonusMoveUsed,
      );

  ActivityResources resourcesFromTotals({
    required int totalMovePoints,
    required int totalStamina,
  }) =>
      ActivityResources(
        totalMovePoints: totalMovePoints,
        totalStamina: totalStamina,
        spentMovePoints: spentMovePoints,
        spentStamina: spentStamina,
        bonusMoveGranted: bonusMoveUsed,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'current_index': currentIndex,
        'spent_move_points': spentMovePoints,
        'spent_stamina': spentStamina,
        'active_encounter': activeEncounter?.toJson(),
        'trail_completed': trailCompleted,
        'bonus_move_used': bonusMoveUsed,
      };

  factory AdventureSession.fromJson(Map<String, dynamic> json) =>
      AdventureSession(
        date: DateTime.parse(json['date'] as String),
        nodes: (json['nodes'] as List<dynamic>)
            .map((n) => TrailNode.fromJson(n as Map<String, dynamic>))
            .toList(),
        currentIndex: (json['current_index'] as num?)?.toInt() ?? 0,
        spentMovePoints: (json['spent_move_points'] as num?)?.toInt() ?? 0,
        spentStamina: (json['spent_stamina'] as num?)?.toInt() ?? 0,
        activeEncounter: json['active_encounter'] != null
            ? EncounterState.fromJson(
                json['active_encounter'] as Map<String, dynamic>,
              )
            : null,
        trailCompleted: json['trail_completed'] as bool? ?? false,
        bonusMoveUsed: json['bonus_move_used'] as bool? ?? false,
      );
}
