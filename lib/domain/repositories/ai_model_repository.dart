import 'package:kynos/domain/entities/on_device_model.dart';

/// Contract for managing the lifecycle of the on-device AI model file.
///
/// Covers installation (download), readiness checks, and initialisation.
/// The implementation lives in infrastructure and uses flutter_gemma internals.
abstract interface class AiModelRepository {
  /// Whether a model file is already installed and available for inference.
  bool get hasActiveModel;

  /// Catalog id of the model that was last installed successfully, if known.
  String? get installedModelId;

  /// Initialises the underlying inference runtime (must be called before use).
  ///
  /// Pass [huggingFaceToken] for gated HuggingFace model downloads.
  Future<void> initialize({String? huggingFaceToken});

  /// Downloads and installs [model] from its configured HuggingFace URL.
  Future<void> install(OnDeviceModel model, {String? token});

  /// Whether the active on-device model matches [catalogId].
  bool isActiveModel(String catalogId);
}
