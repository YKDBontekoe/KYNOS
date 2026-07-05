import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/utils/gemma_device_capability.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_isolate_messages.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime_tier.dart';

const _systemInstruction =
    'You are KYNOS Coach — an expert on-device running coach. '
    'Give concise, biomechanics-aware advice. '
    'Never reveal you are an AI model or reference any training data.';

const _maxCoachReplyTokens = 256;

Future<void> aiIsolateEntrypoint(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  InferenceModel? model;
  InferenceChat? chat;
  bool messengerInitialized = false;

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

        if (!FlutterGemma.hasActiveModel()) {
          mainSendPort.send(
            AiIsolateError(
              'No active Gemma model is installed. Complete model setup before starting chat.',
            ),
          );
          continue;
        }

        final tier = await GemmaRuntimeTier.resolve();
        final backend = tier == GemmaInferenceTier.full
            ? PreferredBackend.gpu
            : PreferredBackend.cpu;

        model ??= await FlutterGemma.getActiveModel(
          maxTokens: AppConstants.modelContextWindow,
          preferredBackend: backend,
        );

        chat = await model.createChat(
          systemInstruction: _systemInstruction,
          maxOutputTokens: _maxCoachReplyTokens,
        );

        mainSendPort.send(AiIsolateReady());
      } catch (e) {
        mainSendPort.send(AiIsolateError(e.toString()));
      }
      continue;
    }

    if (message is AiChatRequest) {
      if (chat == null || model == null) {
        mainSendPort.send(AiIsolateError('Chat not initialized'));
        continue;
      }

      try {
        await chat.addQueryChunk(
          Message.text(text: message.userMessage, isUser: true),
        );

        await for (final response in chat.generateChatResponseAsync()) {
          if (response is TextResponse && response.token.isNotEmpty) {
            mainSendPort.send(AiIsolateChunk(response.token));
          }
        }

        mainSendPort.send(AiIsolateDone());
      } catch (e) {
        mainSendPort.send(AiIsolateError(e.toString()));
      }
      continue;
    }

    if (message is AiResetSessionRequest) {
      try {
        await chat?.clearHistory();
        mainSendPort.send(AiIsolateDone());
      } catch (e) {
        mainSendPort.send(AiIsolateError(e.toString()));
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
        mainSendPort.send(AiIsolateError(e.toString()));
      }
      break;
    }
  }
}
