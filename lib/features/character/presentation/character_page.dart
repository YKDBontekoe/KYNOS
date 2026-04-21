import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/gamification/character_class.dart';
import 'package:kynos/domain/entities/gamification/character_stats.dart';
import 'package:kynos/domain/entities/gamification/earned_title.dart';
import 'package:kynos/domain/entities/gamification/quest.dart';
import 'package:kynos/domain/entities/gamification/runner_character.dart';
import 'package:kynos/features/character/providers/character_provider.dart';
import 'package:kynos/features/character/providers/quest_provider.dart';
import 'package:kynos/shared/providers/gamification_providers.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class CharacterPage extends ConsumerWidget {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(runnerCharacterProvider);
    final questsAsync = ref.watch(dailyQuestsProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          backgroundColor: AppTheme.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          toolbarHeight: 56,
          titleSpacing: 20,
          title: Text(
            'CHARACTER',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.tertiaryLabel,
              letterSpacing: 0.8,
            ),
          ),
        ),
        characterAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.stand),
            ),
          ),
          error: (_, _2) => SliverFillRemaining(
            child: Center(
              child: Text(
                'Could not load character',
                style: GoogleFonts.inter(color: AppTheme.secondaryLabel),
              ),
            ),
          ),
          data: (character) {
            if (character == null) {
              return SliverFillRemaining(
                child: _EmptyCharacterState(ref: ref),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                tokens.Spacing.md,
                0,
                tokens.Spacing.md,
                100,
              ),
              sliver: SliverList.list(
                children: [
                  _ClassHeroCard(character: character),
                  const Gap(tokens.Spacing.md),
                  _XpBar(character: character),
                  const Gap(tokens.Spacing.lg),
                  _SectionLabel(label: 'STATS'),
                  const Gap(tokens.Spacing.sm),
                  _StatsPanel(character: character),
                  const Gap(tokens.Spacing.lg),
                  _SectionLabel(label: "TODAY'S QUEST"),
                  const Gap(tokens.Spacing.sm),
                  _QuestPanel(questsAsync: questsAsync),
                  const Gap(tokens.Spacing.lg),
                  if (character.earnedTitles.isNotEmpty) ...[
                    _SectionLabel(label: 'TITLES'),
                    const Gap(tokens.Spacing.sm),
                    _TitlesPanel(titles: character.earnedTitles),
                    const Gap(tokens.Spacing.lg),
                  ],
                  const _GameKitPanel(),
                  const Gap(tokens.Spacing.lg),
                  _SignatoryPowerCard(characterClass: character.characterClass),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Class hero card ────────────────────────────────────────────────────────────

class _ClassHeroCard extends StatelessWidget {
  const _ClassHeroCard({required this.character});

  final RunnerCharacter character;

  @override
  Widget build(BuildContext context) {
    final klass = character.characterClass;
    final classColor = Color(klass.colorValue);

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: classColor,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Background orbs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'LV ${character.level}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Gap(8),
                    if (character.activeTitle != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '"${character.activeTitle}"',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.90),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  klass.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                const Gap(4),
                Text(
                  klass.epithet,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── XP progress bar ────────────────────────────────────────────────────────────

class _XpBar extends StatelessWidget {
  const _XpBar({required this.character});

  final RunnerCharacter character;

  @override
  Widget build(BuildContext context) {
    final classColor = Color(character.characterClass.colorValue);
    final progress = character.levelProgress;

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXPERIENCE',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                '${character.xpToNextLevel} XP to Level ${character.level + 1}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.tertiaryLabel,
                ),
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppTheme.separator,
                  valueColor: AlwaysStoppedAnimation(classColor),
                );
              },
            ),
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            '${character.xp} XP total',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats panel ────────────────────────────────────────────────────────────────

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.character});

  final RunnerCharacter character;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        children: [
          for (final stat in CharacterStatId.values) ...[
            _StatRow(
              stat: stat,
              value: character.stats[stat],
            ),
            if (stat != CharacterStatId.values.last)
              const Gap(tokens.Spacing.sm),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stat, required this.value});

  final CharacterStatId stat;
  final int value;

  @override
  Widget build(BuildContext context) {
    final pct = value / 100.0;

    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            stat.label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: stat.color,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const Gap(tokens.Spacing.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (context, val, _) {
                return LinearProgressIndicator(
                  value: val,
                  minHeight: 6,
                  backgroundColor: AppTheme.separator,
                  valueColor: AlwaysStoppedAnimation(stat.color),
                );
              },
            ),
          ),
        ),
        const Gap(tokens.Spacing.sm),
        SizedBox(
          width: 30,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.label,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quest panel ────────────────────────────────────────────────────────────────

class _QuestPanel extends StatelessWidget {
  const _QuestPanel({required this.questsAsync});

  final AsyncValue<List<Quest>> questsAsync;

  @override
  Widget build(BuildContext context) {
    return questsAsync.when(
      loading: () => const KynosCard(
        child: _LoadingLine(label: 'Generating quest...'),
      ),
      error: (_, _2) => const SizedBox.shrink(),
      data: (quests) {
        if (quests.isEmpty) {
          return KynosCard(
            child: Text(
              'No quest today. Check back tomorrow.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.secondaryLabel,
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final quest in quests)
              _QuestCard(quest: quest),
          ],
        );
      },
    );
  }
}

class _QuestCard extends ConsumerWidget {
  const _QuestCard({required this.quest});

  final Quest quest;

  Color _difficultyColor(QuestDifficulty d) => switch (d) {
        QuestDifficulty.easy => AppTheme.exercise,
        QuestDifficulty.normal => AppTheme.stand,
        QuestDifficulty.hard => AppTheme.energy,
        QuestDifficulty.legendary => AppTheme.move,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = quest.status == QuestStatus.completed;
    final diffColor = _difficultyColor(quest.difficulty);

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  quest.type.label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: diffColor,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.separator,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  quest.difficulty.label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryLabel,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              if (isCompleted)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppTheme.exercise,
                ),
            ],
          ),
          const Gap(tokens.Spacing.sm),

          // Title
          Text(
            quest.title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isCompleted ? AppTheme.secondaryLabel : AppTheme.label,
              letterSpacing: -0.2,
            ),
          ),
          const Gap(tokens.Spacing.xs),

          // Narrative
          Text(
            '"${quest.narrative}"',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.secondaryLabel,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const Gap(tokens.Spacing.sm),
          const Divider(height: 1),
          const Gap(tokens.Spacing.sm),

          // Objective
          Text(
            quest.objective,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.label,
              height: 1.4,
            ),
          ),
          const Gap(tokens.Spacing.sm),

          // Rewards row
          Row(
            children: [
              _RewardChip(
                label: '+${quest.xpReward} XP',
                color: AppTheme.purple,
              ),
              const Gap(tokens.Spacing.xs),
              for (final entry in quest.statRewards.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _RewardChip(
                    label: '+${entry.value} ${entry.key.label}',
                    color: entry.key.color,
                  ),
                ),
              const Spacer(),
              if (!isCompleted)
                GestureDetector(
                  onTap: () => ref
                      .read(questNotifierProvider.notifier)
                      .completeQuest(quest.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.label,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Complete',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Titles panel ───────────────────────────────────────────────────────────────

class _TitlesPanel extends StatelessWidget {
  const _TitlesPanel({required this.titles});

  final List<EarnedTitle> titles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final title in titles)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.separator,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 14,
                  color: AppTheme.energy,
                ),
                const Gap(6),
                Text(
                  title.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.label,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Signatory power card ───────────────────────────────────────────────────────

class _SignatoryPowerCard extends StatelessWidget {
  const _SignatoryPowerCard({required this.characterClass});

  final CharacterClass characterClass;

  @override
  Widget build(BuildContext context) {
    final classColor = Color(characterClass.colorValue);

    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: classColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(18, 18),
                    painter: _ShieldPainter(color: classColor),
                  ),
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIGNATORY POWER',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    characterClass.signatoryPower,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: classColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(tokens.Spacing.sm),
          Text(
            characterClass.powerDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ── GameKit panel ──────────────────────────────────────────────────────────────

class _GameKitPanel extends ConsumerWidget {
  const _GameKitPanel();

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
                child: _GameKitButton(
                  label: 'Leaderboard',
                  icon: Icons.bar_chart_rounded,
                  onTap: () => ref
                      .read(gameKitRepositoryProvider)
                      .showLeaderboard(
                        leaderboardId: 'kynos.leaderboard.athlete_score',
                      ),
                ),
              ),
              const Gap(tokens.Spacing.sm),
              Expanded(
                child: _GameKitButton(
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

class _GameKitButton extends StatelessWidget {
  const _GameKitButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            const Gap(6),
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
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyCharacterState extends StatelessWidget {
  const _EmptyCharacterState({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(tokens.Spacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CHARACTER NOT ASSIGNED',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.tertiaryLabel,
              letterSpacing: 0.8,
            ),
          ),
          const Gap(tokens.Spacing.sm),
          Text(
            'Connect HealthKit and log a few runs to unlock your class assignment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.secondaryLabel,
              height: 1.4,
            ),
          ),
          const Gap(tokens.Spacing.lg),
          FilledButton(
            onPressed: () => ref.invalidate(runnerCharacterProvider),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.secondaryLabel,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Loading line ───────────────────────────────────────────────────────────────

class _LoadingLine extends StatelessWidget {
  const _LoadingLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppTheme.tertiaryLabel,
          ),
        ),
        const Gap(tokens.Spacing.sm),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.tertiaryLabel,
          ),
        ),
      ],
    );
  }
}

// ── Shield icon painter ────────────────────────────────────────────────────────

class _ShieldPainter extends CustomPainter {
  const _ShieldPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(12, 22)
      ..cubicTo(12, 22, 4, 18, 4, 12)
      ..lineTo(4, 6)
      ..lineTo(12, 2)
      ..lineTo(20, 6)
      ..lineTo(20, 12)
      ..cubicTo(20, 18, 12, 22, 12, 22)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => old.color != color;
}

