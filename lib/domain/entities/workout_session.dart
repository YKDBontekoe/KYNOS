class WorkoutSession {
  final String id;
  final DateTime start;
  final DateTime end;
  final String workoutType;
  final double? distanceMeters;
  final double? energyKcal;
  final int? steps;
  final String sourceName;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;

  const WorkoutSession({
    required this.id,
    required this.start,
    required this.end,
    required this.workoutType,
    this.distanceMeters,
    this.energyKcal,
    this.steps,
    required this.sourceName,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
  });

  Duration get duration => end.difference(start);

  bool get hasRouteCoordinates =>
      startLatitude != null &&
      startLongitude != null &&
      endLatitude != null &&
      endLongitude != null;
}
