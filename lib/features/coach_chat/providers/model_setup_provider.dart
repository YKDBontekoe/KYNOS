import 'package:kynos/domain/catalog/on_device_model_catalog.dart';
import 'package:kynos/domain/repositories/ai_model_repository.dart';
import 'package:kynos/features/coach_chat/providers/model_setup_state.dart';
import 'package:kynos/features/settings/providers/settings_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/huggingface_token_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'model_setup_provider.g.dart';

class MissingHuggingFaceTokenException implements Exception {
  MissingHuggingFaceTokenException(this.modelName);

  final String modelName;

  @override
  String toString() =>
      'A HuggingFace access token is required to download $modelName. '
      'Add your token in Settings → AI & Cloud, or choose a public model '
      'such as Qwen3 0.6B.';
}

@Riverpod(keepAlive: true)
class ModelSetupNotifier extends _$ModelSetupNotifier {
  bool _installInProgress = false;

  @override
  AsyncValue<ModelSetupState> build() =>
      const AsyncData(ModelSetupState(phase: ModelSetupPhase.checking));

  Future<void> checkAndInstall({bool force = false}) async {
    if (_installInProgress) return;
    if (!force && state.value?.isReady == true) return;
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
      final cloudReady = await ref.read(isCloudCoachConfiguredProvider.future);
      if (cloudReady) {
        state = const AsyncData(ModelSetupState(phase: ModelSetupPhase.ready));
        return;
      }

      final settings = ref.read(settingsProvider);
      final model = OnDeviceModelCatalog.byId(settings.selectedLocalModelId);

      String? hfToken;
      if (model.requiresHuggingFaceToken) {
        hfToken = await ref.read(huggingFaceTokenManagerProvider.future);
        if (hfToken == null || hfToken.isEmpty) {
          throw MissingHuggingFaceTokenException(model.name);
        }
      }

      state = AsyncData(
        ModelSetupState(
          phase: ModelSetupPhase.checking,
          progressMessage: 'Initialising ${model.name}…',
        ),
      );

      final AiModelRepository repo = ref.read(aiModelRepositoryProvider);
      await repo.initialize(huggingFaceToken: hfToken);

      final installedId = settings.installedLocalModelId;
      if (installedId != null) {
        GemmaRuntime.markInstalled(installedId);
      }

      if (repo.hasActiveModel && settings.isSelectedLocalModelInstalled) {
        state = const AsyncData(ModelSetupState(phase: ModelSetupPhase.ready));
        return;
      }

      await GemmaRuntime.evictLegacyModelsIfNeeded();

      if (repo.hasActiveModel && settings.isSelectedLocalModelInstalled) {
        state = const AsyncData(ModelSetupState(phase: ModelSetupPhase.ready));
        return;
      }

      state = AsyncData(
        ModelSetupState(
          phase: ModelSetupPhase.downloading,
          progressMessage:
              'Downloading ${model.name} — this may take several minutes on Wi‑Fi.',
        ),
      );

      await repo.install(model, token: hfToken);
      await ref.read(settingsProvider.notifier).markLocalModelInstalled(model.id);
      state = const AsyncData(ModelSetupState(phase: ModelSetupPhase.ready));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
