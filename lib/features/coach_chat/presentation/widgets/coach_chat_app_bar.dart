import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/coach/coach_backend_mode.dart';
import 'package:kynos/domain/entities/coach/coach_conversation_settings.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/conversation_list_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/inference_settings_sheet.dart';
import 'package:kynos/features/coach_chat/providers/active_coach_conversation_provider.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/settings_provider.dart';

/// Minimal coach chrome — one thin centered row, ChatGPT / Claude style.
class CoachChatAppBar extends ConsumerWidget {
  const CoachChatAppBar({
    super.key,
    required this.onDeleteThread,
    required this.onExport,
    required this.onNewChat,
  });

  final VoidCallback onDeleteThread;
  final VoidCallback onExport;
  final VoidCallback onNewChat;

  String _modeSummary(
    CoachConversationSettings settings,
    SettingsState global,
  ) {
    final mode = settings.backendMode.label;
    final model = switch (settings.backendMode) {
      CoachBackendMode.cloud =>
        global.selectedCloudModelName ?? 'Cloud model',
      CoachBackendMode.onDevice ||
      CoachBackendMode.auto =>
        global.selectedLocalModelName,
    };
    final shortModel = model.contains(':')
        ? model.split(':').last.trim()
        : model;
    final clipped = shortModel.length > 22
        ? '${shortModel.substring(0, 20)}…'
        : shortModel;
    return '$mode · $clipped';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = ref.watch(activeCoachConversationProvider).value;
    final kynos = context.kynosTheme;
    final global = ref.watch(settingsProvider);
    final settings =
        conversation?.settings ?? CoachConversationSettings.defaults;
    final title = conversation?.title ?? 'Coach';
    final summary = _modeSummary(settings, global);
    final cloudMissing = settings.backendMode == CoachBackendMode.cloud &&
        !(ref.watch(isCloudCoachConfiguredProvider).value ?? false);

    return ColoredBox(
      color: kynos.background,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Conversations',
                  onPressed: () => showConversationListSheet(context),
                  icon: Icon(Icons.menu_rounded, color: kynos.label),
                ),
                Expanded(
                  child: _TitleModeControl(
                    title: title,
                    summary: summary,
                    warning: cloudMissing,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      showInferenceSettingsSheet(
                        context,
                        onExport: onExport,
                        onDeleteThread: onDeleteThread,
                      );
                    },
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'New conversation',
                  onPressed: onNewChat,
                  icon: Icon(Icons.edit_square, color: kynos.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleModeControl extends StatelessWidget {
  const _TitleModeControl({
    required this.title,
    required this.summary,
    required this.warning,
    required this.onTap,
  });

  final String title;
  final String summary;
  final bool warning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: '$title, $summary. Change model and mode',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  height: 1.05,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: warning ? kynos.stand : kynos.tertiaryLabel,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: warning ? kynos.stand : kynos.tertiaryLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
