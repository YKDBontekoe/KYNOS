import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/huggingface_token_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'model_setup_provider.g.dart';

class MissingHuggingFaceTokenException implements Exception {
  MissingHuggingFaceTokenException();

  @override
  String toString() =>
      'A HuggingFace access token is required to download the on-device '
      'coach model. Add your token in Settings → AI & Cloud.';
}

@Riverpod(keepAlive: true)
class ModelSetupNotifier extends _$ModelSetupNotifier {
  @override
  AsyncValue<bool> build() => const AsyncData(false);

  Future<void> checkAndInstall() async {
    state = const AsyncLoading();
    try {
      final hfToken = await ref.read(huggingFaceTokenManagerProvider.future);
      if (hfToken == null || hfToken.isEmpty) {
        throw MissingHuggingFaceTokenException();
      }

      final AiModelRepository repo = ref.read(aiModelRepositoryProvider);
      await repo.initialize(huggingFaceToken: hfToken);

      if (repo.hasActiveModel) {
        state = const AsyncData(true);
        return;
      }

      await repo.installFromNetwork(url: GemmaRuntime.modelDownloadUrl, token: hfToken);
      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
