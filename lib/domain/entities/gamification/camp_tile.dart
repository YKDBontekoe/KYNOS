enum CampTileStatus {
  locked,
  unlocked,
  built;

  String get label => switch (this) {
        locked => 'Locked',
        unlocked => 'Open',
        built => 'Built',
      };
}

class CampTile {
  const CampTile({
    required this.row,
    required this.col,
    required this.status,
  });

  final int row;
  final int col;
  final CampTileStatus status;

  bool get isLocked => status == CampTileStatus.locked;
  bool get isUnlocked => status == CampTileStatus.unlocked;
  bool get isBuilt => status == CampTileStatus.built;

  CampTile copyWith({
    int? row,
    int? col,
    CampTileStatus? status,
  }) =>
      CampTile(
        row: row ?? this.row,
        col: col ?? this.col,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'status': status.name,
      };

  factory CampTile.fromJson(Map<String, dynamic> json) {
    final status = CampTileStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => CampTileStatus.locked,
    );
    return CampTile(
      row: (json['row'] as num?)?.toInt() ?? 0,
      col: (json['col'] as num?)?.toInt() ?? 0,
      status: status,
    );
  }
}
