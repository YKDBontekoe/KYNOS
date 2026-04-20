import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/infrastructure/ai/ai_infrastructure_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'model_setup_provider.g.dart';

@Riverpod(keepAlive: true)
class ModelSetupNotifier extends _$ModelSetupNotifier {
  @override
  AsyncValue<bool> build() => const AsyncData(false);

  Future<void> checkAndInstall() async {
    if (state.valueOrNull == true) return;
    state = const AsyncLoading();
    try {
      final AiModelRepository repo = ref.read(aiModelRepositoryProvider);
      await repo.initialize();

      final token = AppConstants.huggingFaceToken.isEmpty
          ? null
          : AppConstants.huggingFaceToken;

      final candidateUrls = <String>[
        AppConstants.modelDownloadUrl,
        AppConstants.fallbackModelDownloadUrl,
      ];

      Object? lastError;
      for (final url in candidateUrls) {
        final tokenCandidates = <String?>[
          token,
          // Retry anonymously if token is invalid/unauthorized for this model.
          null,
        ];

        for (final candidateToken in tokenCandidates) {
          try {
            await repo.installFromNetwork(url: url, token: candidateToken);
            state = const AsyncData(true);
            return;
          } catch (e) {
            lastError = e;
          }
        }
      }

      if (repo.hasActiveModel) {
        state = const AsyncData(true);
        return;
      }

      if (lastError != null) {
        throw lastError;
      }
      throw Exception('Model installation failed.');
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
