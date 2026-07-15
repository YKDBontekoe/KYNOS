import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart' hide Radius;
import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/context_inspector_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/focus_run_picker_sheet.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/shared/providers/openrouter_api_key_provider.dart';
import 'package:kynos/shared/providers/settings_provider.dart';
import 'package:kynos/shared/widgets/kynos_segmented_control.dart';

void showInferenceSettingsSheet(
  BuildContext context, {
  VoidCallback? onExport,
  VoidCallback? onDeleteThread,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.kynosTheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(tokens.Radius.xl),
      ),
    ),
    builder: (context) => InferenceSettingsSheet(
      onExport: onExport,
      onDeleteThread: onDeleteThread,
    ),
  );
}

class InferenceSettingsSheet extends ConsumerWidget {
  const InferenceSettingsSheet({
    super.key,
    this.onExport,
    this.onDeleteThread,
  });

  final VoidCallback? onExport;
  final VoidCallback? onDeleteThread;

  Future<void> _selectMode(
    BuildContext context,
    WidgetRef ref,
    CoachConversationSettings settings,
    CoachBackendMode mode,
  ) async {
    await HapticFeedback.selectionClick();
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
      Navigator.pop(context);
      await context.push(Routes.settings);
      return;
    }
    if (!hasModel) {
      Navigator.pop(context);
      await context.push(Routes.openRouterModels);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final settings =
        conversation?.settings ?? CoachConversationSettings.defaults;
    final globalSettings = ref.watch(settingsProvider);
    final kynos = context.kynosTheme;

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
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kynos.separator,
                borderRadius: BorderRadius.circular(tokens.Radius.full),
              ),
            ),
          ),
          const Gap(Spacing.md),
          Text(
            'Model & mode',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
          ),
          const Gap(Spacing.xs),
          Text(
            'Choose how this chat routes coaching replies.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kynos.secondaryLabel,
                ),
          ),
          const Gap(Spacing.md),
          KynosSegmentedControl<CoachBackendMode>(
            segments: CoachBackendMode.values,
            selected: settings.backendMode,
            labelBuilder: (mode) => mode.label,
            onChanged: (mode) => _selectMode(context, ref, settings, mode),
          ),
          const Gap(Spacing.lg),
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
            title: const Text('Cloud model'),
            subtitle: Text(
              settings.preferredCloudModelId != null
                  ? (globalSettings.selectedCloudModelName ?? 'Override set')
                  : (globalSettings.selectedCloudModelName ??
                      'Uses global default'),
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
                        preferredCloudModelId:
                            globalSettings.selectedCloudModelId,
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
          const Gap(Spacing.sm),
          Divider(color: kynos.separator.withValues(alpha: 0.6)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.hub_outlined, color: kynos.secondaryLabel),
            title: const Text('Context sources'),
            onTap: () {
              Navigator.pop(context);
              showContextInspectorSheet(context);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.directions_run_rounded, color: kynos.secondaryLabel),
            title: const Text('Attach focus run'),
            onTap: () {
              Navigator.pop(context);
              showFocusRunPickerSheet(context, ref);
            },
          ),
          if (onExport != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.ios_share_rounded, color: kynos.secondaryLabel),
              title: const Text('Export chat'),
              onTap: () {
                Navigator.pop(context);
                onExport!();
              },
            ),
          if (onDeleteThread != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline_rounded, color: kynos.move),
              title: Text(
                'Delete thread',
                style: TextStyle(color: kynos.move),
              ),
              onTap: () {
                Navigator.pop(context);
                onDeleteThread!();
              },
            ),
        ],
      ),
    );
  }
}
