import 'package:kynos/domain/repositories/coach_conversation_repository.dart';

class MigrateLegacyCoachChatUseCase {
  const MigrateLegacyCoachChatUseCase({
    required CoachConversationRepository repository,
  }) : _repository = repository;

  final CoachConversationRepository _repository;

  Future<({bool migrated, String? conversationId, String? failureMessage})>
      call() async {
    final result = await _repository.migrateLegacyIfNeeded();
    if (result.failure != null) {
      return (
        migrated: false,
        conversationId: null,
        failureMessage: result.failure!.message,
      );
    }
    return (
      migrated: result.migrated,
      conversationId: result.conversationId,
      failureMessage: null,
    );
  }
}
