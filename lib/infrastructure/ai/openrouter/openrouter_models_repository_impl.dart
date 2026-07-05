import 'package:kynos/domain/entities/openrouter_model.dart';
import 'package:kynos/domain/entities/openrouter_model_filters.dart';
import 'package:kynos/domain/repositories/openrouter_models_repository.dart';
import 'package:kynos/infrastructure/ai/openrouter/openrouter_api_client.dart';

class OpenRouterModelsRepositoryImpl implements OpenRouterModelsRepository {
  OpenRouterModelsRepositoryImpl({OpenRouterApiClient? client})
      : _client = client ?? OpenRouterApiClient();

  final OpenRouterApiClient _client;

  List<OpenRouterModel>? _cache;
  OpenRouterModelFilters? _cacheFilters;
  DateTime? _cacheTime;

  static const _cacheTtl = Duration(hours: 24);

  @override
  Future<({List<OpenRouterModel>? models, String? error})> listModels({
    required String apiKey,
    required OpenRouterModelFilters filters,
  }) async {
    final now = DateTime.now();
    if (_cache != null &&
        _cacheFilters == filters &&
        _cacheTime != null &&
        now.difference(_cacheTime!) < _cacheTtl) {
      return (models: _cache, error: null);
    }

    final result = await _client.listModels(apiKey: apiKey, filters: filters);
    if (result.models != null) {
      _cache = result.models;
      _cacheFilters = filters;
      _cacheTime = now;
    }
    return result;
  }

  @override
  void invalidateCache() {
    _cache = null;
    _cacheFilters = null;
    _cacheTime = null;
  }
}
