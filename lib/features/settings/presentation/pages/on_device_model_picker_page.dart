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
  List<OnDeviceModel>? _models;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    final ramBytes = await GemmaDeviceRamProbe.totalRamBytes();
    if (!mounted) return;
    setState(() {
      _models = OnDeviceModelCatalog.forDevice(
        isWeb: kIsWeb,
        totalRamBytes: ramBytes,
      );
      _loading = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final kynos = context.kynosTheme;

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
                  'Smaller models use less memory but may give shorter answers.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: kynos.secondaryLabel,
                      ),
                ),
                const Gap(tokens.Spacing.md),
                const KynosSectionHeader(title: 'Available models'),
                const Gap(tokens.Spacing.sm),
                ...?_models?.map(
                  (model) => OnDeviceModelCard(
                    model: model,
                    isSelected: settings.selectedLocalModelId == model.id,
                    isInstalled: settings.installedLocalModelId == model.id,
                    onTap: () => _selectModel(model),
                  ),
                ),
              ],
            ),
    );
  }
}
