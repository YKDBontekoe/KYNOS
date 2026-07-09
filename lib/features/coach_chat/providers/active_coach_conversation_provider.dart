import 'package:kynos/domain/entities/coach/coach_conversation.dart';
import 'package:kynos/features/coach_chat/providers/coach_conversations_provider.dart';
import 'package:kynos/shared/providers/coach_conversation_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_coach_conversation_provider.g.dart';

@Riverpod(keepAlive: true)
class ActiveCoachConversation extends _$ActiveCoachConversation {
  @override
  Future<CoachConversation?> build() async {
    final activeId = ref.watch(activeCoachConversationIdProvider);
    if (activeId == null) return null;
    final result =
        await ref.read(getCoachConversationUseCaseProvider).call(activeId);
    return result.conversation;
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}
