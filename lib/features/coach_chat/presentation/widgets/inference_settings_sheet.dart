import 'package:flutter/material.dart';
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
import 'package:kynos/features/coach_chat/presentation/widgets/inference_settings_rows.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/features/coach_chat/providers/coach_chat_provider.dart';
import 'package:kynos/shared/providers/openrouter_api_key_provider.dart';
import 'package:kynos/shared/providers/settings_provider.dart';
import 'package:kynos/shared/widgets/kynos_segmented_control.dart';
import 'package:kynos/shared/widgets/show_shell_modal_sheet.dart';

void showInferenceSettingsSheet(
  BuildContext context, {
  VoidCallback? onExport,
  VoidCallback? onDeleteThread,
}) {
  showShellModalBottomSheet<void>(
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
    if (mode == CoachBackendMode.cloud) {
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
        return;
      }
    }

    await ref.read(coachChatProvider.notifier).updateSettings(
          settings.copyWith(backendMode: mode),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final settings =
        conversation?.settings ?? CoachConversationSettings.defaults;
    final globalSettings = ref.watch(settingsProvider);
    final kynos = context.kynosTheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.sm,
          Spacing.md,
          bottomInset + Spacing.md,
        ),
        child: SingleChildScrollView(
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
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Gap(Spacing.xs),
              Text(
                'Choose how this chat routes coaching replies.',
                style: textTheme.bodyMedium?.copyWith(
                  color: kynos.secondaryLabel,
                ),
              ),
              const Gap(Spacing.lg),
              InferenceSheetGroup(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.sm,
                      Spacing.sm,
                      Spacing.sm,
                      Spacing.xs,
                    ),
                    child: KynosSegmentedControl<CoachBackendMode>(
                      segments: CoachBackendMode.values,
                      selected: settings.backendMode,
                      labelBuilder: (mode) => mode.label,
                      onChanged: (mode) =>
                          _selectMode(context, ref, settings, mode),
                    ),
                  ),
                  InferenceModelRow(
                    title: 'On-device model',
                    subtitle: globalSettings.selectedLocalModelName,
                    actionLabel: 'Change',
                    onAction: () {
                      Navigator.pop(context);
                      context.push(Routes.onDeviceModels);
                    },
                  ),
                  const InferenceSheetDivider(),
                  InferenceModelRow(
                    title: 'Cloud model',
                    subtitle: settings.preferredCloudModelId != null
                        ? 'Override: ${settings.preferredCloudModelId}'
                        : (globalSettings.selectedCloudModelName ??
                            'Uses global default'),
                    actionLabel: 'Pick',
                    onAction: () {
                      Navigator.pop(context);
                      context.push(Routes.openRouterModels);
                    },
                  ),
                  if (settings.preferredCloudModelId != null) ...[
                    const InferenceSheetDivider(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () async {
                          await ref
                              .read(coachChatProvider.notifier)
                              .updateSettings(
                                settings.copyWith(
                                  clearPreferredCloudModelId: true,
                                ),
                              );
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text(
                          'Use global cloud model for this chat',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(Spacing.md),
              InferenceSheetGroup(
                children: [
                  InferenceActionRow(
                    icon: Icons.hub_outlined,
                    title: 'Context sources',
                    onTap: () {
                      Navigator.pop(context);
                      showContextInspectorSheet(context);
                    },
                  ),
                  const InferenceSheetDivider(),
                  InferenceActionRow(
                    icon: Icons.directions_run_rounded,
                    title: 'Attach focus run',
                    onTap: () {
                      Navigator.pop(context);
                      showFocusRunPickerSheet(context, ref);
                    },
                  ),
                  if (onExport != null) ...[
                    const InferenceSheetDivider(),
                    InferenceActionRow(
                      icon: Icons.ios_share_rounded,
                      title: 'Export chat',
                      onTap: () {
                        Navigator.pop(context);
                        onExport!();
                      },
                    ),
                  ],
                  if (onDeleteThread != null) ...[
                    const InferenceSheetDivider(),
                    InferenceActionRow(
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete thread',
                      foreground: kynos.move,
                      onTap: () {
                        Navigator.pop(context);
                        onDeleteThread!();
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
