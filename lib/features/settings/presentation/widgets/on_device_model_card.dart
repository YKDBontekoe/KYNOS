import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/on_device_model.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';

class OnDeviceModelCard extends StatelessWidget {
  const OnDeviceModelCard({
    super.key,
    required this.model,
    required this.onTap,
    this.isSelected = false,
    this.isInstalled = false,
  });

  final OnDeviceModel model;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isInstalled;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: tokens.Spacing.sm),
      child: KynosCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    model.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: kynos.stand, size: 20),
              ],
            ),
            const Gap(tokens.Spacing.xs),
            Text(
              model.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kynos.secondaryLabel,
                  ),
            ),
            const Gap(tokens.Spacing.xs),
            Text(
              model.bestFor,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kynos.tertiaryLabel,
                  ),
            ),
            const Gap(tokens.Spacing.sm),
            Wrap(
              spacing: tokens.Spacing.xs,
              runSpacing: tokens.Spacing.xs,
              children: [
                KynosChip.metric(
                  label: 'Size',
                  value: _formatSize(model.sizeMb),
                ),
                KynosChip.metric(
                  label: 'Min RAM',
                  value: '${model.minRamGb} GB',
                ),
                KynosChip.accent(
                  label: _familyLabel(model.family),
                  color: kynos.purple,
                ),
                ...model.capabilities.map(
                  (capability) => KynosChip.accent(
                    label: _capabilityLabel(capability),
                    color: _capabilityColor(capability, kynos),
                  ),
                ),
                if (model.requiresHuggingFaceToken)
                  KynosChip.accent(label: 'HF token', color: kynos.move)
                else
                  KynosChip.accent(label: 'Public', color: kynos.exercise),
                if (isInstalled)
                  KynosChip.accent(label: 'Installed', color: kynos.stand),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatSize(int sizeMb) {
    if (sizeMb >= 1000) {
      return '${(sizeMb / 1000).toStringAsFixed(1)} GB';
    }
    return '$sizeMb MB';
  }

  String _familyLabel(OnDeviceModelFamily family) {
    return switch (family) {
      OnDeviceModelFamily.gemma4 => 'Gemma 4',
      OnDeviceModelFamily.gemma3 => 'Gemma 3',
      OnDeviceModelFamily.gemma3n => 'Gemma3n',
      OnDeviceModelFamily.qwen3 => 'Qwen3',
      OnDeviceModelFamily.qwen2 => 'Qwen 2.5',
      OnDeviceModelFamily.phi => 'Phi-4',
      OnDeviceModelFamily.functionGemma => 'FunctionGemma',
    };
  }

  String _capabilityLabel(OnDeviceModelCapability capability) {
    return switch (capability) {
      OnDeviceModelCapability.functionCalling => 'Tools',
      OnDeviceModelCapability.thinkingMode => 'Thinking',
      OnDeviceModelCapability.vision => 'Vision',
      OnDeviceModelCapability.audio => 'Audio',
      OnDeviceModelCapability.multilingual => 'Multilingual',
    };
  }

  Color _capabilityColor(
    OnDeviceModelCapability capability,
    KynosThemeExtension kynos,
  ) {
    return switch (capability) {
      OnDeviceModelCapability.functionCalling => kynos.stand,
      OnDeviceModelCapability.thinkingMode => kynos.move,
      OnDeviceModelCapability.vision => kynos.exercise,
      OnDeviceModelCapability.audio => kynos.purple,
      OnDeviceModelCapability.multilingual => kynos.secondaryLabel,
    };
  }
}
