import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/core/theme/theme.dart' hide Radius;

/// User chat bubble — solid accent fill.
class KynosUserBubble extends StatelessWidget {
  const KynosUserBubble({
    super.key,
    required this.text,
  });

  final String text;

  Future<void> _copyMessage(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onLongPress: () => _copyMessage(context),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm + 2,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kynos.stand,
                Color.lerp(kynos.stand, kynos.purple, 0.22)!,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: kynos.stand.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SelectableText(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: KynosColors.onAccent,
                  height: 1.48,
                ),
          ),
        ),
      ),
    );
  }
}
