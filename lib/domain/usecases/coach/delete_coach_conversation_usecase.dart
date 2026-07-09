import 'package:kynos/domain/repositories/coach_conversation_repository.dart';

class DeleteCoachConversationUseCase {
  const DeleteCoachConversationUseCase({
    required CoachConversationRepository repository,
  }) : _repository = repository;

  final CoachConversationRepository _repository;

  Future<({bool success, String? failureMessage})> call(String id) async {
    final result = await _repository.delete(id);
    if (result.failure != null) {
      return (success: false, failureMessage: result.failure!.message);
    }
    return (success: result.success, failureMessage: null);
  }
}
