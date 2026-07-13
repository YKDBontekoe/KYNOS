import 'dart:convert';

import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';
import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:kynos/domain/entities/coach/coach_context_preferences.dart';
import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_summary.dart';
import 'package:kynos/domain/entities/coach/coach_data_source.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/domain/entities/coach/coach_tool_call.dart';
import 'package:kynos/domain/entities/health/health_coach_models.dart';
import 'package:kynos/domain/entities/health/health_visual_artifact.dart';
import 'package:logger/logger.dart';

/// Serialises coach conversations to SharedPreferences JSON.
abstract final class CoachConversationCodec {
  static const indexKey = 'coach_conversations_index_v1';
  static const activeIdKey = 'coach_active_conversation_id_v1';
  static const legacyKey = 'coach_chat_history_v1';
  static const maxConversations = 50;
  static final _logger = Logger();

  static String threadKey(String id) => 'coach_thread_$id';

  static List<CoachConversationSummary> decodeIndex(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(_summaryFromMap)
          .toList();
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Could not decode conversation index',
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  static String encodeIndex(List<CoachConversationSummary> summaries) {
    return jsonEncode(summaries.map(_summaryToMap).toList());
  }

  static CoachConversation? decodeThread(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _conversationFromMap(map);
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Could not decode conversation thread',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static String encodeThread(CoachConversation conversation) {
    return jsonEncode(_conversationToMap(conversation));
  }

  static Map<String, dynamic> _summaryToMap(CoachConversationSummary summary) {
    return {
      'id': summary.id,
      'title': summary.title,
      'createdAt': summary.createdAt.toIso8601String(),
      'updatedAt': summary.updatedAt.toIso8601String(),
      'messageCount': summary.messageCount,
      'lastMessagePreview': summary.lastMessagePreview,
      'seedTopic': summary.seedTopic.name,
      'isPinned': summary.isPinned,
      'isArchived': summary.isArchived,
    };
  }

  static CoachConversationSummary _summaryFromMap(Map<String, dynamic> map) {
    return CoachConversationSummary(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      messageCount: map['messageCount'] as int? ?? 0,
      lastMessagePreview: map['lastMessagePreview'] as String?,
      seedTopic: CoachSeedTopic.values.byName(
        map['seedTopic'] as String? ?? CoachSeedTopic.general.name,
      ),
      isPinned: map['isPinned'] as bool? ?? false,
      isArchived: map['isArchived'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _conversationToMap(
    CoachConversation conversation,
  ) {
    return {
      'id': conversation.id,
      'title': conversation.title,
      'createdAt': conversation.createdAt.toIso8601String(),
      'updatedAt': conversation.updatedAt.toIso8601String(),
      'messages': conversation.messages
          .where((m) => m.content.isNotEmpty && !m.isStreaming)
          .map(_messageToMap)
          .toList(),
      'settings': _settingsToMap(conversation.settings),
      if (conversation.seed != null) 'seed': _seedToMap(conversation.seed!),
      'isPinned': conversation.isPinned,
      'isArchived': conversation.isArchived,
    };
  }

  static CoachConversation _conversationFromMap(Map<String, dynamic> map) {
    final messagesRaw = map['messages'] as List<dynamic>? ?? const [];
    final messages = messagesRaw
        .whereType<Map<String, dynamic>>()
        .map(_messageFromMap)
        .where((m) => m.content.isNotEmpty && !m.isStreaming)
        .toList();

    final seedRaw = map['seed'] as Map<String, dynamic>?;
    return CoachConversation(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      messages: messages,
      settings: _settingsFromMap(
        map['settings'] as Map<String, dynamic>? ?? const {},
      ),
      seed: seedRaw == null ? null : _seedFromMap(seedRaw),
      isPinned: map['isPinned'] as bool? ?? false,
      isArchived: map['isArchived'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _messageToMap(ChatMessage message) {
    return {
      'id': message.id,
      'role': message.role.name,
      'content': message.content,
      'timestamp': message.timestamp.toIso8601String(),
      'hasError': message.hasError,
      'userPromptForRetry': message.userPromptForRetry,
      if (message.attemptedBackend != null)
        'attemptedBackend': message.attemptedBackend!.name,
      if (message.contextSnapshotIds != null)
        'contextSnapshotIds': message.contextSnapshotIds,
      if (message.toolSteps != null && message.toolSteps!.isNotEmpty)
        'toolSteps': message.toolSteps!.map(_toolStepToMap).toList(),
      if (message.visualArtifacts != null &&
          message.visualArtifacts!.isNotEmpty)
        'visualArtifacts': message.visualArtifacts!
            .take(4)
            .map((artifact) => artifact.toJson())
            .toList(),
      if (message.findings != null && message.findings!.isNotEmpty)
        'findings': message.findings!
            .map((finding) => finding.toJson())
            .toList(),
      if (message.pendingActions != null && message.pendingActions!.isNotEmpty)
        'pendingActions': message.pendingActions!
            .map((action) => action.toJson())
            .toList(),
    };
  }

  static ChatMessage _messageFromMap(Map<String, dynamic> map) {
    final backendName = map['attemptedBackend'] as String?;
    final snapshotRaw = map['contextSnapshotIds'] as List<dynamic>?;
    final toolStepsRaw = map['toolSteps'] as List<dynamic>?;
    final artifactsRaw = map['visualArtifacts'] as List<dynamic>?;
    final findingsRaw = map['findings'] as List<dynamic>?;
    final actionsRaw = map['pendingActions'] as List<dynamic>?;
    return ChatMessage(
      id: map['id'] as String,
      role: MessageRole.values.byName(map['role'] as String),
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      hasError: map['hasError'] as bool? ?? false,
      userPromptForRetry: map['userPromptForRetry'] as String?,
      attemptedBackend: backendName == null
          ? null
          : AiInferenceBackend.values.byName(backendName),
      contextSnapshotIds: snapshotRaw?.whereType<String>().toList(),
      toolSteps: toolStepsRaw
          ?.whereType<Map<String, dynamic>>()
          .map(_toolStepFromMap)
          .toList(),
      visualArtifacts: _decodeSafely(
        artifactsRaw,
        HealthVisualArtifact.fromJson,
      ),
      findings: _decodeSafely(findingsRaw, HealthFinding.fromJson),
      pendingActions: _decodeSafely(actionsRaw, PendingCoachAction.fromJson),
    );
  }

  static List<T>? _decodeSafely<T>(
    List<dynamic>? values,
    T Function(Map<String, Object?>) decode,
  ) {
    if (values == null) return null;
    final decoded = <T>[];
    for (final value in values) {
      if (value is! Map) continue;
      try {
        decoded.add(decode(value.cast<String, Object?>()));
      } on Object catch (error, stackTrace) {
        _logger.w(
          'Skipping malformed structured coach content',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return decoded.isEmpty ? null : decoded;
  }

  static Map<String, dynamic> _toolStepToMap(CoachToolStep step) {
    return {
      'toolName': step.toolName,
      'status': step.status.name,
      'displayLabel': step.displayLabel,
    };
  }

  static CoachToolStep _toolStepFromMap(Map<String, dynamic> map) {
    return CoachToolStep(
      toolName: map['toolName'] as String,
      status: _toolStatusFromString(map['status'] as String?),
      displayLabel: map['displayLabel'] as String?,
    );
  }

  static CoachToolStatus _toolStatusFromString(String? raw) {
    if (raw == null) return CoachToolStatus.success;
    for (final status in CoachToolStatus.values) {
      if (status.name == raw) return status;
    }
    return CoachToolStatus.success;
  }

  static Map<String, dynamic> _settingsToMap(
    CoachConversationSettings settings,
  ) {
    return {
      'backendMode': settings.backendMode.name,
      'preferredLocalModelId': settings.preferredLocalModelId,
      'preferredCloudModelId': settings.preferredCloudModelId,
      'contextPreferences': _contextPrefsToMap(settings.contextPreferences),
    };
  }

  static CoachConversationSettings _settingsFromMap(Map<String, dynamic> map) {
    final prefsRaw =
        map['contextPreferences'] as Map<String, dynamic>? ?? const {};
    return CoachConversationSettings(
      backendMode: CoachBackendMode.values.byName(
        map['backendMode'] as String? ?? CoachBackendMode.auto.name,
      ),
      preferredLocalModelId: map['preferredLocalModelId'] as String?,
      preferredCloudModelId: map['preferredCloudModelId'] as String?,
      contextPreferences: _contextPrefsFromMap(prefsRaw),
    );
  }

  static Map<String, dynamic> _contextPrefsToMap(
    CoachContextPreferences preferences,
  ) {
    return {
      'enabledSources': preferences.enabledSources.map((s) => s.name).toList(),
      'cloudLevelOverride': preferences.cloudLevelOverride?.name,
      'cloudConsentGiven': preferences.cloudConsentGiven,
    };
  }

  static CoachContextPreferences _contextPrefsFromMap(
    Map<String, dynamic> map,
  ) {
    final sourcesRaw = map['enabledSources'] as List<dynamic>? ?? const [];
    final levelName = map['cloudLevelOverride'] as String?;
    return CoachContextPreferences(
      enabledSources: sourcesRaw
          .whereType<String>()
          .map(CoachDataSource.values.byName)
          .toSet(),
      cloudLevelOverride: levelName == null
          ? null
          : CloudDataLevel.values.byName(levelName),
      cloudConsentGiven: map['cloudConsentGiven'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _seedToMap(CoachChatSeedData seed) {
    return {
      'message': seed.message,
      'topic': seed.topic.name,
      'runId': seed.runId,
      'questId': seed.questId,
    };
  }

  static CoachChatSeedData _seedFromMap(Map<String, dynamic> map) {
    return CoachChatSeedData(
      message: map['message'] as String?,
      topic: CoachSeedTopic.values.byName(
        map['topic'] as String? ?? CoachSeedTopic.general.name,
      ),
      runId: map['runId'] as String?,
      questId: map['questId'] as String?,
    );
  }

  static List<ChatMessage> decodeLegacyMessages(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(_messageFromMap)
          .where((m) => m.content.isNotEmpty && !m.isStreaming)
          .toList();
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Could not decode legacy chat history',
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  static CoachConversationSummary summaryFromConversation(
    CoachConversation conversation,
  ) {
    return CoachConversationSummary(
      id: conversation.id,
      title: conversation.title,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      messageCount: conversation.messages
          .where((m) => m.content.isNotEmpty && !m.isStreaming)
          .length,
      lastMessagePreview: conversation.lastMessagePreview,
      seedTopic: conversation.seed?.topic ?? CoachSeedTopic.general,
      isPinned: conversation.isPinned,
      isArchived: conversation.isArchived,
    );
  }
}
