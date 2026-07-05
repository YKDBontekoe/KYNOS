import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_isolate_messages.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_regression_math.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime.dart';

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

        // Each isolate must initialize flutter_gemma runtime separately.
        // Do not install here; setup flow already owns installation.
        await GemmaRuntime.initialize(
          huggingFaceToken: message.huggingFaceToken,
        );

        try {
          model ??= await FlutterGemma.getActiveModel(
            maxTokens: AppConstants.modelContextWindow,
            preferredBackend: PreferredBackend.cpu,
          );
        } on StateError catch (e) {
          final normalized = e.toString().toLowerCase();
          final missingActiveModel =
              normalized.contains('no active inference model set') ||
              (normalized.contains('no active') &&
                  normalized.contains('model'));
          if (!missingActiveModel) rethrow;

          // Active model selection is isolate-local in flutter_gemma.
          // Re-running installModel() restores active selection for this isolate.
          await GemmaRuntime.installGemma4E2B().fromNetwork(
            GemmaRuntime.modelDownloadUrl,
            token: message.huggingFaceToken != null &&
                    message.huggingFaceToken!.isNotEmpty
                ? message.huggingFaceToken
                : null,
          ).install();

          model = await FlutterGemma.getActiveModel(
            maxTokens: AppConstants.modelContextWindow,
            preferredBackend: PreferredBackend.cpu,
          );
        }

        chat = await model.createChat(
          systemInstruction:
              'You are KYNOS Coach — an expert on-device running coach. '
              'Give concise, biomechanics-aware advice.',
        );

        mainSendPort.send(AiIsolateReady());
      } catch (e) {
        final messageText = e.toString();
        final normalized = messageText.toLowerCase();
        if (normalized.contains('no active') &&
            normalized.contains('model')) {
          mainSendPort.send(
            AiIsolateError(
              'No active Gemma model is installed. Complete model setup before starting chat.',
            ),
          );
        } else {
          mainSendPort.send(AiIsolateError(messageText));
        }
      }
      continue;
    }

    if (message is AiChatRequest) {
      if (chat == null || model == null) {
        mainSendPort.send(AiIsolateError('Chat not initialized'));
        continue;
      }

      try {
        final session = model.session;
        if (session == null) {
          mainSendPort.send(AiIsolateError('Model session unavailable'));
          continue;
        }

        await session.addQueryChunk(
          Message.text(text: message.userMessage, isUser: true),
        );
        final fullResponse = await session.getResponse();

        final words = fullResponse.split(' ');
        for (var i = 0; i < words.length; i++) {
          final chunk = i == 0 ? words[i] : ' ${words[i]}';
          mainSendPort.send(AiIsolateChunk(chunk));
          await Future<void>.delayed(const Duration(milliseconds: 30));
        }

        mainSendPort.send(AiIsolateDone());
      } catch (e) {
        mainSendPort.send(AiIsolateError(e.toString()));
      }
      continue;
    }

    if (message is AiTrainRegressionRequest) {
      try {
        final coefficients = trainRegression(message.samples);
        mainSendPort.send(
          AiTrainRegressionResult(
            b0: coefficients.b0,
            b1: coefficients.b1,
            b2: coefficients.b2,
          ),
        );
      } catch (e) {
        mainSendPort.send(AiIsolateError(e.toString()));
      }
      continue;
    }

    if (message is AiInferRegressionRequest) {
      final prediction =
          message.b0 +
          (message.b1 * message.cadenceSpm) +
          (message.b2 * message.powerWatts);
      mainSendPort.send(AiInferRegressionResult(prediction));
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
