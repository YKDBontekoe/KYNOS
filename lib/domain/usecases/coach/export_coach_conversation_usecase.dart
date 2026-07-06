import 'package:kynos/domain/entities/chat_message.dart';
import 'package:kynos/domain/entities/coach/coach_conversation.dart';

class ExportCoachConversationUseCase {
  const ExportCoachConversationUseCase();

  String call(CoachConversation conversation, {bool includeHealthAudit = false}) {
    final buffer = StringBuffer()
      ..writeln('# ${conversation.title}')
      ..writeln()
      ..writeln('_Exported ${DateTime.now().toIso8601String()}_')
      ..writeln();

    for (final message in conversation.messages) {
      if (message.isStreaming || message.content.trim().isEmpty) continue;
      final role = message.role == MessageRole.user ? 'You' : 'Coach';
      buffer
        ..writeln('## $role')
        ..writeln(message.content.trim())
        ..writeln();
      if (includeHealthAudit &&
          message.contextSnapshotIds != null &&
          message.contextSnapshotIds!.isNotEmpty) {
        buffer.writeln(
          '_Context: ${message.contextSnapshotIds!.join(', ')}_',
        );
        buffer.writeln();
      }
    }

    return buffer.toString().trim();
  }
}
