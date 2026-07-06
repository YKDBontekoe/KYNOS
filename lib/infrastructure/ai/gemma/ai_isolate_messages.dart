import 'package:flutter/services.dart';

enum AiPreferredBackend { gpu, cpu }

// Request messages
sealed class AiIsolateRequest {}

class AiInitRequest implements AiIsolateRequest {
  AiInitRequest(this.rootToken, {this.huggingFaceToken});

  final RootIsolateToken rootToken;
  final String? huggingFaceToken;
}

class AiChatRequest implements AiIsolateRequest {
  AiChatRequest(this.userMessage, {required this.requestId});

  final String userMessage;
  final int requestId;
}

class AiReloadChatRequest implements AiIsolateRequest {
  AiReloadChatRequest({required this.requestId});

  final int requestId;
}

class AiReloadModelRequest implements AiIsolateRequest {
  AiReloadModelRequest({
    required this.backend,
    required this.requestId,
  });

  final AiPreferredBackend backend;
  final int requestId;
}

class AiTrainRegressionRequest implements AiIsolateRequest {
  AiTrainRegressionRequest(this.samples);

  final List<AiRegressionSample> samples;
}

class AiInferRegressionRequest implements AiIsolateRequest {
  AiInferRegressionRequest({
    required this.cadenceSpm,
    required this.powerWatts,
    required this.b0,
    required this.b1,
    required this.b2,
  });

  final double cadenceSpm;
  final double powerWatts;
  final double b0;
  final double b1;
  final double b2;
}

class AiResetSessionRequest implements AiIsolateRequest {
  AiResetSessionRequest({this.requestId = 0});

  final int requestId;
}

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
  AiIsolateChunk(this.chunk, {required this.requestId});

  final String chunk;
  final int requestId;
}

class AiIsolateDone implements AiIsolateResponse {
  AiIsolateDone({this.requestId = 0});

  final int requestId;
}

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

class AiInferRegressionResult implements AiIsolateResponse {
  AiInferRegressionResult(this.prediction);

  final double prediction;
}

class AiIsolateError implements AiIsolateResponse {
  AiIsolateError(this.error, {required this.requestId});

  final String error;
  final int requestId;
}
