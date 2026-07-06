import 'package:kynos/domain/entities/gamification/camp_building.dart';
import 'package:kynos/domain/entities/gamification/camp_tile.dart';

/// Persistent Summit Camp save state.
class CampState {
  const CampState({
    required this.gridSize,
    required this.tiles,
    required this.buildings,
    required this.weeklyAltitude,
    required this.weeklyGoal,
    required this.weekStart,
    required this.fatigue,
    required this.spentMomentum,
    required this.spentFuel,
    required this.spentFocus,
    required this.spentSpirit,
    this.lastRestDate,
    this.restMultiplier = 1.0,
    this.expeditionUsedToday = false,
    this.dailyDate,
  });

  static const int defaultGridSize = 5;

  final int gridSize;
  final List<CampTile> tiles;
  final List<PlacedBuilding> buildings;
  final int weeklyAltitude;
  final int weeklyGoal;
  final DateTime weekStart;
  final int fatigue;
  final int spentMomentum;
  final int spentFuel;
  final int spentFocus;
  final int spentSpirit;
  final DateTime? lastRestDate;
  final double restMultiplier;
  final bool expeditionUsedToday;

  /// Calendar day when daily spend counters were last reset.
  final DateTime? dailyDate;

  double get summitProgress =>
      weeklyGoal <= 0 ? 0 : (weeklyAltitude / weeklyGoal).clamp(0.0, 1.0);

  bool get summitReached => weeklyAltitude >= weeklyGoal;

  CampTile? tileAt(int row, int col) {
    for (final tile in tiles) {
      if (tile.row == row && tile.col == col) return tile;
    }
    return null;
  }

  PlacedBuilding? buildingAt(int row, int col) {
    for (final b in buildings) {
      if (b.row == row && b.col == col) return b;
    }
    return null;
  }

  bool isAdjacentToUnlocked(int row, int col) {
    const deltas = [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ];
    for (final (dr, dc) in deltas) {
      final neighbor = tileAt(row + dr, col + dc);
      if (neighbor != null && neighbor.status != CampTileStatus.locked) {
        return true;
      }
    }
    return false;
  }

