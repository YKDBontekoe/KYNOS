import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/domain/repositories/coach_conversation_repository.dart';

class CreateCoachConversationUseCase {
  const CreateCoachConversationUseCase({
    required CoachConversationRepository repository,
  }) : _repository = repository;

  final CoachConversationRepository _repository;

  Future<({CoachConversation? conversation, String? failureMessage})> call({
    String title = 'New chat',
    CoachChatSeedData? seed,
    CoachConversationSettings? settings,
  }) async {
    final resolvedSettings = settings ?? CoachConversationSettings.defaults;
    final now = DateTime.now();
    final id = '${now.microsecondsSinceEpoch}';
    final conversation = CoachConversation(
      id: id,
      title: title,
      createdAt: now,
      updatedAt: now,
      seed: seed,
      settings: resolvedSettings,
    );
    final result = await _repository.create(conversation);
    if (result.failure != null) {
      return (conversation: null, failureMessage: result.failure!.message);
    }
    return (conversation: result.conversation, failureMessage: null);
  }
}
