import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:kynos/core/constants/app_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'model_setup_provider.g.dart';

@Riverpod(keepAlive: true)
class ModelSetupNotifier extends _$ModelSetupNotifier {
  @override
  AsyncValue<bool> build() {
    return const AsyncData(false);
  }

  Future<void> checkAndInstall() async {
    state = const AsyncLoading();
    
    try {
      // 1. Initialise as per docs
      await FlutterGemma.initialize();
      
      // 2. Check if installed
      if (FlutterGemma.hasActiveModel()) {
        state = const AsyncData(true);
        return;
      }

      // 3. Install from network as per docs
      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromNetwork(
            AppConstants.modelDownloadUrl,
            token: AppConstants.huggingFaceToken.isEmpty 
                ? null 
                : AppConstants.huggingFaceToken,
          )
          .install();

      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
