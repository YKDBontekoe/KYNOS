/// Structures players can build on unlocked camp tiles.
enum CampBuildingType {
  trackLoop,
  recoveryYurt,
  paceTower,
  summitBeacon;

  String get label => switch (this) {
        trackLoop => 'Track Loop',
        recoveryYurt => 'Recovery Yurt',
        paceTower => 'Pace Tower',
        summitBeacon => 'Summit Beacon',
      };

  String get description => switch (this) {
        trackLoop => 'Daily movement hub. Boosts Momentum cap.',
        recoveryYurt => 'Sleep sanctuary. Improves Rest bonuses.',
        paceTower => 'Run lookout. Strengthens expeditions.',
        summitBeacon => 'Weekly climb anchor. Advances summit meter.',
      };

  /// Fuel cost to place at level 1.
  int get baseFuelCost => switch (this) {
        trackLoop => 4,
        recoveryYurt => 5,
        paceTower => 6,
        summitBeacon => 8,
      };

  /// Fuel cost to upgrade from [level] to next level.
  int upgradeFuelCost(int level) => baseFuelCost + level * 2;

  /// Summit altitude contributed per building level.
  int summitContribution(int level) => switch (this) {
        trackLoop => level,
        recoveryYurt => level,
        paceTower => level * 2,
        summitBeacon => level * 3,
      };
}

class PlacedBuilding {
  const PlacedBuilding({
    required this.type,
    required this.level,
    required this.row,
    required this.col,
  });

  final CampBuildingType type;
  final int level;
  final int row;
  final int col;

  PlacedBuilding copyWith({
    CampBuildingType? type,
    int? level,
    int? row,
    int? col,
  }) =>
      PlacedBuilding(
        type: type ?? this.type,
        level: level ?? this.level,
        row: row ?? this.row,
        col: col ?? this.col,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'level': level,
        'row': row,
        'col': col,
      };

  factory PlacedBuilding.fromJson(Map<String, dynamic> json) {
    final type = CampBuildingType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => CampBuildingType.trackLoop,
    );
    return PlacedBuilding(
      type: type,
      level: (json['level'] as num?)?.toInt() ?? 1,
      row: (json['row'] as num?)?.toInt() ?? 0,
      col: (json['col'] as num?)?.toInt() ?? 0,
    );
  }
}
