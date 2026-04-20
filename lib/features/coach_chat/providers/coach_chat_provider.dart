import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/dashboard/providers/health_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coach_chat_provider.g.dart';

@Riverpod(keepAlive: true)
class CoachChatNotifier extends _$CoachChatNotifier {
  final _logger = Logger();
  
  InferenceModel? _model;
  InferenceChat? _chat;

  @override
  Future<List<ChatMessage>> build() async {
    ref.onDispose(() {
      _model?.close();
    });
    return const [];
  }

  Future<void> _ensureReady() async {
    if (_chat != null) return;

    // Direct package implementation as per documentation
    await FlutterGemma.initialize();
    
    _model ??= await FlutterGemma.getActiveModel(
      maxTokens: 512,
      preferredBackend: PreferredBackend.gpu,
    );

    _chat = await _model!.createChat();
  }

  Future<void> sendMessage(String userMessage) async {
    final current = state.valueOrNull ?? const [];

    // Append user message
    final userMsg = ChatMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}_user',
      role: MessageRole.user,
      content: userMessage,
      timestamp: DateTime.now(),
    );
    state = AsyncData([...current, userMsg]);

    // Assistant placeholder
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
      await _ensureReady();

      // Simple system prompt prepended for 0.12.x
      final fullPrompt = 'You are KYNOS coach.\n\n$userMessage';
      
      await _chat!.addQueryChunk(Message.text(text: fullPrompt, isUser: true));

      await for (final response in _chat!.generateChatResponseAsync()) {
        if (response is TextResponse) {
          final msgs = state.value!;
          final idx = msgs.indexWhere((m) => m.id == assistantId);
          if (idx == -1) break;

          final updated = msgs[idx].copyWith(
            content: msgs[idx].content + response.token,
          );
          state = AsyncData(List<ChatMessage>.from(msgs)..[idx] = updated);
        }
      }

      _finaliseMessage(assistantId, streaming: false);
    } catch (e, st) {
      _logger.e('Inference error', error: e, stackTrace: st);
      _finaliseMessage(assistantId, streaming: false, content: 'Error: $e');
    }
  }

  Future<void> clearConversation() async {
    state = const AsyncData([]);
    await _chat?.clearHistory();
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
