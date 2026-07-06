import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/domain/utils/gemma_inference_limits.dart';
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

      final prompt = _truncatePrompt(message.userMessage);

      try {
        await chat!.addQueryChunk(
          Message.text(text: prompt, isUser: true),
        );

        await for (final response in chat!.generateChatResponseAsync()) {
          if (response is TextResponse && response.token.isNotEmpty) {
            mainSendPort.send(
              AiIsolateChunk(response.token, requestId: message.requestId),
            );
          }
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

String _truncatePrompt(String prompt) {
  if (prompt.length <= GemmaInferenceLimits.maxPromptCharacters) {
    return prompt;
  }
  return prompt.substring(0, GemmaInferenceLimits.maxPromptCharacters);
}
