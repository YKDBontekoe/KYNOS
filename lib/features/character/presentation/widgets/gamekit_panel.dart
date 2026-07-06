import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/repositories/gamekit_repository.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class GameKitPanel extends ConsumerWidget {
  const GameKitPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech_rounded, size: 16, color: AppTheme.energy),
              const Gap(tokens.Spacing.sm),
              Text('GAME CENTER', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Row(
            children: [
              Expanded(
                child: GameKitButton(
                  label: 'Leaderboard',
                  icon: Icons.bar_chart_rounded,
                  onTap: () => ref
                      .read(gameKitRepositoryProvider)
                      .showLeaderboard(
                        leaderboardId: LeaderboardIds.athleteScore,
                      ),
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: GameKitButton(
                  label: 'Achievements',
                  icon: Icons.emoji_events_rounded,
                  onTap: () =>
                      ref.read(gameKitRepositoryProvider).showAchievements(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GameKitButton extends StatelessWidget {
  const GameKitButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppTheme.secondaryLabel),
            const Gap(tokens.Spacing.sm),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.label,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
