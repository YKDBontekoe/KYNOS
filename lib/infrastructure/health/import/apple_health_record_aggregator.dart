import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/infrastructure/health/import/apple_health_date_parser.dart';
import 'package:kynos/infrastructure/health/import/apple_health_unit_converter.dart';

/// Aggregates Apple Health `Record` and `ActivitySummary` elements into daily
/// [HealthSummary] values — mirrors [aggregateHealthSummaries] for HealthKit.
class AppleHealthRecordAggregator {
  final _byDay = <DateTime, _DailyAccumulator>{};

  void addRecord({
    required String type,
    String? value,
    String? unit,
    required String startDate,
    required String endDate,
  }) {
    final start = parseAppleHealthDate(startDate);
    if (start == null) {
      return;
    }

    final day = DateTime(start.year, start.month, start.day);
    final acc = _byDay.putIfAbsent(day, () => _DailyAccumulator(date: day));
    final numeric = double.tryParse(value ?? '');

    switch (type) {
      case 'HKQuantityTypeIdentifierHeartRateVariabilitySDNN':
        if (numeric != null) acc.addHrv(numeric);
      case 'HKQuantityTypeIdentifierRestingHeartRate':
        if (numeric != null) acc.addRhr(numeric);
      case 'HKQuantityTypeIdentifierHeartRate':
        if (numeric != null) acc.addHeartRate(numeric);
      case 'HKQuantityTypeIdentifierRespiratoryRate':
        if (numeric != null) acc.addRespiratoryRate(numeric);
      case 'HKQuantityTypeIdentifierOxygenSaturation':
        if (numeric != null) acc.addBloodOxygen(toBloodOxygenPercent(numeric)!);
      case 'HKCategoryTypeIdentifierSleepAnalysis':
        _addSleep(acc, value, startDate, endDate);
      case 'HKQuantityTypeIdentifierActiveEnergyBurned':
        if (!acc.hasActivitySummary && numeric != null) {
          acc.activeCalories += toKilocalories(numeric, unit)!;
        }
      case 'HKQuantityTypeIdentifierBasalEnergyBurned':
        if (numeric != null) acc.basalCalories += toKilocalories(numeric, unit)!;
      case 'HKQuantityTypeIdentifierStepCount':
        if (numeric != null) acc.steps += numeric.round();
      case 'HKQuantityTypeIdentifierDistanceWalkingRunning':
        if (numeric != null) {
          acc.distanceMeters += toMeters(numeric, unit) ?? numeric;
        }
      case 'HKQuantityTypeIdentifierFlightsClimbed':
        if (numeric != null) acc.flightsClimbed += numeric;
      case 'HKQuantityTypeIdentifierAppleExerciseTime':
        if (!acc.hasActivitySummary && numeric != null) {
          acc.exerciseMinutes += toMinutes(numeric, unit) ?? numeric;
        }
      case 'HKQuantityTypeIdentifierRunningPower':
        if (numeric != null) acc.addRunningPower(numeric);
      case 'HKQuantityTypeIdentifierRunningCadence':
        if (numeric != null) acc.addCadence(numeric);
      case 'HKQuantityTypeIdentifierRunningStrideLength':
        if (numeric != null) {
          acc.addStrideLength(toMeters(numeric, unit) ?? numeric);
        }
      default:
        break;
    }
  }

  void addActivitySummary({
    required String dateComponents,
    String? activeEnergyBurned,
    String? activeEnergyBurnedUnit,
    String? appleExerciseTime,
  }) {
    final day = _parseDateComponents(dateComponents);
    if (day == null) {
      return;
    }

    final acc = _byDay.putIfAbsent(day, () => _DailyAccumulator(date: day));
    acc.hasActivitySummary = true;

    final energy = double.tryParse(activeEnergyBurned ?? '');
    if (energy != null) {
      acc.activeCalories = toKilocalories(energy, activeEnergyBurnedUnit) ?? energy;
    }

    final exercise = double.tryParse(appleExerciseTime ?? '');
    if (exercise != null) {
      acc.exerciseMinutes = exercise;
    }
  }

