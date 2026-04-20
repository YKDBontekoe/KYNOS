import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';

/// flutter_gemma implementation of [AiModelRepository].
///
/// Handles model file download, installation check, and runtime initialisation.
class OnDeviceModelRepository implements AiModelRepository {
  @override
  bool get hasActiveModel => FlutterGemma.hasActiveModel();

  @override
  Future<void> initialize() => FlutterGemma.initialize();

  @override
  Future<void> installFromNetwork({required String url, String? token}) async {
    await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
        .fromNetwork(url, token: token)
        .install();
  }
}
