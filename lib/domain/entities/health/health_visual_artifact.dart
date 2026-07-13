import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_metric.dart';

part 'health_visual_artifact.freezed.dart';
part 'health_visual_artifact.g.dart';

@freezed
abstract class HealthArtifactMeta with _$HealthArtifactMeta {
  const factory HealthArtifactMeta({
    required String id,
    @Default(1) int schemaVersion,
    required String title,
    required String explanation,
    required DateTime start,
    required DateTime end,
    required FindingConfidence confidence,
    @Default(<String>[]) List<String> evidenceReferences,
    @Default(<String>[]) List<String> limitations,
    @Default(true) bool isInteractive,
  }) = _HealthArtifactMeta;

  factory HealthArtifactMeta.fromJson(Map<String, Object?> json) =>
      _$HealthArtifactMetaFromJson(json);
}

@freezed
abstract class HealthDataPoint with _$HealthDataPoint {
  const factory HealthDataPoint({
    required DateTime date,
    required double value,
    String? label,
  }) = _HealthDataPoint;

  factory HealthDataPoint.fromJson(Map<String, Object?> json) =>
      _$HealthDataPointFromJson(json);
}

@freezed
abstract class HealthSeries with _$HealthSeries {
  const factory HealthSeries({
    required String id,
    required String label,
    required HealthMetric metric,
    required String unit,
    required List<HealthDataPoint> points,
    double? baseline,
  }) = _HealthSeries;

  factory HealthSeries.fromJson(Map<String, Object?> json) =>
      _$HealthSeriesFromJson(json);
}

@freezed
abstract class HealthTableRow with _$HealthTableRow {
  const factory HealthTableRow({
    required String label,
    required List<String> values,
  }) = _HealthTableRow;

  factory HealthTableRow.fromJson(Map<String, Object?> json) =>
      _$HealthTableRowFromJson(json);
}

@freezed
abstract class HealthScatterPoint with _$HealthScatterPoint {
  const factory HealthScatterPoint({
    required DateTime date,
    required double x,
    required double y,
  }) = _HealthScatterPoint;

  factory HealthScatterPoint.fromJson(Map<String, Object?> json) =>
      _$HealthScatterPointFromJson(json);
}

@freezed
abstract class HealthTimelineEvent with _$HealthTimelineEvent {
  const factory HealthTimelineEvent({
    required DateTime date,
    required String title,
    required String detail,
  }) = _HealthTimelineEvent;

  factory HealthTimelineEvent.fromJson(Map<String, Object?> json) =>
      _$HealthTimelineEventFromJson(json);
}

@freezed
abstract class InfluenceEdge with _$InfluenceEdge {
  const factory InfluenceEdge({
    required String from,
    required String to,
    required String label,
    required double strength,
  }) = _InfluenceEdge;

  factory InfluenceEdge.fromJson(Map<String, Object?> json) =>
      _$InfluenceEdgeFromJson(json);
}

@Freezed(unionKey: 'type')
abstract class HealthVisualArtifact with _$HealthVisualArtifact {
  const factory HealthVisualArtifact.trend({
    required HealthArtifactMeta meta,
    required List<HealthSeries> series,
  }) = HealthTrendArtifact;

  const factory HealthVisualArtifact.comparisonTable({
    required HealthArtifactMeta meta,
    required List<String> columns,
    required List<HealthTableRow> rows,
  }) = HealthComparisonTableArtifact;

  const factory HealthVisualArtifact.correlationScatter({
    required HealthArtifactMeta meta,
    required HealthMetric xMetric,
    required HealthMetric yMetric,
    required List<HealthScatterPoint> points,
    required double correlation,
  }) = HealthCorrelationScatterArtifact;

  const factory HealthVisualArtifact.calendarHeatmap({
    required HealthArtifactMeta meta,
    required HealthMetric metric,
    required List<HealthDataPoint> points,
  }) = HealthCalendarHeatmapArtifact;

  const factory HealthVisualArtifact.healthTimeline({
    required HealthArtifactMeta meta,
    required List<HealthTimelineEvent> events,
  }) = HealthTimelineArtifact;

  const factory HealthVisualArtifact.influenceMap({
    required HealthArtifactMeta meta,
    required List<String> nodes,
    required List<InfluenceEdge> edges,
  }) = HealthInfluenceMapArtifact;

  factory HealthVisualArtifact.fromJson(Map<String, Object?> json) =>
      _$HealthVisualArtifactFromJson(json);
}
