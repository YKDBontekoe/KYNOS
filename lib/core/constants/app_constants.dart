/// Compile-time constants for KYNOS.
abstract final class AppConstants {
  // ── AI Model ──────────────────────────────────────────────────────────────
  /// Preferred on-device model for mid-range iOS (iPhone 14 Pro, 6 GB RAM).
  static const String defaultModelId = 'gemma4-e2b-int4';

  /// Fallback model when thermals exceed [thermalThresholdCelsius].
  static const String fallbackModelId = 'gemma4-e2b-int4'; // same tier, lower threads

  /// Maximum RAM budget (bytes) reserved for the AI runtime.
  static const int aiRamBudgetBytes = 3 * 1024 * 1024 * 1024; // 3 GB

  /// Context window (tokens) supported by Gemma 4 E2B.
  static const int modelContextWindow = 128000;

  // ── Inference ─────────────────────────────────────────────────────────────
  /// Target frame render budget at 120 Hz ProMotion (ms).
  static const double frameTargetMs = 8.33;

  // ── Biomechanics ─────────────────────────────────────────────────────────
  /// Minimum cadence considered biomechanically optimal (steps/min).
  static const int optimalCadenceMin = 170;

  /// Maximum recommended ACWR (Acute:Chronic Workload Ratio) to avoid injury.
  static const double acwrSafeMax = 1.3;

  /// Recommended volume variation tolerance between training weeks.
  static const double weeklyVolumeTolerance = 0.10; // ±10 %

  // ── Privacy ───────────────────────────────────────────────────────────────
  /// All biometric data stays on-device; this flag disables any cloud path.
  static const bool zeroKnowledgeMode = true;

  // ── Export ────────────────────────────────────────────────────────────────
  static const String exportFormatParquet = 'parquet';
  static const String exportFormatProtobuf = 'protobuf';
  static const String exportFormatJson = 'json';
}
