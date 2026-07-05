import 'dart:async';

import 'package:kynos/domain/entities/openrouter_model.dart';
import 'package:kynos/domain/entities/openrouter_model_filters.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/openrouter_api_key_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'openrouter_models_provider.g.dart';

class OpenRouterCatalogState {
  const OpenRouterCatalogState({
    required this.filters,
    this.searchQuery = '',
  });

  final OpenRouterModelFilters filters;
  final String searchQuery;

  OpenRouterModelFilters get effectiveFilters => filters.copyWith(
        query: searchQuery.isEmpty ? filters.query : searchQuery,
      );
}

@Riverpod(keepAlive: true)
class OpenRouterCatalog extends _$OpenRouterCatalog {
  static const _sortKey = 'openrouter_sort';
  static const _freeKey = 'openrouter_free_only';
  static const _categoryKey = 'openrouter_category';
  Timer? _searchDebounce;

  @override
  OpenRouterCatalogState build() {
    ref.onDispose(() => _searchDebounce?.cancel());
    _loadFilterPrefs();
    return const OpenRouterCatalogState(
      filters: OpenRouterModelFilters(
        sort: OpenRouterModelSort.mostPopular,
        category: OpenRouterModelFilters.defaultCategory,
      ),
    );
  }

  Future<void> _loadFilterPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final sortName = prefs.getString(_sortKey);
    final sort = OpenRouterModelSort.values.firstWhere(
      (s) => s.name == sortName,
      orElse: () => OpenRouterModelSort.mostPopular,
    );
    final freeOnly = prefs.getBool(_freeKey) ?? false;
    final category =
        prefs.getString(_categoryKey) ?? OpenRouterModelFilters.defaultCategory;

    state = OpenRouterCatalogState(
      filters: OpenRouterModelFilters(
        sort: sort,
        category: category,
        freeOnly: freeOnly,
      ),
      searchQuery: state.searchQuery,
    );
  }

  void setSearchQuery(String query) {
    state = OpenRouterCatalogState(
      filters: state.filters,
      searchQuery: query,
    );
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      ref.invalidate(openRouterCatalogDataProvider);
    });
  }

  Future<void> updateFilters(OpenRouterModelFilters filters) async {
    state = OpenRouterCatalogState(
      filters: filters,
      searchQuery: state.searchQuery,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortKey, filters.sort.name);
    await prefs.setBool(_freeKey, filters.freeOnly);
    if (filters.category != null) {
      await prefs.setString(_categoryKey, filters.category!);
    } else {
      await prefs.remove(_categoryKey);
    }
    ref.invalidate(openRouterCatalogDataProvider);
    ref.read(openRouterModelsRepositoryProvider).invalidateCache();
  }

  Future<void> toggleFreeOnly() {
    return updateFilters(
      state.filters.copyWith(freeOnly: !state.filters.freeOnly),
    );
  }

  Future<void> setSort(OpenRouterModelSort sort) {
    return updateFilters(state.filters.copyWith(sort: sort));
  }
}

@riverpod
Future<({List<OpenRouterModel>? models, String? error})> openRouterCatalogData(
  Ref ref,
) async {
  final apiKey = await ref.watch(openRouterApiKeyManagerProvider.future);
  if (apiKey == null || apiKey.isEmpty) {
    return (models: null, error: 'Add your OpenRouter API key in Settings first.');
  }

  final catalog = ref.watch(openRouterCatalogProvider);
  final repo = ref.watch(openRouterModelsRepositoryProvider);
  final result = await repo.listModels(
    apiKey: apiKey,
    filters: catalog.effectiveFilters,
  );
  return (models: result.models, error: result.error);
}
