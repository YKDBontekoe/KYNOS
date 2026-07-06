import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/features/coach_chat/providers/model_setup_state.dart';
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
  bool _installInProgress = false;

  @override
  AsyncValue<ModelSetupState> build() =>
      const AsyncData(ModelSetupState(phase: ModelSetupPhase.checking));

  Future<void> checkAndInstall() async {
    if (_installInProgress) return;
    _installInProgress = true;
    try {
      await _checkAndInstallImpl();
    } finally {
      _installInProgress = false;
    }
  }

  Future<void> _checkAndInstallImpl() async {
    state = const AsyncLoading();
    try {
      final hfToken = await ref.read(huggingFaceTokenManagerProvider.future);
      if (hfToken == null || hfToken.isEmpty) {
        throw MissingHuggingFaceTokenException();
      }

      state = const AsyncData(
        ModelSetupState(
          phase: ModelSetupPhase.checking,
          progressMessage: 'Initialising on-device runtime…',
        ),
      );

      final AiModelRepository repo = ref.read(aiModelRepositoryProvider);
      await repo.initialize(huggingFaceToken: hfToken);

      if (repo.hasActiveModel) {
        state = const AsyncData(ModelSetupState(phase: ModelSetupPhase.ready));
        return;
      }

      await GemmaRuntime.evictLegacyModelsIfNeeded();

      if (repo.hasActiveModel) {
        state = const AsyncData(ModelSetupState(phase: ModelSetupPhase.ready));
        return;
      }

      state = const AsyncData(
        ModelSetupState(
          phase: ModelSetupPhase.downloading,
          progressMessage:
              'Downloading coach model — this may take several minutes on Wi‑Fi.',
        ),
      );

      await repo.installFromNetwork(url: GemmaRuntime.modelDownloadUrl, token: hfToken);
      state = const AsyncData(ModelSetupState(phase: ModelSetupPhase.ready));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
