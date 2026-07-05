import 'package:kynos/domain/entities/openrouter_model.dart';
import 'package:kynos/domain/entities/openrouter_model_filters.dart';

/// Contract for fetching the OpenRouter model catalog.
abstract interface class OpenRouterModelsRepository {
  Future<({List<OpenRouterModel>? models, String? error})> listModels({
    required String apiKey,
    required OpenRouterModelFilters filters,
  });

  void invalidateCache();
}
