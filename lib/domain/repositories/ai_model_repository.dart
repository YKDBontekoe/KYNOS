/// Contract for managing the lifecycle of the on-device AI model file.
///
/// Covers installation (download), readiness checks, and initialisation.
/// The implementation lives in infrastructure and uses flutter_gemma internals.
abstract interface class AiModelRepository {
  /// Whether a model file is already installed and available for inference.
  bool get hasActiveModel;

  /// Initialises the underlying inference runtime (must be called before use).
  ///
  /// Pass [huggingFaceToken] for gated HuggingFace model downloads.
  Future<void> initialize({String? huggingFaceToken});

  /// Downloads and installs the model from [url].
  ///
  /// Pass [token] for gated HuggingFace repositories; omit for public files.
  Future<void> installFromNetwork({required String url, String? token});
}
