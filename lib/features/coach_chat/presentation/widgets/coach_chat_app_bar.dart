import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/conversation_list_sheet.dart';
import 'package:kynos/features/coach_chat/presentation/widgets/inference_settings_sheet.dart';
import 'package:kynos/shared/widgets/liquid_glass_surface.dart';

/// Floating corner actions for Coach — not a top navigation bar.
class CoachChatAppBar extends StatelessWidget {
  const CoachChatAppBar({
    super.key,
    required this.onDeleteThread,
    required this.onExport,
    required this.onNewChat,
  });

  final VoidCallback onDeleteThread;
  final VoidCallback onExport;
  final VoidCallback onNewChat;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.sm,
          Spacing.md,
          0,
        ),
        child: Row(
          children: [
            _OrbButton(
              tooltip: 'Conversations',
              icon: Icons.chat_bubble_outline_rounded,
              onTap: () => showConversationListSheet(context),
            ),
            const Spacer(),
            _OrbButton(
              tooltip: 'Model & mode',
              icon: Icons.auto_awesome_rounded,
              onTap: () => showInferenceSettingsSheet(
                context,
                onExport: onExport,
                onDeleteThread: onDeleteThread,
              ),
            ),
            const Gap(Spacing.sm),
            _OrbButton(
              tooltip: 'New conversation',
              icon: Icons.edit_outlined,
              onTap: onNewChat,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbButton extends StatelessWidget {
  const _OrbButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: kynos.card.withValues(alpha: 0),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: kynos.cardShadow,
                ),
                child: LiquidGlassSurface(
                  borderRadius: Radius.full,
                  blurSigma: LiquidGlassTokens.buttonBlurSigma,
                  border: Border.all(
                    color: LiquidGlassTokens.borderColor(
                      Theme.of(context).brightness,
                    ),
                  ),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(icon, size: 18, color: kynos.label),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
