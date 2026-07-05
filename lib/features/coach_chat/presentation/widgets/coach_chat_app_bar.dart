import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/theme.dart';

class CoachChatAppBar extends StatelessWidget {
  const CoachChatAppBar({super.key, required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.xs, Spacing.md, Spacing.sm),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppTheme.exercise, shape: BoxShape.circle),
            ),
            const Gap(Spacing.sm),
            Text(
              'KYNOS Coach',
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.label),
            ),
            const Spacer(),
            const OnDeviceBadge(),
            const Gap(Spacing.sm),
            GestureDetector(
              onTap: onClear,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppTheme.separator, borderRadius: BorderRadius.circular(Radius.md)),
                child: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.secondaryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnDeviceBadge extends StatelessWidget {
  const OnDeviceBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kynos.exercise.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 11, color: kynos.exercise),
          const Gap(Spacing.xs),
          Text(
            'On-Device',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: kynos.exercise,
                ),
          ),
        ],
      ),
    );
  }
}
