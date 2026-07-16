import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';

/// Structured handoff when opening coach chat from another feature.
class CoachChatSeedData {
  const CoachChatSeedData({
    this.message,
    this.topic = CoachSeedTopic.general,
    this.runId,
  });

  final String? message;
  final CoachSeedTopic topic;
  final String? runId;

  bool get isEmpty =>
      (message == null || message!.trim().isEmpty) &&
      topic == CoachSeedTopic.general &&
      runId == null;

  CoachChatSeedData copyWith({
    String? message,
    CoachSeedTopic? topic,
    String? runId,
  }) {
    return CoachChatSeedData(
      message: message ?? this.message,
      topic: topic ?? this.topic,
      runId: runId ?? this.runId,
    );
  }
}
