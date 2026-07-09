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
              child: Material(
                color: kynos.stand.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Radius.md),
                child: ListTile(
                  dense: true,
                  title: const Text('Cloud coach not configured'),
                  subtitle: const Text('Add OpenRouter key and model in Settings'),
                  trailing: TextButton(
                    onPressed: () => context.push(Routes.settings),
                    child: const Text('Settings'),
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<CoachBackendMode>(
                  segments: CoachBackendMode.values
                      .map(
                        (mode) => ButtonSegment(
                          value: mode,
                          label: Text(mode.label, style: const TextStyle(fontSize: 12)),
                        ),
                      )
                      .toList(),
                  selected: {settings.backendMode},
                  onSelectionChanged: (selection) async {
                    final mode = selection.first;
                    await ref.read(coachChatProvider.notifier).updateSettings(
                          settings.copyWith(backendMode: mode),
                        );
                  },
                ),
              ),
              const Gap(Spacing.sm),
              InkWell(
                onTap: () => showInferenceSettingsSheet(context),
                borderRadius: BorderRadius.circular(Radius.md),
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
