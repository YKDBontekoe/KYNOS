import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Compile-time constants for KYNOS.
abstract final class AppConstants {
  // ── AI Model ──────────────────────────────────────────────────────────────
  /// Preferred on-device model for mid-range iOS (iPhone 14 Pro, 6 GB RAM).
  static const String defaultModelId = 'gemma3-1b-int4';
  static const String fallbackModelId = 'gemma3-1b-int4-task';

  /// Maximum RAM budget (bytes) reserved for the AI runtime.
  static const int aiRamBudgetBytes = 3 * 1024 * 1024 * 1024; // 3 GB

  /// Conservative context window for stable mobile inference.
  static const int modelContextWindow = 256;

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

  // ── Model download ────────────────────────────────────────────────────────
  /// Primary mobile-safe Gemma model (smaller profile).
  static const String modelDownloadUrl =
      'https://huggingface.co/litert-community/Gemma3-1B-IT'
      '/resolve/main/gemma3-1b-it-int4.task?download=true';

  /// Fallback bundle variant for runtimes preferring .litertlm packaging.
  static const String fallbackModelDownloadUrl =
      'https://huggingface.co/litert-community/Gemma3-1B-IT'
      '/resolve/main/gemma3-1b-it-int4.litertlm?download=true';

  /// HuggingFace API token — set HF_TOKEN in your .env file.
  /// Leave empty for public/ungated model files.
  static String get huggingFaceToken => dotenv.env['HF_TOKEN'] ?? '';

  // ── Privacy ───────────────────────────────────────────────────────────────
  /// All biometric data stays on-device; this flag disables any cloud path.
  static const bool zeroKnowledgeMode = true;

  // ── Export ────────────────────────────────────────────────────────────────
  static const String exportFormatParquet = 'parquet';
  static const String exportFormatProtobuf = 'protobuf';
  static const String exportFormatJson = 'json';
}
