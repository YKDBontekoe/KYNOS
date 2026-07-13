// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_visual_artifact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthArtifactMeta _$HealthArtifactMetaFromJson(Map<String, dynamic> json) =>
    _HealthArtifactMeta(
      id: json['id'] as String,
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      title: json['title'] as String,
      explanation: json['explanation'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      confidence: $enumDecode(_$FindingConfidenceEnumMap, json['confidence']),
      evidenceReferences:
          (json['evidenceReferences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      limitations:
          (json['limitations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      isInteractive: json['isInteractive'] as bool? ?? true,
    );

Map<String, dynamic> _$HealthArtifactMetaToJson(_HealthArtifactMeta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schemaVersion': instance.schemaVersion,
      'title': instance.title,
      'explanation': instance.explanation,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'confidence': _$FindingConfidenceEnumMap[instance.confidence]!,
      'evidenceReferences': instance.evidenceReferences,
      'limitations': instance.limitations,
      'isInteractive': instance.isInteractive,
    };

const _$FindingConfidenceEnumMap = {
  FindingConfidence.low: 'low',
  FindingConfidence.moderate: 'moderate',
  FindingConfidence.high: 'high',
};

_HealthDataPoint _$HealthDataPointFromJson(Map<String, dynamic> json) =>
    _HealthDataPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String?,
    );

Map<String, dynamic> _$HealthDataPointToJson(_HealthDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'label': instance.label,
    };

_HealthSeries _$HealthSeriesFromJson(Map<String, dynamic> json) =>
    _HealthSeries(
      id: json['id'] as String,
      label: json['label'] as String,
      metric: $enumDecode(_$HealthMetricEnumMap, json['metric']),
      unit: json['unit'] as String,
      points: (json['points'] as List<dynamic>)
          .map((e) => HealthDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      baseline: (json['baseline'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HealthSeriesToJson(_HealthSeries instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'metric': _$HealthMetricEnumMap[instance.metric]!,
      'unit': instance.unit,
      'points': instance.points,
      'baseline': instance.baseline,
    };

const _$HealthMetricEnumMap = {
  HealthMetric.hrv: 'hrv',
  HealthMetric.restingHeartRate: 'restingHeartRate',
  HealthMetric.averageHeartRate: 'averageHeartRate',
  HealthMetric.respiratoryRate: 'respiratoryRate',
  HealthMetric.bloodOxygen: 'bloodOxygen',
  HealthMetric.sleep: 'sleep',
  HealthMetric.steps: 'steps',
  HealthMetric.distance: 'distance',
  HealthMetric.exerciseTime: 'exerciseTime',
  HealthMetric.activeEnergy: 'activeEnergy',
  HealthMetric.totalEnergy: 'totalEnergy',
  HealthMetric.selfReportedEnergy: 'selfReportedEnergy',
  HealthMetric.selfReportedMood: 'selfReportedMood',
  HealthMetric.selfReportedStress: 'selfReportedStress',
};

_HealthTableRow _$HealthTableRowFromJson(Map<String, dynamic> json) =>
    _HealthTableRow(
      label: json['label'] as String,
      values: (json['values'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$HealthTableRowToJson(_HealthTableRow instance) =>
    <String, dynamic>{'label': instance.label, 'values': instance.values};

_HealthScatterPoint _$HealthScatterPointFromJson(Map<String, dynamic> json) =>
    _HealthScatterPoint(
      date: DateTime.parse(json['date'] as String),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$HealthScatterPointToJson(_HealthScatterPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'x': instance.x,
      'y': instance.y,
    };

_HealthTimelineEvent _$HealthTimelineEventFromJson(Map<String, dynamic> json) =>
    _HealthTimelineEvent(
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      detail: json['detail'] as String,
    );

Map<String, dynamic> _$HealthTimelineEventToJson(
  _HealthTimelineEvent instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'title': instance.title,
  'detail': instance.detail,
};

_InfluenceEdge _$InfluenceEdgeFromJson(Map<String, dynamic> json) =>
    _InfluenceEdge(
      from: json['from'] as String,
      to: json['to'] as String,
      label: json['label'] as String,
      strength: (json['strength'] as num).toDouble(),
    );

Map<String, dynamic> _$InfluenceEdgeToJson(_InfluenceEdge instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'label': instance.label,
      'strength': instance.strength,
    };

HealthTrendArtifact _$HealthTrendArtifactFromJson(Map<String, dynamic> json) =>
    HealthTrendArtifact(
      meta: HealthArtifactMeta.fromJson(json['meta'] as Map<String, dynamic>),
      series: (json['series'] as List<dynamic>)
          .map((e) => HealthSeries.fromJson(e as Map<String, dynamic>))
          .toList(),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$HealthTrendArtifactToJson(
  HealthTrendArtifact instance,
) => <String, dynamic>{
  'meta': instance.meta,
  'series': instance.series,
  'type': instance.$type,
};

HealthComparisonTableArtifact _$HealthComparisonTableArtifactFromJson(
  Map<String, dynamic> json,
) => HealthComparisonTableArtifact(
  meta: HealthArtifactMeta.fromJson(json['meta'] as Map<String, dynamic>),
  columns: (json['columns'] as List<dynamic>).map((e) => e as String).toList(),
  rows: (json['rows'] as List<dynamic>)
      .map((e) => HealthTableRow.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$HealthComparisonTableArtifactToJson(
  HealthComparisonTableArtifact instance,
) => <String, dynamic>{
  'meta': instance.meta,
  'columns': instance.columns,
  'rows': instance.rows,
  'type': instance.$type,
};

HealthCorrelationScatterArtifact _$HealthCorrelationScatterArtifactFromJson(
  Map<String, dynamic> json,
) => HealthCorrelationScatterArtifact(
  meta: HealthArtifactMeta.fromJson(json['meta'] as Map<String, dynamic>),
  xMetric: $enumDecode(_$HealthMetricEnumMap, json['xMetric']),
  yMetric: $enumDecode(_$HealthMetricEnumMap, json['yMetric']),
  points: (json['points'] as List<dynamic>)
      .map((e) => HealthScatterPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  correlation: (json['correlation'] as num).toDouble(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$HealthCorrelationScatterArtifactToJson(
  HealthCorrelationScatterArtifact instance,
) => <String, dynamic>{
  'meta': instance.meta,
  'xMetric': _$HealthMetricEnumMap[instance.xMetric]!,
  'yMetric': _$HealthMetricEnumMap[instance.yMetric]!,
  'points': instance.points,
  'correlation': instance.correlation,
  'type': instance.$type,
};

HealthCalendarHeatmapArtifact _$HealthCalendarHeatmapArtifactFromJson(
  Map<String, dynamic> json,
) => HealthCalendarHeatmapArtifact(
  meta: HealthArtifactMeta.fromJson(json['meta'] as Map<String, dynamic>),
  metric: $enumDecode(_$HealthMetricEnumMap, json['metric']),
  points: (json['points'] as List<dynamic>)
      .map((e) => HealthDataPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$HealthCalendarHeatmapArtifactToJson(
  HealthCalendarHeatmapArtifact instance,
) => <String, dynamic>{
  'meta': instance.meta,
  'metric': _$HealthMetricEnumMap[instance.metric]!,
  'points': instance.points,
  'type': instance.$type,
};

HealthTimelineArtifact _$HealthTimelineArtifactFromJson(
  Map<String, dynamic> json,
) => HealthTimelineArtifact(
  meta: HealthArtifactMeta.fromJson(json['meta'] as Map<String, dynamic>),
  events: (json['events'] as List<dynamic>)
      .map((e) => HealthTimelineEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$HealthTimelineArtifactToJson(
  HealthTimelineArtifact instance,
) => <String, dynamic>{
  'meta': instance.meta,
  'events': instance.events,
  'type': instance.$type,
};

HealthInfluenceMapArtifact _$HealthInfluenceMapArtifactFromJson(
  Map<String, dynamic> json,
) => HealthInfluenceMapArtifact(
  meta: HealthArtifactMeta.fromJson(json['meta'] as Map<String, dynamic>),
  nodes: (json['nodes'] as List<dynamic>).map((e) => e as String).toList(),
  edges: (json['edges'] as List<dynamic>)
      .map((e) => InfluenceEdge.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$HealthInfluenceMapArtifactToJson(
  HealthInfluenceMapArtifact instance,
) => <String, dynamic>{
  'meta': instance.meta,
  'nodes': instance.nodes,
  'edges': instance.edges,
  'type': instance.$type,
};
