import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/infrastructure/ai/ai_infrastructure_providers.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_chat_provider.g.dart';

@Riverpod(keepAlive: true)
class CoachChatNotifier extends _$CoachChatNotifier {
  final _logger = Logger();

  @override
  Future<List<ChatMessage>> build() async {
    ref.onDispose(() async {
      await ref.read(aiCoachRepositoryProvider).dispose();
    });
    return const [];
  }

  Future<void> sendMessage(String userMessage) async {
    final current = state.value ?? const [];

    final userMsg = ChatMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}_user',
      role: MessageRole.user,
      content: userMessage,
      timestamp: DateTime.now(),
    );
    state = AsyncData([...current, userMsg]);

    final assistantId = '${DateTime.now().microsecondsSinceEpoch}_assistant';
    final placeholder = ChatMessage(
      id: assistantId,
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    state = AsyncData([...state.value!, placeholder]);

    try {
      final AiCoachRepository repository = ref.read(aiCoachRepositoryProvider);
      await for (final chunk in repository.chat(userMessage: userMessage)) {
        final msgs = state.value!;
        final idx = msgs.indexWhere((m) => m.id == assistantId);
        if (idx == -1) break;

        final updated = msgs[idx].copyWith(
          content: msgs[idx].content + chunk,
        );
        state = AsyncData(List<ChatMessage>.from(msgs)..[idx] = updated);
      }
      _finaliseMessage(assistantId, streaming: false);
    } catch (e, st) {
      _logger.e('Inference error', error: e, stackTrace: st);
      _finaliseMessage(assistantId, streaming: false, content: 'Error: $e');
    }
  }

  Future<void> clearConversation() async {
    state = const AsyncData([]);
    await ref.read(aiCoachRepositoryProvider).resetSession();
  }

  void _finaliseMessage(String id, {required bool streaming, String? content}) {
    final msgs = state.value;
    if (msgs == null) return;

    final idx = msgs.indexWhere((m) => m.id == id);
    if (idx == -1) return;

    final updated = msgs[idx].copyWith(
      isStreaming: streaming,
      content: content ?? msgs[idx].content,
    );
    state = AsyncData(List<ChatMessage>.from(msgs)..[idx] = updated);
  }
}
