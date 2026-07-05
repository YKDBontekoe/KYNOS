import 'package:meta/meta.dart';

@immutable
class OpenRouterModelPricing {
  const OpenRouterModelPricing({
    required this.prompt,
    required this.completion,
  });

  /// USD per token (string from API).
  final String prompt;
  final String completion;
}

@immutable
class OpenRouterModel {
  const OpenRouterModel({
    required this.id,
    required this.name,
    required this.contextLength,
    required this.pricing,
    this.description,
    this.expirationDate,
  });

  final String id;
  final String name;
  final int contextLength;
  final OpenRouterModelPricing pricing;
  final String? description;
  final String? expirationDate;
}

/// Whether both input and output token pricing are zero.
bool isFreeOpenRouterModel(OpenRouterModel model) {
  final input = double.tryParse(model.pricing.prompt) ?? -1;
  final output = double.tryParse(model.pricing.completion) ?? -1;
  return input == 0 && output == 0;
}

String formatOpenRouterPricing(OpenRouterModel model) {
  if (isFreeOpenRouterModel(model)) return 'Free';
  final input = double.tryParse(model.pricing.prompt);
  final output = double.tryParse(model.pricing.completion);
  if (input == null || output == null) return '—';
  // API returns per-token; display as $/M tokens.
  final inputPerM = input * 1e6;
  final outputPerM = output * 1e6;
  return '\$${inputPerM.toStringAsFixed(2)}/M in · '
      '\$${outputPerM.toStringAsFixed(2)}/M out';
}
