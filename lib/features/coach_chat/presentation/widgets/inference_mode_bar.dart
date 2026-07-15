import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/inference_settings_sheet.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/settings_provider.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_segmented_control.dart';

class InferenceModeBar extends ConsumerWidget {
  const InferenceModeBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final settings = conversation?.settings ?? CoachConversationSettings.defaults;
    final globalSettings = ref.watch(settingsProvider);
    final cloudConfigured = ref.watch(isCloudCoachConfiguredProvider).value ?? false;

    final modelLabel = switch (settings.backendMode) {
      CoachBackendMode.cloud =>
        settings.preferredCloudModelId != null
            ? globalSettings.selectedCloudModelName ?? 'Cloud model'
            : globalSettings.selectedCloudModelName ?? 'Cloud',
      CoachBackendMode.onDevice => globalSettings.selectedLocalModelName,
      CoachBackendMode.auto => cloudConfigured ? 'Auto' : 'On-Device',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (settings.backendMode == CoachBackendMode.cloud && !cloudConfigured)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: kynos.stand.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(Radius.lg),
                  border: Border.all(
                    color: kynos.stand.withValues(alpha: 0.16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.sm,
                    Spacing.sm,
                    Spacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 18,
                        color: kynos.stand,
                      ),
                      const Gap(Spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cloud coach not configured',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Add an OpenRouter key and model in Settings',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(Routes.settings),
                        child: const Text('Settings'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: KynosSegmentedControl<CoachBackendMode>(
                  segments: CoachBackendMode.values,
                  selected: settings.backendMode,
                  labelBuilder: (mode) => mode.label,
                  onChanged: (mode) async {
                    await ref.read(coachChatProvider.notifier).updateSettings(
                          settings.copyWith(backendMode: mode),
                        );
                  },
                ),
              ),
              const Gap(Spacing.sm),
              InkWell(
                onTap: () => showInferenceSettingsSheet(context),
                borderRadius: BorderRadius.circular(Radius.sm),
                child: KynosChip.accent(
                  label: modelLabel,
                  color: kynos.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
