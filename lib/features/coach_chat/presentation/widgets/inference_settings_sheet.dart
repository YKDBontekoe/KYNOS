import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/shared/providers/settings_provider.dart';

void showInferenceSettingsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.kynosTheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.Radius.lg)),
    ),
    builder: (context) => const InferenceSettingsSheet(),
  );
}

class InferenceSettingsSheet extends ConsumerWidget {
  const InferenceSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final settings = conversation?.settings ?? CoachConversationSettings.defaults;
    final globalSettings = ref.watch(settingsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        MediaQuery.paddingOf(context).bottom + Spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Inference settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(Spacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('On-device model'),
            subtitle: Text(globalSettings.selectedLocalModelName),
            trailing: TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(Routes.onDeviceModels);
              },
              child: const Text('Change'),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Cloud model (this chat)'),
            subtitle: Text(
              settings.preferredCloudModelId != null
                  ? (globalSettings.selectedCloudModelName ?? 'Override set')
                  : 'Uses global default',
            ),
            trailing: TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(Routes.openRouterModels);
              },
              child: const Text('Pick'),
            ),
          ),
          if (globalSettings.selectedCloudModelId != null)
            TextButton(
              onPressed: () async {
                await ref.read(coachChatProvider.notifier).updateSettings(
                      settings.copyWith(
                        preferredCloudModelId: globalSettings.selectedCloudModelId,
                      ),
                    );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Use global cloud model for this chat'),
            ),
          if (settings.preferredCloudModelId != null)
            TextButton(
              onPressed: () async {
                await ref.read(coachChatProvider.notifier).updateSettings(
                      settings.copyWith(clearPreferredCloudModelId: true),
                    );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Clear per-chat cloud override'),
            ),
        ],
      ),
    );
  }
}
