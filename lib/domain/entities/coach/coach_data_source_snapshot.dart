import 'package:kynos/domain/entities/coach/coach_data_source.dart';

/// UI-facing description of one coach data source.
class CoachDataSourceSnapshot {
  const CoachDataSourceSnapshot({
    required this.source,
    required this.label,
    required this.preview,
    required this.isEnabled,
    required this.willSendToCloud,
  });

  final CoachDataSource source;
  final String label;
  final String preview;
  final bool isEnabled;
  final bool willSendToCloud;
}
