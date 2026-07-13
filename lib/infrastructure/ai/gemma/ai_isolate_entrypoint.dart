import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/domain/utils/coach_prompt_truncator.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_isolate_messages.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_inference_session.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime_tier.dart';

Future<void> aiIsolateEntrypoint(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  InferenceModel? model;
  InferenceChat? chat;
  GemmaInferenceTier tier = GemmaInferenceTier.constrained;
  AiPreferredBackend activeBackend = AiPreferredBackend.cpu;
  bool messengerInitialized = false;

  Future<void> ensureSession({AiPreferredBackend? backendOverride}) async {
    tier = await GemmaRuntimeTier.resolve();
    activeBackend = backendOverride ?? preferredBackendFromTier(tier);
    final session = await loadGemmaCoachSession(
      tier: tier,
      backend: activeBackend,
      existingModel: model,
    );
    model = session.model;
    chat = session.chat;
  }

  await for (final message in receivePort) {
    if (message is AiInitRequest) {
      try {
        if (!messengerInitialized) {
          BackgroundIsolateBinaryMessenger.ensureInitialized(message.rootToken);
          messengerInitialized = true;
        }

        await GemmaRuntime.initialize(
          huggingFaceToken: message.huggingFaceToken,
        );

        await GemmaRuntime.evictLegacyModelsIfNeeded();

        if (!GemmaRuntime.hasCompatibleActiveModel()) {
          mainSendPort.send(
            AiIsolateError(
              'No active Gemma model is installed. Complete model setup before starting chat.',
              requestId: 0,
            ),
          );
          continue;
        }

        await ensureSession();
        mainSendPort.send(AiIsolateReady());
      } catch (e) {
        mainSendPort.send(AiIsolateError(e.toString(), requestId: 0));
      }
      continue;
    }

    if (message is AiReloadChatRequest) {
      try {
        if (model == null) {
          await ensureSession();
        } else {
          await chat?.clearHistory();
          chat = await recreateCoachChat(model: model!, tier: tier);
        }
        mainSendPort.send(AiIsolateDone(requestId: message.requestId));
      } catch (e) {
        mainSendPort.send(
          AiIsolateError(e.toString(), requestId: message.requestId),
        );
      }
      continue;
    }

    if (message is AiReloadModelRequest) {
      try {
        activeBackend = message.backend;
        await ensureSession(backendOverride: message.backend);
        mainSendPort.send(AiIsolateDone(requestId: message.requestId));
      } catch (e) {
        mainSendPort.send(
          AiIsolateError(e.toString(), requestId: message.requestId),
        );
      }
      continue;
    }

    if (message is AiChatRequest) {
      if (chat == null || model == null) {
        mainSendPort.send(
          AiIsolateError('Chat not initialized', requestId: message.requestId),
        );
        continue;
      }

      final prompt = message.userMessage;

      try {
        await chat!.addQueryChunk(
          Message.text(text: prompt, isUser: true),
        );

        final responseText = await _streamChatResponse(
          chat: chat!,
          requestId: message.requestId,
          mainSendPort: mainSendPort,
        );

        if (coachResponseLooksTruncated(
          responseText,
          maxOutputTokens: message.maxOutputTokens,
        )) {
          await chat!.addQueryChunk(
            Message.text(
              text:
                  'Continue your previous answer from where you stopped. '
                  'Finish the thought in one or two short sentences.',
              isUser: true,
            ),
          );
          await _streamChatResponse(
            chat: chat!,
            requestId: message.requestId,
            mainSendPort: mainSendPort,
          );
        }

        mainSendPort.send(AiIsolateDone(requestId: message.requestId));
      } catch (e) {
        mainSendPort.send(
          AiIsolateError(e.toString(), requestId: message.requestId),
        );
      }
      continue;
    }

    if (message is AiResetSessionRequest) {
      try {
        await chat?.clearHistory();
        mainSendPort.send(AiIsolateDone(requestId: message.requestId));
      } catch (e) {
        mainSendPort.send(
          AiIsolateError(e.toString(), requestId: message.requestId),
        );
      }
      continue;
    }

    if (message is AiDisposeRequest) {
      try {
        await model?.close();
        model = null;
        chat = null;
        mainSendPort.send(AiIsolateDone());
      } catch (e) {
        mainSendPort.send(AiIsolateError(e.toString(), requestId: 0));
      }
      break;
    }
  }
}

Future<String> _streamChatResponse({
  required InferenceChat chat,
  required int requestId,
  required SendPort mainSendPort,
}) async {
  final buffer = StringBuffer();
  await for (final response in chat.generateChatResponseAsync()) {
    if (response is TextResponse && response.token.isNotEmpty) {
      buffer.write(response.token);
      mainSendPort.send(
        AiIsolateChunk(response.token, requestId: requestId),
      );
    }
  }
  return buffer.toString();
}
