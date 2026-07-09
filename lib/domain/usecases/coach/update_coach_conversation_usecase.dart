import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/domain/repositories/coach_conversation_repository.dart';

class UpdateCoachConversationUseCase {
  const UpdateCoachConversationUseCase({
    required CoachConversationRepository repository,
  }) : _repository = repository;

  final CoachConversationRepository _repository;

  static const maxTitleLength = 40;

  Future<({CoachConversation? conversation, String? failureMessage})> call(
    CoachConversation conversation,
  ) async {
    final result = await _repository.update(conversation);
    if (result.failure != null) {
      return (conversation: null, failureMessage: result.failure!.message);
    }
    return (conversation: result.conversation, failureMessage: null);
  }

  String titleFromFirstMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return 'New chat';
    if (trimmed.length <= maxTitleLength) return trimmed;
    return '${trimmed.substring(0, maxTitleLength).trim()}…';
  }
}
