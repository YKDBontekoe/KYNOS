import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/openrouter_model.dart';
import 'package:kynos/domain/entities/openrouter_model_filters.dart';
import 'package:kynos/features/settings/presentation/widgets/openrouter_model_card.dart';
import 'package:kynos/features/settings/providers/openrouter_models_provider.dart';
import 'package:kynos/features/settings/providers/settings_provider.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_loading_line.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

class OpenRouterModelPickerPage extends ConsumerWidget {
  const OpenRouterModelPickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(openRouterCatalogProvider);
    final catalogData = ref.watch(openRouterCatalogDataProvider);
    final settings = ref.watch(settingsProvider);
    final kynos = context.kynosTheme;

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(title: const Text('Choose cloud model')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(tokens.Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search models...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: ref.read(openRouterCatalogProvider.notifier).setSearchQuery,
                ),
                const Gap(tokens.Spacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Free'),
                        selected: catalog.filters.freeOnly,
                        onSelected: (_) => ref
                            .read(openRouterCatalogProvider.notifier)
                            .toggleFreeOnly(),
                      ),
                      const Gap(tokens.Spacing.xs),
                      ..._sortChips(context, ref, catalog.filters.sort),
                    ],
                  ),
                ),
                if (catalog.filters.freeOnly) ...[
                  const Gap(tokens.Spacing.xs),
                  Text(
                    'Free models have \$0 input and output per token.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kynos.secondaryLabel,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const KynosSectionHeader(title: 'Models'),
          Expanded(
            child: catalogData.when(
              loading: () => const Center(
                child: KynosLoadingLine(label: 'Loading models...'),
              ),
              error: (_, _) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(tokens.Spacing.md),
                  child: Text(
                    'Could not load models. Check your API key and try again.',
                  ),
                ),
              ),
              data: (result) {
                if (result.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(tokens.Spacing.md),
                      child: Text(result.error!),
                    ),
                  );
                }
                final models = result.models ?? const <OpenRouterModel>[];
                if (models.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(tokens.Spacing.md),
                      child: Text(
                        catalog.filters.freeOnly
                            ? 'No free models match your filters — '
                                'try clearing family or context filters.'
                            : 'No models found.',
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(openRouterCatalogDataProvider);
                    await ref.read(openRouterCatalogDataProvider.future);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: tokens.Spacing.md,
                    ),
                    itemCount: models.length,
                    itemBuilder: (context, index) {
                      final model = models[index];
                      return OpenRouterModelCard(
                        model: model,
                        isSelected: settings.selectedCloudModelId == model.id,
                        onTap: () => _showDetail(context, ref, model),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _sortChips(
    BuildContext context,
    WidgetRef ref,
    OpenRouterModelSort current,
  ) {
    const sorts = [
      (OpenRouterModelSort.mostPopular, 'Popular'),
      (OpenRouterModelSort.pricingLowToHigh, 'Cheapest'),
      (OpenRouterModelSort.contextHighToLow, 'Context'),
      (OpenRouterModelSort.newest, 'Newest'),
    ];

    return sorts
        .map(
          (s) => Padding(
            padding: const EdgeInsets.only(right: tokens.Spacing.xs),
            child: FilterChip(
              label: Text(s.$2),
              selected: current == s.$1,
              onSelected: (_) =>
                  ref.read(openRouterCatalogProvider.notifier).setSort(s.$1),
            ),
          ),
        )
        .toList();
  }

  void _showDetail(BuildContext context, WidgetRef ref, OpenRouterModel model) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(tokens.Spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(model.name, style: Theme.of(ctx).textTheme.titleLarge),
            const Gap(tokens.Spacing.sm),
            Text(model.id),
            const Gap(tokens.Spacing.sm),
            KynosChip.metric(
              label: 'Pricing',
              value: formatOpenRouterPricing(model),
            ),
            if (model.description != null) ...[
              const Gap(tokens.Spacing.sm),
              Text(model.description!),
            ],
            const Gap(tokens.Spacing.md),
            FilledButton(
              onPressed: () async {
                await ref.read(settingsProvider.notifier).updateSelectedCloudModel(
                      id: model.id,
                      name: model.name,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (context.mounted) {
                  context.pop();
                }
              },
              child: const Text('Select model'),
            ),
          ],
        ),
      ),
    );
  }
}
