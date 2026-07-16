import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/openrouter_api_key_provider.dart';
import 'package:kynos/shared/providers/settings_provider.dart';

/// Slim cloud-setup notice only — mode switching lives in the header sheet.
class InferenceModeBar extends ConsumerWidget {
  const InferenceModeBar({super.key});

  String _missingCloudStep(SettingsState settings, bool hasKey) {
    if (!settings.cloudTasksEnabled) {
      return 'Turn on cloud coaching in Settings, then pick a model.';
    }
    if (!hasKey) return 'Add your cloud API key in Settings to continue.';
    if (!settings.hasSelectedCloudModel) {
      return 'Choose a cloud model to finish setup.';
    }
    return 'Add a cloud API key, base URL, and model in Settings.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kynos = context.kynosTheme;
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final settings =
        conversation?.settings ?? CoachConversationSettings.defaults;
    final globalSettings = ref.watch(settingsProvider);
    final cloudConfiguredAsync = ref.watch(isCloudCoachConfiguredProvider);
    final hasKey =
        (ref.watch(openRouterApiKeyManagerProvider).value ?? '').isNotEmpty;

    // Avoid a transient banner while the cloud gate is still resolving.
    if (settings.backendMode != CoachBackendMode.cloud ||
        cloudConfiguredAsync.isLoading ||
        (cloudConfiguredAsync.value ?? false)) {
      return const SizedBox.shrink();
    }

    final missingStep = _missingCloudStep(globalSettings, hasKey);
    final setupCtaLabel = !hasKey
        ? 'Add key'
        : !globalSettings.hasSelectedCloudModel
            ? 'Pick model'
            : 'Settings';

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
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
    );
  }
}
