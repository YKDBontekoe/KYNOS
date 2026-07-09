import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_summary.dart';

/// Persists coach chat threads locally.
abstract interface class CoachConversationRepository {
  Future<({List<CoachConversationSummary> summaries, Failure? failure})>
      listSummaries();

  Future<({CoachConversation? conversation, Failure? failure})> getById(
    String id,
  );

  Future<({CoachConversation? conversation, Failure? failure})> create(
    CoachConversation conversation,
  );

  Future<({CoachConversation? conversation, Failure? failure})> update(
    CoachConversation conversation,
  );

  Future<({bool success, Failure? failure})> delete(String id);

  Future<({bool migrated, String? conversationId, Failure? failure})>
      migrateLegacyIfNeeded();

  Future<({String? activeId, Failure? failure})> readActiveConversationId();

  Future<({bool success, Failure? failure})> writeActiveConversationId(
    String? id,
  );
}
