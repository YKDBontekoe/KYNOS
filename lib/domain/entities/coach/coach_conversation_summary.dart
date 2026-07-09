import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';

/// Lightweight metadata for conversation list UI.
class CoachConversationSummary {
  const CoachConversationSummary({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.lastMessagePreview,
    this.seedTopic = CoachSeedTopic.general,
    this.isPinned = false,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final String? lastMessagePreview;
  final CoachSeedTopic seedTopic;
  final bool isPinned;
  final bool isArchived;

  CoachConversationSummary copyWith({
    String? title,
    DateTime? updatedAt,
    int? messageCount,
    String? lastMessagePreview,
    CoachSeedTopic? seedTopic,
    bool? isPinned,
    bool? isArchived,
  }) {
    return CoachConversationSummary(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      seedTopic: seedTopic ?? this.seedTopic,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
