import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/core/constants/app_constants.dart';

// Request messages
sealed class AiIsolateRequest {}

class AiInitRequest implements AiIsolateRequest {
  AiInitRequest(this.rootToken);

  final RootIsolateToken rootToken;
}

class AiChatRequest implements AiIsolateRequest {
  AiChatRequest(this.userMessage);

  final String userMessage;
}

class AiTrainRegressionRequest implements AiIsolateRequest {
  AiTrainRegressionRequest(this.samples);

  final List<AiRegressionSample> samples;
}

class AiResetSessionRequest implements AiIsolateRequest {}

class AiDisposeRequest implements AiIsolateRequest {}

class AiRegressionSample {
  const AiRegressionSample({
    required this.cadenceSpm,
    required this.powerWatts,
    required this.strideLengthMeters,
  });

  final double cadenceSpm;
  final double powerWatts;
  final double strideLengthMeters;
}

// Response messages
sealed class AiIsolateResponse {}

class AiIsolateReady implements AiIsolateResponse {}

class AiIsolateChunk implements AiIsolateResponse {
  AiIsolateChunk(this.chunk);

  final String chunk;
}

class AiIsolateDone implements AiIsolateResponse {}

class AiTrainRegressionResult implements AiIsolateResponse {
  AiTrainRegressionResult({
    required this.b0,
    required this.b1,
    required this.b2,
  });

  final double b0;
  final double b1;
  final double b2;
}

class AiIsolateError implements AiIsolateResponse {
  AiIsolateError(this.error);

  final String error;
}

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
        await FlutterGemma.initialize();

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
          await FlutterGemma.installModel(
            modelType: ModelType.gemmaIt,
          ).fromNetwork(
            AppConstants.modelDownloadUrl,
            token: AppConstants.huggingFaceToken.isEmpty
                ? null
                : AppConstants.huggingFaceToken,
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
        final coefficients = _trainRegression(message.samples);
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

({double b0, double b1, double b2}) _trainRegression(
  List<AiRegressionSample> samples,
) {
  if (samples.length < 3) {
    throw StateError(
      'At least 3 samples are required for multivariate regression.',
    );
  }

  double s1 = 0;
  double sc = 0;
  double sp = 0;
  double scc = 0;
  double spp = 0;
  double scp = 0;

  double sy = 0;
  double scy = 0;
  double spy = 0;

  for (final sample in samples) {
    final c = sample.cadenceSpm;
    final p = sample.powerWatts;
    final y = sample.strideLengthMeters;

    s1 += 1;
    sc += c;
    sp += p;
    scc += c * c;
    spp += p * p;
    scp += c * p;

    sy += y;
    scy += c * y;
    spy += p * y;
  }

  // Small ridge term for numerical stability on highly-correlated run data.
  const ridge = 1e-6;
  final matrix = <List<double>>[
    <double>[s1 + ridge, sc, sp],
    <double>[sc, scc + ridge, scp],
    <double>[sp, scp, spp + ridge],
  ];
  final vector = <double>[sy, scy, spy];

  return _solve3x3(matrix, vector);
}

({double b0, double b1, double b2}) _solve3x3(
  List<List<double>> a,
  List<double> b,
) {
  final m = List<List<double>>.generate(
    3,
    (r) => <double>[a[r][0], a[r][1], a[r][2], b[r]],
  );

  for (var col = 0; col < 3; col++) {
    var pivotRow = col;
    var pivotSize = m[col][col].abs();
    for (var row = col + 1; row < 3; row++) {
      final size = m[row][col].abs();
      if (size > pivotSize) {
        pivotSize = size;
        pivotRow = row;
      }
    }

    if (pivotSize < 1e-12) {
      throw StateError('Regression matrix is singular.');
    }

    if (pivotRow != col) {
      final temp = m[col];
      m[col] = m[pivotRow];
      m[pivotRow] = temp;
    }

    final pivot = m[col][col];
    for (var j = col; j < 4; j++) {
      m[col][j] = m[col][j] / pivot;
    }

    for (var row = 0; row < 3; row++) {
      if (row == col) continue;
      final factor = m[row][col];
      for (var j = col; j < 4; j++) {
        m[row][j] = m[row][j] - (factor * m[col][j]);
      }
    }
  }

  return (b0: m[0][3], b1: m[1][3], b2: m[2][3]);
}
