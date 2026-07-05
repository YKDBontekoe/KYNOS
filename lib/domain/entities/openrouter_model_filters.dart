import 'package:meta/meta.dart';

/// Server-side sort options for OpenRouter GET /v1/models.
enum OpenRouterModelSort {
  mostPopular('most-popular'),
  pricingLowToHigh('pricing-low-to-high'),
  pricingHighToLow('pricing-high-to-low'),
  contextHighToLow('context-high-to-low'),
  latencyLowToHigh('latency-low-to-high'),
  throughputHighToLow('throughput-high-to-low'),
  newest('newest'),
  intelligenceHighToLow('intelligence-high-to-low');

  const OpenRouterModelSort(this.apiValue);
  final String apiValue;
}

@immutable
class OpenRouterModelFilters {
  const OpenRouterModelFilters({
    this.sort = OpenRouterModelSort.mostPopular,
    this.query,
    this.minPricePerM,
    this.maxPricePerM,
    this.minContextTokens,
    this.architecture,
    this.modelAuthors,
    this.providers,
    this.category,
    this.zeroDataRetention = false,
    this.region,
    this.freeOnly = false,
  });

  static const defaultCategory = 'programming';

  final OpenRouterModelSort sort;
  final String? query;
  final double? minPricePerM;
  final double? maxPricePerM;
  final int? minContextTokens;
  final String? architecture;
  final String? modelAuthors;
  final String? providers;
  final String? category;
  final bool zeroDataRetention;
  final String? region;
  final bool freeOnly;

  OpenRouterModelFilters copyWith({
    OpenRouterModelSort? sort,
    String? query,
    double? minPricePerM,
    double? maxPricePerM,
    int? minContextTokens,
    String? architecture,
    String? modelAuthors,
    String? providers,
    String? category,
    bool? zeroDataRetention,
    String? region,
    bool? freeOnly,
  }) {
    return OpenRouterModelFilters(
      sort: sort ?? this.sort,
      query: query ?? this.query,
      minPricePerM: minPricePerM ?? this.minPricePerM,
      maxPricePerM: maxPricePerM ?? this.maxPricePerM,
      minContextTokens: minContextTokens ?? this.minContextTokens,
      architecture: architecture ?? this.architecture,
      modelAuthors: modelAuthors ?? this.modelAuthors,
      providers: providers ?? this.providers,
      category: category ?? this.category,
      zeroDataRetention: zeroDataRetention ?? this.zeroDataRetention,
      region: region ?? this.region,
      freeOnly: freeOnly ?? this.freeOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenRouterModelFilters &&
          sort == other.sort &&
          query == other.query &&
          minPricePerM == other.minPricePerM &&
          maxPricePerM == other.maxPricePerM &&
          minContextTokens == other.minContextTokens &&
          architecture == other.architecture &&
          modelAuthors == other.modelAuthors &&
          providers == other.providers &&
          category == other.category &&
          zeroDataRetention == other.zeroDataRetention &&
          region == other.region &&
          freeOnly == other.freeOnly;

  @override
  int get hashCode => Object.hash(
        sort,
        query,
        minPricePerM,
        maxPricePerM,
        minContextTokens,
        architecture,
        modelAuthors,
        providers,
        category,
        zeroDataRetention,
        region,
        freeOnly,
      );
}
