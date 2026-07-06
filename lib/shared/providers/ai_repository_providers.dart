import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/ai_coach_repository.dart';
import 'package:kynos/domain/repositories/cloud_ai_repository.dart';
import 'package:kynos/domain/repositories/openrouter_models_repository.dart';
import 'package:kynos/features/settings/providers/settings_provider.dart';
import 'package:kynos/infrastructure/ai/hybrid_ai_coach_repository.dart';
import 'package:kynos/infrastructure/ai/isolate_ai_coach_repository.dart';
import 'package:kynos/infrastructure/ai/openrouter/openrouter_cloud_ai_repository.dart';
import 'package:kynos/infrastructure/ai/openrouter/openrouter_models_repository_impl.dart';
import 'package:kynos/shared/providers/openrouter_api_key_provider.dart';

export 'package:kynos/infrastructure/ai/ai_infrastructure_providers.dart'
    show aiModelRepositoryProvider;
export 'package:kynos/infrastructure/ai/gemma/gemma_runtime.dart'
    show GemmaRuntime;

/// Whether coach chat can run via OpenRouter without a local model install.
final isCloudCoachConfiguredProvider = FutureProvider<bool>((ref) async {
  final settings = ref.watch(settingsProvider);
  if (!settings.cloudTasksEnabled || !settings.hasSelectedCloudModel) {
    return false;
  }
  final apiKey = await ref.read(openRouterApiKeyManagerProvider.future);
  return apiKey != null && apiKey.isNotEmpty;
});

final openRouterModelsRepositoryProvider = Provider<OpenRouterModelsRepository>(
  (ref) => OpenRouterModelsRepositoryImpl(),
);

final cloudAiRepositoryProvider = Provider<CloudAiRepository>(
  (ref) => OpenRouterCloudAiRepository(),
);

final localAiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  final repo = IsolateAiCoachRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Hybrid coach — local isolate Gemma + optional OpenRouter cloud.
final aiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  final local = ref.watch(localAiCoachRepositoryProvider);
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
      );
    },
  );
  ref.onDispose(repo.dispose);
  return repo;
});
