import 'package:kynos/domain/entities/ai_inference_backend.dart';
import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';

/// Maps per-conversation backend mode to repository preferred backend.
abstract final class CoachBackendModeMapper {
  static AiInferenceBackend? toPreferredBackend(CoachBackendMode mode) {
    return switch (mode) {
      CoachBackendMode.auto => null,
      CoachBackendMode.onDevice => AiInferenceBackend.onDevice,
      CoachBackendMode.cloud => AiInferenceBackend.openRouter,
    };
  }
}