  List<HealthSummary> finalize() {
    return _byDay.values
        .map((acc) => acc.toSummary())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _addSleep(
    _DailyAccumulator acc,
    String? categoryValue,
    String startDate,
    String endDate,
  ) {
    if (!_isAsleepCategory(categoryValue)) {
      return;
    }

    final start = parseAppleHealthDate(startDate);
    final end = parseAppleHealthDate(endDate);
    if (start == null || end == null) {
      return;
    }

    final minutes = end.difference(start).inMinutes.toDouble();
    if (minutes > 0) {
      acc.sleepMinutes += minutes;
    }
  }

  bool _isAsleepCategory(String? value) {
    if (value == null) {
      return false;
    }

    return value.contains('Asleep') && !value.contains('Awake');
  }

  DateTime? _parseDateComponents(String raw) {
    final parts = raw.split('-');
    if (parts.length != 3) {
      return null;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }

    return DateTime(year, month, day);
  }
}

class _DailyAccumulator {
  _DailyAccumulator({required this.date});

  final DateTime date;

  bool hasActivitySummary = false;

  double _hrvSum = 0;
  int _hrvCount = 0;
  double _rhrSum = 0;
  int _rhrCount = 0;
  double _heartRateSum = 0;
  int _heartRateCount = 0;
  double _respiratoryRateSum = 0;
  int _respiratoryRateCount = 0;
  double _bloodOxygenSum = 0;
  int _bloodOxygenCount = 0;
  double _runningPowerSum = 0;
  int _runningPowerCount = 0;
  double _cadenceSum = 0;
  int _cadenceCount = 0;
  double _strideLengthSum = 0;
  int _strideLengthCount = 0;

  double sleepMinutes = 0;
  double activeCalories = 0;
  double basalCalories = 0;
  int steps = 0;
  double distanceMeters = 0;
  double flightsClimbed = 0;
  double exerciseMinutes = 0;

  void addHrv(double value) {
    _hrvSum += value;
    _hrvCount += 1;
  }

  void addRhr(double value) {
    _rhrSum += value;
    _rhrCount += 1;
  }

  void addHeartRate(double value) {
    _heartRateSum += value;
    _heartRateCount += 1;
  }

  void addRespiratoryRate(double value) {
    _respiratoryRateSum += value;
    _respiratoryRateCount += 1;
  }

  void addBloodOxygen(double value) {
    _bloodOxygenSum += value;
    _bloodOxygenCount += 1;
  }

  void addRunningPower(double value) {
    _runningPowerSum += value;
    _runningPowerCount += 1;
  }

  void addCadence(double value) {
    _cadenceSum += value;
    _cadenceCount += 1;
  }

  void addStrideLength(double value) {
    _strideLengthSum += value;
    _strideLengthCount += 1;
  }

  HealthSummary toSummary() {
    final totalCalories = activeCalories + basalCalories;
    return HealthSummary(
      date: date,
      hrvMs: _hrvCount == 0 ? null : _hrvSum / _hrvCount,
      rhrBpm: _rhrCount == 0 ? null : _rhrSum / _rhrCount,
      avgHeartRateBpm:
          _heartRateCount == 0 ? null : _heartRateSum / _heartRateCount,
      respiratoryRateBrpm: _respiratoryRateCount == 0
          ? null
          : _respiratoryRateSum / _respiratoryRateCount,
      bloodOxygenPercent:
          _bloodOxygenCount == 0 ? null : _bloodOxygenSum / _bloodOxygenCount,
      sleepHours: sleepMinutes == 0 ? null : sleepMinutes / 60,
      activeCalories: activeCalories == 0 ? null : activeCalories,
      basalCalories: basalCalories == 0 ? null : basalCalories,
      totalCalories: totalCalories == 0 ? null : totalCalories,
      steps: steps == 0 ? null : steps,
      distanceMeters: distanceMeters == 0 ? null : distanceMeters,
      flightsClimbed: flightsClimbed == 0 ? null : flightsClimbed,
      runningPowerWatts:
          _runningPowerCount == 0 ? null : _runningPowerSum / _runningPowerCount,
      cadenceSpm: _cadenceCount == 0 ? null : _cadenceSum / _cadenceCount,
      strideLengthMeters: _strideLengthCount == 0
          ? null
          : _strideLengthSum / _strideLengthCount,
      exerciseMinutes: exerciseMinutes == 0 ? null : exerciseMinutes,
    );
  }
}
