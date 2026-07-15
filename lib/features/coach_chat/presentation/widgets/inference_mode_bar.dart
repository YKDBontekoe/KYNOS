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
import 'package:kynos/shared/providers/openrouter_api_key_provider.dart';
import 'package:kynos/shared/providers/settings_provider.dart';
import 'package:kynos/shared/widgets/kynos_chip.dart';
import 'package:kynos/shared/widgets/kynos_segmented_control.dart';

class InferenceModeBar extends ConsumerWidget {
  const InferenceModeBar({super.key});

  Future<void> _selectMode(
    BuildContext context,
    WidgetRef ref,
    CoachConversationSettings settings,
    CoachBackendMode mode,
  ) async {
    await ref.read(coachChatProvider.notifier).updateSettings(
          settings.copyWith(backendMode: mode),
        );

    if (mode != CoachBackendMode.cloud || !context.mounted) return;

    final global = ref.read(settingsProvider);
    if (!global.cloudTasksEnabled) {
      await ref.read(settingsProvider.notifier).updateCloudTasksEnabled(true);
    }

    final apiKey = await ref.read(openRouterApiKeyManagerProvider.future);
    final hasKey = apiKey != null && apiKey.isNotEmpty;
    final hasModel = ref.read(settingsProvider).hasSelectedCloudModel;

    if (!context.mounted) return;
    if (!hasKey) {
      await context.push(Routes.settings);
      return;
    }
    if (!hasModel) {
      await context.push(Routes.openRouterModels);
    }
  }

  String _missingCloudStep(
    SettingsState settings,
    bool hasKey,
  ) {
    if (!settings.cloudTasksEnabled) {
      return 'Turn on OpenRouter fallback in Settings, then pick a model.';
    }
    if (!hasKey) return 'Add your OpenRouter API key in Settings to continue.';
    if (!settings.hasSelectedCloudModel) {
      return 'Choose a cloud model to finish setup.';
    }
    return 'Add an OpenRouter key and model in Settings.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final settings =
        conversation?.settings ?? CoachConversationSettings.defaults;
    final globalSettings = ref.watch(settingsProvider);
    final cloudConfigured =
        ref.watch(isCloudCoachConfiguredProvider).value ?? false;
    final hasKey =
        (ref.watch(openRouterApiKeyManagerProvider).value ?? '').isNotEmpty;

    final modelLabel = switch (settings.backendMode) {
      CoachBackendMode.cloud =>
        settings.preferredCloudModelId != null
            ? globalSettings.selectedCloudModelName ?? 'Cloud model'
            : globalSettings.selectedCloudModelName ?? 'Cloud',
      CoachBackendMode.onDevice => globalSettings.selectedLocalModelName,
      CoachBackendMode.auto => globalSettings.selectedLocalModelName,
    };

    final missingStep = _missingCloudStep(globalSettings, hasKey);
    final setupCtaLabel = !hasKey
        ? 'Add key'
        : !globalSettings.hasSelectedCloudModel
            ? 'Pick model'
            : 'Settings';

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
                              'Finish cloud setup',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              missingStep,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (!hasKey) {
                            context.push(Routes.settings);
                          } else if (!globalSettings.hasSelectedCloudModel) {
                            context.push(Routes.openRouterModels);
                          } else {
                            context.push(Routes.settings);
                          }
                        },
                        child: Text(setupCtaLabel),
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
                  onChanged: (mode) =>
                      _selectMode(context, ref, settings, mode),
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
