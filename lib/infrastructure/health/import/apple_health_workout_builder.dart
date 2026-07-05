import 'package:kynos/infrastructure/health/import/apple_health_date_parser.dart';
import 'package:kynos/infrastructure/health/import/apple_health_unit_converter.dart';
import 'package:xml/xml_events.dart';

String? xmlEventAttr(XmlStartElementEvent event, String name) {
  for (final attribute in event.attributes) {
    if (attribute.name == name) {
      return attribute.value;
    }
  }
  return null;
}

class AppleHealthWorkoutBuilder {
  AppleHealthWorkoutBuilder({
    required this.activityType,
    this.start,
    this.end,
    this.distanceMeters,
    this.energyKcal,
    this.sourceName,
    List<String>? routePaths,
  }) : routePaths = routePaths ?? <String>[];

  factory AppleHealthWorkoutBuilder.fromAttributes(XmlStartElementEvent event) {
    final distance = double.tryParse(xmlEventAttr(event, 'totalDistance') ?? '');
    final energy = double.tryParse(xmlEventAttr(event, 'totalEnergyBurned') ?? '');

    return AppleHealthWorkoutBuilder(
      activityType: xmlEventAttr(event, 'workoutActivityType') ?? '',
      start: parseAppleHealthDate(xmlEventAttr(event, 'startDate')),
      end: parseAppleHealthDate(xmlEventAttr(event, 'endDate')),
      distanceMeters: toMeters(distance, xmlEventAttr(event, 'totalDistanceUnit')),
      energyKcal: toKilocalories(energy, xmlEventAttr(event, 'totalEnergyBurnedUnit')),
      sourceName: xmlEventAttr(event, 'sourceName'),
    );
  }

  final String activityType;
  final DateTime? start;
  final DateTime? end;
  final double? distanceMeters;
  final double? energyKcal;
  final String? sourceName;
  final List<String> routePaths;

  bool get isRunning => activityType.toUpperCase().contains('RUNNING');
}
