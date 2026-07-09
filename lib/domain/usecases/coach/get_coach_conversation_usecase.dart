import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/domain/repositories/coach_conversation_repository.dart';

class GetCoachConversationUseCase {
  const GetCoachConversationUseCase({
    required CoachConversationRepository repository,
  }) : _repository = repository;

  final CoachConversationRepository _repository;

  Future<({CoachConversation? conversation, String? failureMessage})> call(
    String id,
  ) async {
    final result = await _repository.getById(id);
    if (result.failure != null) {
      return (conversation: null, failureMessage: result.failure!.message);
    }
    return (conversation: result.conversation, failureMessage: null);
  }
}
