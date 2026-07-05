import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/repositories/biomechanics_repository.dart';
import 'package:kynos/infrastructure/ai/biomechanics/biomechanics_coefficients_protobuf.dart';
import 'package:kynos/infrastructure/ai/gemma/ai_isolate_bridge.dart';
import 'package:kynos/infrastructure/privacy/local_sync_privacy_guard.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// On-device biomechanics model repository backed by AI isolate training.
class OnDeviceBiomechanicsRepository implements BiomechanicsRepository {
  OnDeviceBiomechanicsRepository({LocalSyncPrivacyGuard? privacyGuard})
    : _privacyGuard = privacyGuard ?? LocalSyncPrivacyGuard();

  final LocalSyncPrivacyGuard _privacyGuard;

  Isolate? _isolate;
  SendPort? _isolateSendPort;
  StreamController<AiIsolateResponse>? _responseController;

  double? _b0;
  double? _b1;
  double? _b2;

  @override
  ({double? b0, double? b1, double? b2}) get coefficients =>
      (b0: _b0, b1: _b1, b2: _b2);

  @override
  Future<Failure?> train(List<BiomechanicsSample> samples) async {
    if (samples.length < 3) {
      return const BiomechanicsModelFailure(
        'At least 3 steady-state samples are required for training.',
      );
    }

    final privacyFailure = await _privacyGuard
        .verifyNoRawSensorDataStagedForCloudSync();
    if (privacyFailure != null) {
      return privacyFailure;
    }

    try {
      await _ensureIsolate();

      final completer = Completer<AiTrainRegressionResult>();
      late final StreamSubscription<AiIsolateResponse> sub;
      sub = _responseController!.stream.listen((response) {
        if (response is AiTrainRegressionResult) {
          if (!completer.isCompleted) {
            completer.complete(response);
          }
          unawaited(sub.cancel());
        } else if (response is AiIsolateError) {
          if (!completer.isCompleted) {
            completer.completeError(StateError(response.error));
          }
          unawaited(sub.cancel());
        }
      });

      final requestSamples = samples
          .map(
            (sample) => AiRegressionSample(
              cadenceSpm: sample.cadenceSpm,
              powerWatts: sample.powerWatts,
              strideLengthMeters: sample.strideLengthMeters,
            ),
          )
          .toList(growable: false);

      _isolateSendPort!.send(AiTrainRegressionRequest(requestSamples));
      final result = await completer.future.timeout(const Duration(seconds: 5));

      _b0 = result.b0;
      _b1 = result.b1;
      _b2 = result.b2;

      return null;
    } catch (e) {
      return BiomechanicsModelFailure(e.toString());
    }
  }

  @override
  Future<({double? prediction, Failure? failure})> infer({
    required double cadenceSpm,
    required double powerWatts,
  }) async {
    final b0 = _b0;
    final b1 = _b1;
    final b2 = _b2;
    if (b0 == null || b1 == null || b2 == null) {
      return (
        prediction: null,
        failure: const BiomechanicsModelFailure('Model is not calibrated yet.'),
      );
    }

    try {
      await _ensureIsolate();

      final completer = Completer<AiInferRegressionResult>();
      late final StreamSubscription<AiIsolateResponse> sub;
      sub = _responseController!.stream.listen((response) {
        if (response is AiInferRegressionResult) {
          if (!completer.isCompleted) {
            completer.complete(response);
          }
          unawaited(sub.cancel());
        } else if (response is AiIsolateError) {
          if (!completer.isCompleted) {
            completer.completeError(StateError(response.error));
          }
          unawaited(sub.cancel());
        }
      });

      _isolateSendPort!.send(
        AiInferRegressionRequest(
          cadenceSpm: cadenceSpm,
          powerWatts: powerWatts,
          b0: b0,
          b1: b1,
          b2: b2,
        ),
      );

      final result = await completer.future.timeout(const Duration(seconds: 5));
      return (prediction: result.prediction, failure: null);
    } catch (e) {
      return (
        prediction: null,
        failure: BiomechanicsModelFailure(e.toString()),
      );
    }
  }

  @override
  Future<Failure?> save() async {
    final b0 = _b0;
    final b1 = _b1;
    final b2 = _b2;
    if (b0 == null || b1 == null || b2 == null) {
      return const StorageFailure('No trained coefficients to save.');
    }

    try {
      final encoded = BiomechanicsCoefficientsProtobuf(
        b0: b0,
        b1: b1,
        b2: b2,
        updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      ).encode();

      final file = await _modelFile();
      await file.parent.create(recursive: true);
      await file.writeAsBytes(encoded, flush: true);

      return null;
    } catch (e) {
      return StorageFailure(e.toString());
    }
  }

  @override
  Future<Failure?> restore() async {
    try {
      final file = await _modelFile();
      if (!await file.exists()) {
        return null;
      }

      final bytes = await file.readAsBytes();
      final decoded = BiomechanicsCoefficientsProtobuf.decode(bytes);
      if (decoded == null) {
        return const StorageFailure('Stored coefficients file is invalid.');
      }

      _b0 = decoded.b0;
      _b1 = decoded.b1;
      _b2 = decoded.b2;
      return null;
    } catch (e) {
      return StorageFailure(e.toString());
    }
  }

  Future<void> dispose() async {
    if (_isolateSendPort != null) {
      _isolateSendPort!.send(AiDisposeRequest());
    }
    await _responseController?.close();
    _isolate?.kill(priority: Isolate.immediate);

    _isolate = null;
    _isolateSendPort = null;
    _responseController = null;
  }

  Future<void> _ensureIsolate() async {
    if (_isolate != null &&
        _isolateSendPort != null &&
        _responseController != null) {
      return;
    }

    final receivePort = ReceivePort();
    _responseController = StreamController<AiIsolateResponse>.broadcast();
    _isolate = await Isolate.spawn(
      regressionIsolateEntrypoint,
      receivePort.sendPort,
      debugName: 'kynos-regression-isolate',
    );

    receivePort.listen((message) {
      if (message is SendPort) {
        _isolateSendPort = message;
      } else if (message is AiIsolateResponse) {
        _responseController?.add(message);
      }
    });

    while (_isolateSendPort == null) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<File> _modelFile() async {
    final appSupportDirectory = await getApplicationSupportDirectory();
    return File(
      p.join(appSupportDirectory.path, 'models', 'gait_beta_coefficients.pb'),
    );
  }
}