  /// Fresh camp with center tile unlocked.
  factory CampState.initial({DateTime? now}) {
    final today = now ?? DateTime.now();
    final weekStart = _weekStart(today);
    final tiles = <CampTile>[];
    const size = defaultGridSize;
    final center = size ~/ 2;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final isCenter = r == center && c == center;
        tiles.add(
          CampTile(
            row: r,
            col: c,
            status: isCenter ? CampTileStatus.unlocked : CampTileStatus.locked,
          ),
        );
      }
    }
    return CampState(
      gridSize: size,
      tiles: tiles,
      buildings: const [],
      weeklyAltitude: 0,
      weeklyGoal: 100,
      weekStart: weekStart,
      fatigue: 0,
      spentMomentum: 0,
      spentFuel: 0,
      spentFocus: 0,
      spentSpirit: 0,
    );
  }

  static DateTime _weekStart(DateTime date) {
    final weekday = date.weekday; // Mon=1
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Roll week if [reference] is in a new ISO week.
  CampState forCurrentWeek(DateTime reference) {
    final start = _weekStart(reference);
    if (start.year == weekStart.year &&
        start.month == weekStart.month &&
        start.day == weekStart.day) {
      return this;
    }
    return copyWith(
      weekStart: start,
      weeklyAltitude: 0,
      weeklyGoal: 100,
    );
  }

  /// Reset daily spend counters when [reference] is a new calendar day.
  CampState forCurrentDay(DateTime reference) {
    final day = DateTime(reference.year, reference.month, reference.day);
    if (dailyDate != null &&
        dailyDate!.year == day.year &&
        dailyDate!.month == day.month &&
        dailyDate!.day == day.day) {
      return this;
    }
    return copyWith(
      dailyDate: day,
      spentMomentum: 0,
      spentFuel: 0,
      spentFocus: 0,
      spentSpirit: 0,
      expeditionUsedToday: false,
    );
  }

  CampState copyWith({
    int? gridSize,
    List<CampTile>? tiles,
    List<PlacedBuilding>? buildings,
    int? weeklyAltitude,
    int? weeklyGoal,
    DateTime? weekStart,
    int? fatigue,
    int? spentMomentum,
    int? spentFuel,
    int? spentFocus,
    int? spentSpirit,
    DateTime? lastRestDate,
    double? restMultiplier,
    bool? expeditionUsedToday,
    DateTime? dailyDate,
  }) =>
      CampState(
        gridSize: gridSize ?? this.gridSize,
        tiles: tiles ?? this.tiles,
        buildings: buildings ?? this.buildings,
        weeklyAltitude: weeklyAltitude ?? this.weeklyAltitude,
        weeklyGoal: weeklyGoal ?? this.weeklyGoal,
        weekStart: weekStart ?? this.weekStart,
        fatigue: fatigue ?? this.fatigue,
        spentMomentum: spentMomentum ?? this.spentMomentum,
        spentFuel: spentFuel ?? this.spentFuel,
        spentFocus: spentFocus ?? this.spentFocus,
        spentSpirit: spentSpirit ?? this.spentSpirit,
        lastRestDate: lastRestDate ?? this.lastRestDate,
        restMultiplier: restMultiplier ?? this.restMultiplier,
        expeditionUsedToday:
            expeditionUsedToday ?? this.expeditionUsedToday,
        dailyDate: dailyDate ?? this.dailyDate,
      );

  Map<String, dynamic> toJson() => {
        'grid_size': gridSize,
        'tiles': tiles.map((t) => t.toJson()).toList(),
        'buildings': buildings.map((b) => b.toJson()).toList(),
        'weekly_altitude': weeklyAltitude,
        'weekly_goal': weeklyGoal,
        'week_start': weekStart.toIso8601String(),
        'fatigue': fatigue,
        'spent_momentum': spentMomentum,
        'spent_fuel': spentFuel,
        'spent_focus': spentFocus,
        'spent_spirit': spentSpirit,
        'last_rest_date': lastRestDate?.toIso8601String(),
        'rest_multiplier': restMultiplier,
        'expedition_used_today': expeditionUsedToday,
        'daily_date': dailyDate?.toIso8601String(),
      };

  factory CampState.fromJson(Map<String, dynamic> json) {
    final tileList = (json['tiles'] as List<dynamic>?)
            ?.map((t) => CampTile.fromJson(t as Map<String, dynamic>))
            .toList() ??
        CampState.initial().tiles;
    final buildingList = (json['buildings'] as List<dynamic>?)
            ?.map((b) => PlacedBuilding.fromJson(b as Map<String, dynamic>))
            .toList() ??
        const <PlacedBuilding>[];
    return CampState(
      gridSize: (json['grid_size'] as num?)?.toInt() ?? defaultGridSize,
      tiles: tileList,
      buildings: buildingList,
      weeklyAltitude: (json['weekly_altitude'] as num?)?.toInt() ?? 0,
      weeklyGoal: (json['weekly_goal'] as num?)?.toInt() ?? 100,
      weekStart: DateTime.tryParse(json['week_start'] as String? ?? '') ??
          CampState._weekStart(DateTime.now()),
      fatigue: (json['fatigue'] as num?)?.toInt() ?? 0,
      spentMomentum: (json['spent_momentum'] as num?)?.toInt() ?? 0,
      spentFuel: (json['spent_fuel'] as num?)?.toInt() ?? 0,
      spentFocus: (json['spent_focus'] as num?)?.toInt() ?? 0,
      spentSpirit: (json['spent_spirit'] as num?)?.toInt() ?? 0,
      lastRestDate: json['last_rest_date'] != null
          ? DateTime.tryParse(json['last_rest_date'] as String)
          : null,
      restMultiplier: (json['rest_multiplier'] as num?)?.toDouble() ?? 1.0,
      expeditionUsedToday: json['expedition_used_today'] as bool? ?? false,
      dailyDate: json['daily_date'] != null
          ? DateTime.tryParse(json['daily_date'] as String)
          : null,
    );
  }
}
