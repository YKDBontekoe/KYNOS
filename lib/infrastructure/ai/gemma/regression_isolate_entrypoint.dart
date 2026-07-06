import 'dart:async';
import 'dart:isolate';

import 'package:kynos/infrastructure/ai/gemma/ai_isolate_messages.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_regression_math.dart';

/// Lightweight background worker for gait regression math (no LLM deps).
Future<void> regressionIsolateEntrypoint(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  await for (final message in receivePort) {
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
        mainSendPort.send(AiIsolateError(e.toString(), requestId: 0));
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

    if (message is AiDisposeRequest) {
      break;
    }
  }
}
