import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';

/// Per-thread inference and context preferences.
class CoachConversationSettings {
  CoachConversationSettings({
    this.backendMode = CoachBackendMode.auto,
    this.preferredLocalModelId,
    this.preferredCloudModelId,
    CoachContextPreferences? contextPreferences,
  }) : contextPreferences = contextPreferences ?? CoachContextPreferences.defaults;

  final CoachBackendMode backendMode;
  final String? preferredLocalModelId;
  final String? preferredCloudModelId;
  final CoachContextPreferences contextPreferences;

  static final defaults = CoachConversationSettings();

  CoachConversationSettings copyWith({
    CoachBackendMode? backendMode,
    String? preferredLocalModelId,
    String? preferredCloudModelId,
    CoachContextPreferences? contextPreferences,
    bool clearPreferredLocalModelId = false,
    bool clearPreferredCloudModelId = false,
  }) {
    return CoachConversationSettings(
      backendMode: backendMode ?? this.backendMode,
      preferredLocalModelId: clearPreferredLocalModelId
          ? null
          : (preferredLocalModelId ?? this.preferredLocalModelId),
      preferredCloudModelId: clearPreferredCloudModelId
          ? null
          : (preferredCloudModelId ?? this.preferredCloudModelId),
      contextPreferences: contextPreferences ?? this.contextPreferences,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachConversationSettings &&
          runtimeType == other.runtimeType &&
          backendMode == other.backendMode &&
          preferredLocalModelId == other.preferredLocalModelId &&
          preferredCloudModelId == other.preferredCloudModelId &&
          contextPreferences == other.contextPreferences;

  @override
  int get hashCode => Object.hash(
        backendMode,
        preferredLocalModelId,
        preferredCloudModelId,
        contextPreferences,
      );
}
