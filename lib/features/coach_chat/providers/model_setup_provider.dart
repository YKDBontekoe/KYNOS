import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'model_setup_provider.g.dart';

@Riverpod(keepAlive: true)
class ModelSetupNotifier extends _$ModelSetupNotifier {
  @override
  AsyncValue<bool> build() => const AsyncData(false);

  Future<void> checkAndInstall() async {
    state = const AsyncLoading();
    try {
      final AiModelRepository repo = ref.read(aiModelRepositoryProvider);
      await repo.initialize();

      if (repo.hasActiveModel) {
        state = const AsyncData(true);
        return;
      }

      await repo.installFromNetwork(
        url: AppConstants.modelDownloadUrl,
        token: AppConstants.huggingFaceToken.isEmpty
            ? null
            : AppConstants.huggingFaceToken,
      );
      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
