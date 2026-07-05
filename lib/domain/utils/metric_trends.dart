/// Direction of a metric change relative to a baseline.
enum TrendDirection { up, down, neutral }

/// Delta between a current value and a comparison baseline.
class MetricDelta {
  const MetricDelta({
    required this.delta,
    required this.pct,
    required this.direction,
    required this.improved,
  });

  final double delta;
  final double? pct;
  final TrendDirection direction;
  final bool improved;
}

/// Computes delta between [today] and [baseline].
MetricDelta? computeMetricDelta({
  required double? today,
  required double? baseline,
  required bool higherIsBetter,
}) {
  if (today == null || baseline == null) return null;
  final delta = today - baseline;
  if (delta.abs() < 0.001) {
    return const MetricDelta(
      delta: 0,
      pct: 0,
      direction: TrendDirection.neutral,
      improved: true,
    );
  }

  final improved = higherIsBetter ? delta > 0 : delta < 0;
  final direction = delta > 0
      ? TrendDirection.up
      : delta < 0
      ? TrendDirection.down
      : TrendDirection.neutral;
  final pct = baseline.abs() > 0.001 ? (delta / baseline) * 100 : null;

  return MetricDelta(
    delta: delta,
    pct: pct,
    direction: direction,
    improved: improved,
  );
}

/// Rolling average of non-null [values].
double? rollingAverage(Iterable<double?> values) {
  final present = values.whereType<double>().toList();
  if (present.isEmpty) return null;
  return present.reduce((a, b) => a + b) / present.length;
}

/// Formats a compact sublabel for metric tiles, e.g. "↑ 4 ms vs yesterday".
String? formatMetricDeltaSublabel({
  required MetricDelta? vsYesterday,
  required MetricDelta? vs7DayAvg,
  required String unit,
  int digits = 0,
}) {
  if (vsYesterday != null && vsYesterday.delta.abs() >= 0.001) {
    final sign = vsYesterday.delta > 0 ? '+' : '';
    final value = digits == 0
        ? vsYesterday.delta.round().toString()
        : vsYesterday.delta.toStringAsFixed(digits);
    return '$sign$value $unit vs yesterday';
  }

  if (vs7DayAvg != null &&
      vs7DayAvg.pct != null &&
      vs7DayAvg.pct!.abs() >= 0.5) {
    final sign = vs7DayAvg.pct! > 0 ? '+' : '';
    return '$sign${vs7DayAvg.pct!.round()}% vs 7-day avg';
  }

  return null;
}

/// Whether the delta should render in a positive (green) colour.
bool isDeltaPositive(MetricDelta? delta) => delta?.improved ?? false;
