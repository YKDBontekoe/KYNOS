import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/shared/widgets/metric_tile.dart';

// ── Root ──────────────────────────────────────────────────────────────────

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => const _Shell();
}

// ── Shell ─────────────────────────────────────────────────────────────────

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  static const _labels = ['Today', 'Coach', 'Lab', 'Plan', 'Profile'];
  static const _icons = [
    Icons.bolt_rounded,
    Icons.chat_bubble_rounded,
    Icons.science_rounded,
    Icons.calendar_month_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _index,
        children: const [
          _TodayTab(),
          _Placeholder(label: 'Coach', icon: Icons.chat_bubble_rounded),
          _Placeholder(label: 'Lab', icon: Icons.science_rounded),
          _Placeholder(label: 'Plan', icon: Icons.calendar_month_rounded),
          _Placeholder(label: 'Profile', icon: Icons.person_rounded),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        labels: _labels,
        icons: _icons,
        selectedIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final List<String> labels;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomBar({
    required this.labels,
    required this.icons,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.card,
        border: Border(
          top: BorderSide(color: AppTheme.separator, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: _BarItem(
                    icon: icons[i],
                    label: labels[i],
                    selected: selectedIndex == i,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.stand : AppTheme.tertiaryLabel;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const Gap(3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder ───────────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Placeholder({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppTheme.tertiaryLabel),
          const Gap(tokens.Spacing.md),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondaryLabel,
            ),
          ),
          const Gap(tokens.Spacing.xs),
          Text(
            'Coming soon',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Today tab ─────────────────────────────────────────────────────────────

class _TodayTab extends StatelessWidget {
  const _TodayTab();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Good night';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  String _dateLabel() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // ── App bar ───────────────────────────────────────────────────────
        SliverAppBar(
          backgroundColor: AppTheme.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          toolbarHeight: 56,
          titleSpacing: 20,
          title: Text(
            _dateLabel(),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.tertiaryLabel,
              letterSpacing: 0.2,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppTheme.separator,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: AppTheme.secondaryLabel,
                ),
              ),
            ),
            const Gap(20),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList.list(
            children: [
              // ── Hero banner ────────────────────────────────────────────
              _HeroBanner(greeting: _greeting()),
              const Gap(tokens.Spacing.lg),

              // ── Readiness ──────────────────────────────────────────────
              _ReadinessCard(),
              const Gap(tokens.Spacing.lg),

              // ── Metrics ────────────────────────────────────────────────
              const _SectionHeader(title: "Today's Metrics"),
              const Gap(tokens.Spacing.sm),
              const Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'HRV',
                      value: '—',
                      unit: 'ms',
                      accentColor: AppTheme.exercise,
                    ),
                  ),
                  Gap(tokens.Spacing.sm),
                  Expanded(
                    child: MetricTile(
                      label: 'Resting HR',
                      value: '—',
                      unit: 'bpm',
                      accentColor: AppTheme.move,
                    ),
                  ),
                ],
              ),
              const Gap(tokens.Spacing.sm),
              const Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'Sleep',
                      value: '—',
                      unit: 'h',
                      accentColor: AppTheme.stand,
                    ),
                  ),
                  Gap(tokens.Spacing.sm),
                  Expanded(
                    child: MetricTile(
                      label: 'Active kcal',
                      value: '—',
                      unit: 'kcal',
                      accentColor: AppTheme.energy,
                    ),
                  ),
                ],
              ),
              const Gap(tokens.Spacing.lg),

              // ── Connect ────────────────────────────────────────────────
              const _SectionHeader(title: 'Get Started'),
              const Gap(tokens.Spacing.sm),
              _ConnectCard(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Hero banner with runner ────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String greeting;
  const _HeroBanner({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppTheme.stand,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Subtle inner highlight at top
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Row(
              children: [
                // Text left
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        greeting,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.70),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'KYNOS',
                        style: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.0,
                          height: 1.0,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        'Your AI running coach',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.60),
                        ),
                      ),
                    ],
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

// ── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.secondaryLabel,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Readiness card ─────────────────────────────────────────────────────────

class _ReadinessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const _ActivityRing(
            progress: 0,
            size: 80,
            strokeWidth: 8,
            colors: [AppTheme.move, AppTheme.exercise, AppTheme.stand],
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READINESS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryLabel,
                    letterSpacing: 0.8,
                  ),
                ),
                const Gap(4),
                Text(
                  '—',
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.label,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
                const Gap(6),
                Text(
                  'Connect HealthKit to unlock your daily readiness.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.secondaryLabel,
                    height: 1.4,
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

// ── Activity rings ─────────────────────────────────────────────────────────

class _ActivityRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color> colors;

  const _ActivityRing({
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          colors: colors,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> colors;

  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < colors.length; i++) {
      final spacing = strokeWidth * 0.28;
      final radius =
          (size.width / 2) - strokeWidth / 2 - (strokeWidth + spacing) * i;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = colors[i].withValues(alpha: 0.15),
      );

      if (progress > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          2 * math.pi * progress,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = colors[i]
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Connect card ───────────────────────────────────────────────────────────

class _ConnectCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.exercise.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: AppTheme.exercise,
                    size: 24,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect HealthKit',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.label,
                        ),
                      ),
                      Text(
                        'Required for AI coaching',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.tertiaryLabel,
                  size: 20,
                ),
              ],
            ),
          ),
          const Divider(height: 0, indent: 72),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grant access to HRV, resting heart rate, sleep, and activity '
                  'data to unlock personalised AI coaching.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.secondaryLabel,
                    height: 1.5,
                  ),
                ),
                const Gap(16),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Connect HealthKit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
