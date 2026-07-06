import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';

/// Structured handoff when opening coach chat from another feature.
class CoachChatSeedData {
  const CoachChatSeedData({
    this.message,
    this.topic = CoachSeedTopic.general,
    this.runId,
    this.questId,
  });

  final String? message;
  final CoachSeedTopic topic;
  final String? runId;
  final String? questId;

  bool get isEmpty =>
      (message == null || message!.trim().isEmpty) &&
      topic == CoachSeedTopic.general &&
      runId == null &&
      questId == null;

  CoachChatSeedData copyWith({
    String? message,
    CoachSeedTopic? topic,
    String? runId,
    String? questId,
  }) {
    return CoachChatSeedData(
      message: message ?? this.message,
      topic: topic ?? this.topic,
      runId: runId ?? this.runId,
      questId: questId ?? this.questId,
    );
  }
}
