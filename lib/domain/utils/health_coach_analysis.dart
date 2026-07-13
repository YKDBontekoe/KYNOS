import 'dart:math' as math;

import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_metric.dart';
import 'package:kynos/domain/entities/health_summary.dart';

abstract final class HealthCoachAnalysis {
  static const baselineDays = 28;
  static const stableBaselineObservations = 14;
  static const minimumTrendObservations = 7;
  static const minimumAssociationPairs = 10;

  static PersonalBaseline? baseline(
    List<HealthSummary> history,
    HealthMetric metric, {
    DateTime? asOf,
  }) {
    final end = _dateOnly(asOf ?? DateTime.now());
    final start = end.subtract(const Duration(days: baselineDays));
    final values = history
        .where(
          (item) =>
              _dateOnly(item.date).isBefore(end) &&
              !_dateOnly(item.date).isBefore(start),
        )
        .map(metric.valueFrom)
        .whereType<double>()
        .where((value) => value.isFinite)
        .toList();
    if (values.isEmpty) return null;
    final centre = median(values);
    final mad = median(values.map((value) => (value - centre).abs()).toList());
    return PersonalBaseline(
      metric: metric,
      observationCount: values.length,
      median: centre,
      medianAbsoluteDeviation: mad,
      start: start,
      end: end,
      quality: values.length >= stableBaselineObservations
          ? BaselineQuality.stable
          : BaselineQuality.learning,
    );
  }

  /// Modified z-score based on median absolute deviation.
  static double? robustDeviation(double value, PersonalBaseline baseline) {
    if (baseline.medianAbsoluteDeviation == 0) return null;
    return 0.6745 *
        (value - baseline.median) /
        baseline.medianAbsoluteDeviation;
  }

  static double median(List<double> values) {
    if (values.isEmpty) throw ArgumentError.value(values, 'values');
    final sorted = List<double>.from(values)..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }

  static double? spearman(List<({double x, double y})> pairs) {
    final valid = pairs
        .where((pair) => pair.x.isFinite && pair.y.isFinite)
        .toList();
    if (valid.length < minimumAssociationPairs) return null;
    final xRanks = _ranks(valid.map((pair) => pair.x).toList());
    final yRanks = _ranks(valid.map((pair) => pair.y).toList());
    final result = _pearson(xRanks, yRanks);
    if (result == null || result.abs() < 0.30) return null;
    return result.clamp(-1, 1);
  }

  static String associationStrength(double coefficient) {
    final absolute = coefficient.abs();
    if (absolute >= 0.70) return 'strong';
    if (absolute >= 0.50) return 'moderate';
    return 'weak';
  }

  static List<({DateTime date, double x, double y})> pairedValues(
    List<HealthSummary> history,
    HealthMetric xMetric,
    HealthMetric yMetric,
  ) {
    return history
        .map((item) {
          final x = xMetric.valueFrom(item);
          final y = yMetric.valueFrom(item);
          return x == null || y == null ? null : (date: item.date, x: x, y: y);
        })
        .whereType<({DateTime date, double x, double y})>()
        .toList();
  }

  static List<double> _ranks(List<double> values) {
    final indexed = List.generate(
      values.length,
      (index) => (index, values[index]),
    )..sort((a, b) => a.$2.compareTo(b.$2));
    final ranks = List<double>.filled(values.length, 0);
    var cursor = 0;
    while (cursor < indexed.length) {
      var end = cursor;
      while (end + 1 < indexed.length &&
          indexed[end + 1].$2 == indexed[cursor].$2) {
        end++;
      }
      final rank = (cursor + end) / 2 + 1;
      for (var i = cursor; i <= end; i++) {
        ranks[indexed[i].$1] = rank;
      }
      cursor = end + 1;
    }
    return ranks;
  }

  static double? _pearson(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) return null;
    final xMean = x.reduce((a, b) => a + b) / x.length;
    final yMean = y.reduce((a, b) => a + b) / y.length;
    var numerator = 0.0;
    var xSquares = 0.0;
    var ySquares = 0.0;
    for (var i = 0; i < x.length; i++) {
      final xDelta = x[i] - xMean;
      final yDelta = y[i] - yMean;
      numerator += xDelta * yDelta;
      xSquares += xDelta * xDelta;
      ySquares += yDelta * yDelta;
    }
    final denominator = math.sqrt(xSquares * ySquares);
    return denominator == 0 ? null : numerator / denominator;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
