import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/cloud_ai_repository.dart';
import 'package:kynos/domain/repositories/openrouter_models_repository.dart';
import 'package:kynos/infrastructure/ai/hybrid_ai_coach_repository.dart';
import 'package:kynos/infrastructure/ai/isolate_ai_coach_repository.dart';
import 'package:kynos/infrastructure/ai/openai_compatible/openai_compatible_cloud_ai_repository.dart';
import 'package:kynos/infrastructure/ai/openrouter/openrouter_models_repository_impl.dart';
import 'package:kynos/shared/providers/openrouter_api_key_provider.dart';
import 'package:kynos/shared/providers/settings_provider.dart';

export 'package:kynos/infrastructure/ai/ai_infrastructure_providers.dart'
    show aiModelRepositoryProvider;
export 'package:kynos/infrastructure/ai/gemma/gemma_device_ram_probe.dart'
    show GemmaDeviceRamProbe;
export 'package:kynos/infrastructure/ai/gemma/gemma_runtime.dart'
    show GemmaRuntime;

/// Whether coach chat can run via a configured cloud endpoint without a local model.
final isCloudCoachConfiguredProvider = FutureProvider<bool>((ref) async {
  final settings = ref.watch(settingsProvider);
  if (!settings.cloudTasksEnabled || !settings.hasSelectedCloudModel) {
    return false;
  }
  if (settings.cloudBaseUrl.trim().isEmpty) return false;
  final apiKey = await ref.read(openRouterApiKeyManagerProvider.future);
  return apiKey != null && apiKey.isNotEmpty;
});

final openRouterModelsRepositoryProvider = Provider<OpenRouterModelsRepository>(
  (ref) => OpenRouterModelsRepositoryImpl(),
);

final cloudAiRepositoryProvider = Provider<CloudAiRepository>(
  (ref) => OpenAiCompatibleCloudAiRepository(),
);

HybridAiCoachRepository _createHybridRepo(
  Ref ref,
  AiCoachRepository local,
) {
  final cloud = ref.watch(cloudAiRepositoryProvider);
  final keyStorage = ref.watch(secureApiKeyStorageProvider);

  final repo = HybridAiCoachRepository(
    localRepository: local,
    cloudRepository: cloud,
    keyStorage: keyStorage,
    configReader: () async {
      final settings = ref.read(settingsProvider);
      return HybridAiCoachConfig(
        cloudTasksEnabled: settings.cloudTasksEnabled,
        cloudDataLevel: settings.cloudDataLevel,
        selectedModelId: settings.selectedCloudModelId,
        selectedModelName: settings.selectedCloudModelName,
        cloudBaseUrl: settings.cloudBaseUrl,
      );
    },
  );
  ref.onDispose(repo.dispose);
  return repo;
}

/// On-device isolate for interactive coach chat (isolated from refinements).
final localChatAiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  final repo = IsolateAiCoachRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

/// On-device isolate for background insight/quest refinements.
final localRefinementAiCoachRepositoryProvider =
    Provider<AiCoachRepository>((ref) {
  final repo = IsolateAiCoachRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Hybrid coach for interactive chat — local isolate + optional cloud LLM.
final chatAiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  final local = ref.watch(localChatAiCoachRepositoryProvider);
  return _createHybridRepo(ref, local);
});

/// Hybrid coach for background refinements — separate isolate session.
final refinementAiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  final local = ref.watch(localRefinementAiCoachRepositoryProvider);
  return _createHybridRepo(ref, local);
});

/// @deprecated Use [refinementAiCoachRepositoryProvider] or [chatAiCoachRepositoryProvider].
final localAiCoachRepositoryProvider = localRefinementAiCoachRepositoryProvider;

/// Background AI jobs (insights, quests, debrief).
final aiCoachRepositoryProvider = refinementAiCoachRepositoryProvider;
