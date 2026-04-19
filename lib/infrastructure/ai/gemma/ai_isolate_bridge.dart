import 'dart:isolate';

/// Message types exchanged between the Main Isolate and the AI Background Isolate.
sealed class IsolateMessage {}

final class InferenceRequest extends IsolateMessage {
  final String prompt;
  final int maxTokens;
  final SendPort responsePort;

  InferenceRequest({
    required this.prompt,
    required this.maxTokens,
    required this.responsePort,
  });
}

final class InferenceChunk extends IsolateMessage {
  final String token;

  InferenceChunk(this.token) : super();
}

final class InferenceDone extends IsolateMessage {
  InferenceDone() : super();
}

final class InferenceError extends IsolateMessage {
  final String message;

  InferenceError(this.message) : super();
}

/// Entry point executed inside the Background Isolate.
///
/// Receives [InferenceRequest] messages and responds with [InferenceChunk]
/// tokens followed by [InferenceDone] or [InferenceError].
///
/// TODO(ai): Initialise the LiteRT-LM runtime here and load the Gemma model.
void aiIsolateEntryPoint(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is InferenceRequest) {
      // Stub: echo the prompt back one word at a time.
      const stub = 'AI Isolate running — LiteRT-LM not yet wired.';
      for (final word in stub.split(' ')) {
        message.responsePort.send(InferenceChunk('$word '));
      }
      message.responsePort.send(InferenceDone());
    }
  });
}
