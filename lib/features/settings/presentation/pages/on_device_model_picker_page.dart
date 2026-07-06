import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/catalog/on_device_model_catalog.dart';
import 'package:kynos/domain/entities/on_device_model.dart';
import 'package:kynos/features/settings/presentation/on_device_model_selection_result.dart';
import 'package:kynos/features/settings/presentation/widgets/on_device_model_card.dart';
import 'package:kynos/features/settings/providers/settings_provider.dart';
import 'package:kynos/shared/providers/ai_reconnect_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/model_setup_provider.dart';
import 'package:kynos/shared/widgets/kynos_section_header.dart';

class OnDeviceModelPickerPage extends ConsumerStatefulWidget {
  const OnDeviceModelPickerPage({super.key});

  @override
  ConsumerState<OnDeviceModelPickerPage> createState() =>
      _OnDeviceModelPickerPageState();
}

class _OnDeviceModelPickerPageState
    extends ConsumerState<OnDeviceModelPickerPage> {
  int? _totalRamBytes;
  bool _loading = true;
  final Set<OnDeviceModelCapability> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    final ramBytes = await GemmaDeviceRamProbe.totalRamBytes();
    if (!mounted) return;
    setState(() {
      _totalRamBytes = ramBytes;
      _loading = false;
    });
  }

  Map<OnDeviceModelTier, List<OnDeviceModel>> get _groupedModels =>
      OnDeviceModelCatalog.modelsGroupedByTier(
        isWeb: kIsWeb,
        totalRamBytes: _totalRamBytes,
        requiredCapabilities:
            _activeFilters.isEmpty ? null : _activeFilters,
      );

  bool get _hasVisibleModels =>
      _groupedModels.values.any((models) => models.isNotEmpty);

  Future<void> _selectModel(OnDeviceModel model) async {
    final settings = ref.read(settingsProvider);
    final wasInstalled = settings.installedLocalModelId == model.id;

    await ref.read(settingsProvider.notifier).updateSelectedLocalModel(
          id: model.id,
          name: model.name,
        );

    if (!wasInstalled) {
      ref.invalidate(modelSetupProvider);
      ref.read(aiReconnectStateProvider.notifier).markNeedsReconnect();
    }

    if (!mounted) return;
    context.pop(
      OnDeviceModelSelectionResult(
        modelName: model.name,
        needsDownload: !wasInstalled,
      ),
    );
  }

  void _toggleFilter(OnDeviceModelCapability capability) {
    setState(() {
      if (_activeFilters.contains(capability)) {
        _activeFilters.remove(capability);
      } else {
        _activeFilters.add(capability);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final kynos = context.kynosTheme;
    final groupedModels = _groupedModels;

    return Scaffold(
      backgroundColor: kynos.background,
      appBar: AppBar(title: const Text('Choose on-device model')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(tokens.Spacing.md),
              children: [
                Text(
                  'Lightweight models run entirely on your phone. '
                  'Check capabilities like thinking, vision, and tool use '
                  'before downloading — larger models need more RAM.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: kynos.secondaryLabel,
                      ),
                ),
                const Gap(tokens.Spacing.md),
                const KynosSectionHeader(title: 'Filter by capability'),
                const Gap(tokens.Spacing.sm),
                Wrap(
                  spacing: tokens.Spacing.xs,
                  runSpacing: tokens.Spacing.xs,
                  children: [
                    _FilterChip(
                      label: 'Tools',
                      isSelected: _activeFilters.contains(
                        OnDeviceModelCapability.functionCalling,
                      ),
                      color: kynos.stand,
                      onTap: () => _toggleFilter(
                        OnDeviceModelCapability.functionCalling,
                      ),
                    ),
                    _FilterChip(
                      label: 'Thinking',
                      isSelected: _activeFilters.contains(
                        OnDeviceModelCapability.thinkingMode,
                      ),
                      color: kynos.move,
                      onTap: () => _toggleFilter(
                        OnDeviceModelCapability.thinkingMode,
                      ),
                    ),
                    _FilterChip(
                      label: 'Vision',
                      isSelected: _activeFilters.contains(
                        OnDeviceModelCapability.vision,
                      ),
                      color: kynos.exercise,
                      onTap: () => _toggleFilter(
                        OnDeviceModelCapability.vision,
                      ),
                    ),
                  ],
                ),
                const Gap(tokens.Spacing.md),
                if (!_hasVisibleModels)
                  Text(
                    'No models match your filters on this device. '
                    'Try clearing a filter or check available RAM.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kynos.secondaryLabel,
                        ),
                  )
                else ...[
                  for (final tier in OnDeviceModelTier.values)
                    ..._buildTierSection(
                      context: context,
                      tier: tier,
                      models: groupedModels[tier] ?? const [],
                      settings: settings,
                    ),
                ],
              ],
            ),
    );
  }

  List<Widget> _buildTierSection({
    required BuildContext context,
    required OnDeviceModelTier tier,
    required List<OnDeviceModel> models,
    required SettingsState settings,
  }) {
    if (models.isEmpty) return const [];

    return [
      const Gap(tokens.Spacing.sm),
      KynosSectionHeader(title: _tierLabel(tier)),
      const Gap(tokens.Spacing.sm),
      ...models.map(
        (model) => OnDeviceModelCard(
          model: model,
          isSelected: settings.selectedLocalModelId == model.id,
          isInstalled: settings.installedLocalModelId == model.id,
          onTap: () => _selectModel(model),
        ),
      ),
    ];
  }

  String _tierLabel(OnDeviceModelTier tier) {
    return switch (tier) {
      OnDeviceModelTier.lightweight => 'Lightweight',
      OnDeviceModelTier.balanced => 'Balanced',
      OnDeviceModelTier.flagship => 'Flagship',
    };
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? color : kynos.secondaryLabel,
          ),
      side: BorderSide(
        color: isSelected ? color : kynos.separator,
      ),
    );
  }
}
