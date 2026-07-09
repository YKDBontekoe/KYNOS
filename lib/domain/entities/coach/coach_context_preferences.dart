import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';

/// Per-conversation control over which data sources reach the coach prompt.
class CoachContextPreferences {
  CoachContextPreferences({
    Set<CoachDataSource>? enabledSources,
    this.cloudLevelOverride,
    this.cloudConsentGiven = false,
  }) : enabledSources = enabledSources ?? CoachDataSource.all;

  final Set<CoachDataSource> enabledSources;
  final CloudDataLevel? cloudLevelOverride;
  final bool cloudConsentGiven;

  static final defaults = CoachContextPreferences();

  bool isEnabled(CoachDataSource source) => enabledSources.contains(source);

  CoachContextPreferences copyWith({
    Set<CoachDataSource>? enabledSources,
    CloudDataLevel? cloudLevelOverride,
    bool? cloudConsentGiven,
    bool clearCloudLevelOverride = false,
  }) {
    return CoachContextPreferences(
      enabledSources: enabledSources ?? this.enabledSources,
      cloudLevelOverride: clearCloudLevelOverride
          ? null
          : (cloudLevelOverride ?? this.cloudLevelOverride),
      cloudConsentGiven: cloudConsentGiven ?? this.cloudConsentGiven,
    );
  }

  CoachContextPreferences toggleSource(CoachDataSource source, bool enabled) {
    final next = Set<CoachDataSource>.from(enabledSources);
    if (enabled) {
      next.add(source);
    } else {
      next.remove(source);
    }
    return copyWith(enabledSources: next);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachContextPreferences &&
          runtimeType == other.runtimeType &&
          _setEquals(enabledSources, other.enabledSources) &&
          cloudLevelOverride == other.cloudLevelOverride &&
          cloudConsentGiven == other.cloudConsentGiven;

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(enabledSources),
        cloudLevelOverride,
        cloudConsentGiven,
      );
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  return a.containsAll(b);
}
