import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/domain/entities/gamification/adventure_session.dart';
import 'package:kynos/domain/entities/gamification/trail_node.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';

class TrailMap extends StatelessWidget {
  const TrailMap({
    super.key,
    required this.session,
    required this.canAdvance,
    required this.onAdvance,
  });

  final AdventureSession session;
  final bool canAdvance;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRAIL RUN',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.tertiaryLabel,
              letterSpacing: 0.8,
            ),
          ),
          const Gap(tokens.Spacing.md),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: session.nodes.length,
              separatorBuilder: (_, _) => const Gap(tokens.Spacing.xs),
              itemBuilder: (context, index) {
                final node = session.nodes[index];
                final isCurrent = index == session.currentIndex;
                final isPast = index < session.currentIndex;
                return _TrailNodeDot(
                  node: node,
                  isCurrent: isCurrent,
                  isPast: isPast,
                );
              },
            ),
          ),
          const Gap(tokens.Spacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  _statusLabel(session),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.secondaryLabel,
                  ),
                ),
              ),
              FilledButton(
                onPressed: canAdvance ? onAdvance : null,
                child: const Text('Advance'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(AdventureSession session) {
    if (session.trailCompleted) return 'Trail complete for today.';
    final node = session.currentNode;
    if (node == null) return 'Ready to run the trail.';
    return 'Node ${node.index + 1}/${session.nodes.length} · ${node.type.label}';
  }
}

class _TrailNodeDot extends StatelessWidget {
  const _TrailNodeDot({
    required this.node,
    required this.isCurrent,
    required this.isPast,
  });

  final TrailNode node;
  final bool isCurrent;
  final bool isPast;

  Color _color(BuildContext context) {
    final kynos = context.kynosTheme;
    if (isCurrent) return kynos.purple;
    if (isPast || node.resolved) return AppTheme.exercise;
    return switch (node.type) {
      TrailNodeType.boss => AppTheme.energy,
      TrailNodeType.treasure => AppTheme.move,
      TrailNodeType.rest => AppTheme.stand,
      TrailNodeType.encounter => AppTheme.energy,
      TrailNodeType.start => AppTheme.secondaryLabel,
    };
  }

  IconData _icon() => switch (node.type) {
        TrailNodeType.start => Icons.flag_outlined,
        TrailNodeType.encounter => Icons.flash_on_rounded,
        TrailNodeType.rest => Icons.self_improvement_outlined,
        TrailNodeType.treasure => Icons.inventory_2_outlined,
        TrailNodeType.boss => Icons.whatshot_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: isCurrent ? 0.2 : 0.1),
            border: Border.all(
              color: color,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Icon(_icon(), size: 20, color: color),
        ),
        const Gap(tokens.Spacing.xs),
        Text(
          node.type.label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppTheme.tertiaryLabel,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
