class WorkoutRoutePoint {
  final double latitude;
  final double longitude;
  final DateTime? timestamp;

  const WorkoutRoutePoint({
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp?.toIso8601String(),
      };

  static WorkoutRoutePoint fromJson(Map<String, dynamic> json) {
    return WorkoutRoutePoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.tryParse(json['timestamp'] as String),
    );
  }
}
