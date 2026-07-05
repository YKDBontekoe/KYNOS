/// Move points and stamina derived from daily health activity.
class ActivityResources {
  const ActivityResources({
    required this.totalMovePoints,
    required this.totalStamina,
    required this.spentMovePoints,
    required this.spentStamina,
    this.bonusMoveGranted = false,
  });

  final int totalMovePoints;
  final int totalStamina;
  final int spentMovePoints;
  final int spentStamina;
  final bool bonusMoveGranted;

  int get availableMovePoints =>
      (totalMovePoints - spentMovePoints).clamp(0, totalMovePoints);

  int get availableStamina =>
      (totalStamina - spentStamina).clamp(0, totalStamina);

  bool get canAdvance => availableMovePoints > 0;

  ActivityResources copyWith({
    int? totalMovePoints,
    int? totalStamina,
    int? spentMovePoints,
    int? spentStamina,
    bool? bonusMoveGranted,
  }) =>
      ActivityResources(
        totalMovePoints: totalMovePoints ?? this.totalMovePoints,
        totalStamina: totalStamina ?? this.totalStamina,
        spentMovePoints: spentMovePoints ?? this.spentMovePoints,
        spentStamina: spentStamina ?? this.spentStamina,
        bonusMoveGranted: bonusMoveGranted ?? this.bonusMoveGranted,
      );
}
