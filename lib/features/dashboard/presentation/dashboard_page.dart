import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/coach_chat/presentation/coach_chat_page.dart';
import 'package:kynos/features/dashboard/providers/health_provider.dart';
import 'package:kynos/shared/widgets/metric_tile.dart';

// ── Root ──────────────────────────────────────────────────────────────────

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => const _Shell();
}

// ── Shell ─────────────────────────────────────────────────────────────────

class _Shell extends ConsumerStatefulWidget {
  const _Shell();

  @override
  ConsumerState<_Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<_Shell> {
  int _index = 0;

  static const _labels = ['Today', 'Coach', 'Lab', 'Plan', 'Profile'];

  // Lucide-quality SVG path data — matches the interactive prototype
  static const _navPaths = [
    _NavPaths.bolt,
    _NavPaths.chat,
    _NavPaths.lab,
    _NavPaths.plan,
    _NavPaths.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      // Allows body content to flow under the floating nav pill
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: const [
          _TodayTab(),
          CoachChatPage(),
          _Placeholder(label: 'Lab', icon: Icons.science_rounded),
          _Placeholder(label: 'Plan', icon: Icons.calendar_month_rounded),
          _Placeholder(label: 'Profile', icon: Icons.person_rounded),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        labels: _labels,
        paths: _navPaths,
        selectedIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final List<String> labels;
  final List<String> paths;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomBar({
    required this.labels,
    required this.paths,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Floating glass pill — truly floating via Scaffold.extendBody = true
    // Color.transparent background ensures nothing fills the area _below_ the pill
    return ColoredBox(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  // Near-opaque white so blur + shadow read well
                  color: Colors.white.withValues(alpha: 0.93),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 48,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Expanded(
                        child: _BarItem(
                          svgPath: paths[i],
                          label: labels[i],
                          selected: selectedIndex == i,
                          onTap: () => onTap(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final String svgPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BarItem({
    required this.svgPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.stand : const Color(0xFF606060);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.stand.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: CustomPaint(
                  key: ValueKey('$svgPath-$selected'),
                  size: const Size(22, 22),
                  painter: _NavIconPainter(
                    pathData: svgPath,
                    color: color,
                    strokeWidth: selected ? 2.0 : 1.8,
                  ),
                ),
              ),
            ),
          ),
          const Gap(2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: color,
              letterSpacing: selected ? -0.2 : 0.1,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

// ── Nav icon SVG path painter ──────────────────────────────────────────────

/// Paints a single Lucide-quality SVG path at 24×24 viewBox → 22×22 widget.
class _NavIconPainter extends CustomPainter {
  final String pathData;
  final Color color;
  final double strokeWidth;

  const _NavIconPainter({
    required this.pathData,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _parseSvgPath(pathData);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NavIconPainter old) =>
      old.pathData != pathData ||
      old.color != color ||
      old.strokeWidth != strokeWidth;

  /// Minimal SVG path parser — supports M, L, H, V, C, Q, Z and A (absolute + relative).
  static Path _parseSvgPath(String d) {
    final path = Path();
    final tokens = RegExp(
      r'[MLHVCSQTAZmlhvcsqtaz]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?',
    ).allMatches(d).map((m) => m.group(0)!).toList();

    var i = 0;
    double cx = 0, cy = 0;
    String cmd = 'M';

    double next() => double.parse(tokens[i++]);

    while (i < tokens.length) {
      final t = tokens[i];
      if (RegExp(r'^[A-Za-z]$').hasMatch(t)) {
        cmd = t;
        i++;
      }
      switch (cmd) {
        case 'M':
          cx = next();
          cy = next();
          path.moveTo(cx, cy);
          cmd = 'L';
        case 'L':
          cx = next();
          cy = next();
          path.lineTo(cx, cy);
        case 'H':
          cx = next();
          path.lineTo(cx, cy);
        case 'V':
          cy = next();
          path.lineTo(cx, cy);
        case 'C':
          final x1 = next(), y1 = next();
          final x2 = next(), y2 = next();
          cx = next();
          cy = next();
          path.cubicTo(x1, y1, x2, y2, cx, cy);
        case 'Q':
          final x1 = next(), y1 = next();
          cx = next();
          cy = next();
          path.quadraticBezierTo(x1, y1, cx, cy);
        case 'A':
          // rx ry x-rotation large-arc-flag sweep-flag x y
          final rx = next(), ry = next();
          final rot = next();
          final largeArc = next() == 1;
          final sweep = next() == 1;
          cx = next();
          cy = next();
          path.arcToPoint(
            Offset(cx, cy),
            radius: Radius.elliptical(rx, ry),
            rotation: rot,
            largeArc: largeArc,
            clockwise: sweep,
          );
        case 'Z':
        case 'z':
          path.close();
        case 'l':
          cx += next();
          cy += next();
          path.lineTo(cx, cy);
        case 'm':
          cx += next();
          cy += next();
          path.moveTo(cx, cy);
          cmd = 'l';
        case 'h':
          cx += next();
          path.lineTo(cx, cy);
        case 'v':
          cy += next();
          path.lineTo(cx, cy);
        case 'c':
          final dx1 = next(), dy1 = next();
          final dx2 = next(), dy2 = next();
          final dx = next(), dy = next();
          path.cubicTo(
            cx + dx1,
            cy + dy1,
            cx + dx2,
            cy + dy2,
            cx + dx,
            cy + dy,
          );
          cx += dx;
          cy += dy;
        case 'a':
          final rx = next(), ry = next();
          final rot = next();
          final largeArc = next() == 1;
          final sweep = next() == 1;
          final ex = cx + next(), ey = cy + next();
          path.arcToPoint(
            Offset(ex, ey),
            radius: Radius.elliptical(rx, ry),
            rotation: rot,
            largeArc: largeArc,
            clockwise: sweep,
          );
          cx = ex;
          cy = ey;
        default:
          i++; // skip unknown
      }
    }
    return path;
  }
}

// ── Nav SVG path constants (24×24 viewBox, Lucide stroke icons) ────────────
abstract final class _NavPaths {
  // Bolt / zap — Today tab
  static const bolt = 'M13 2 3 14 12 14 11 22 21 10 12 10 13 2';

  // Message circle — Coach tab
  static const chat = 'M7.9 20A9 9 0 1 0 4 16.1L2 22Z';

  // Flask conical — Lab tab
  static const lab =
      'M10 2v7.31l-5.24 9.65A1 1 0 0 0 5.68 21h12.64a1 1 0 0 0 .88-1.54L14 9.31V2 M8.5 2h7 M7 16h10';

  // Calendar with check mark — Plan tab
  static const plan =
      'M3 4h18a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z M16 2v4 M8 2v4 M1 10h22 M9 16l2 2 4-4';

  // Circle user — Profile tab
  static const profile =
      'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Z M12 7a3 3 0 1 0 0 6 3 3 0 0 0 0-6Z M6.168 18.849A4 4 0 0 1 10 16h4a4 4 0 0 1 3.834 2.855';
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

class _TodayTab extends ConsumerWidget {
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthSummary = ref.watch(healthSummaryProvider);

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
          // Extra bottom padding for the floating nav bar
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList.list(
            children: [
              // ── Hero banner ────────────────────────────────────────────
              _HeroBanner(greeting: _greeting()),
              const Gap(tokens.Spacing.lg),

              // ── Readiness ──────────────────────────────────────────────
              const _ReadinessCard(),
              const Gap(tokens.Spacing.lg),

              // ── Metrics ────────────────────────────────────────────────
              const _SectionHeader(title: "Today's Metrics"),
              const Gap(tokens.Spacing.sm),
              healthSummary.when(
                data: (summary) => _HealthMetricsGrid(summary: summary),
                loading: () => const _HealthMetricsGrid(summary: null),
                error: (e, s) => Center(
                  child: Text(
                    'Error loading metrics: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const Gap(tokens.Spacing.lg),

              // ── Connect ────────────────────────────────────────────────
              if (healthSummary.value == null && !healthSummary.isLoading) ...[
                const _SectionHeader(title: 'Get Started'),
                const Gap(tokens.Spacing.sm),
                const _ConnectCard(),
                const Gap(tokens.Spacing.lg),
              ],

              // ── Privacy notice ─────────────────────────────────────────
              const _PrivacyNotice(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Health metrics grid ─────────────────────────────────────────────────────

class _HealthMetricsGrid extends StatelessWidget {
  final HealthSummary? summary;

  const _HealthMetricsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'HRV',
                value: summary == null
                    ? null
                    : (summary!.hrvMs?.round().toString() ?? '—'),
                unit: 'ms',
                accentColor: AppTheme.exercise,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Resting HR',
                value: summary == null
                    ? null
                    : (summary!.rhrBpm?.round().toString() ?? '—'),
                unit: 'bpm',
                accentColor: AppTheme.move,
              ),
            ),
          ],
        ),
        const Gap(tokens.Spacing.sm),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Sleep',
                value: summary == null
                    ? null
                    : (summary!.sleepHours?.toStringAsFixed(1) ?? '—'),
                unit: 'h',
                accentColor: AppTheme.stand,
              ),
            ),
            const Gap(tokens.Spacing.sm),
            Expanded(
              child: MetricTile(
                label: 'Active kcal',
                value: summary == null
                    ? null
                    : (summary!.activeCalories?.round().toString() ?? '—'),
                unit: 'kcal',
                accentColor: AppTheme.energy,
              ),
            ),
          ],
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

class _ReadinessCard extends ConsumerWidget {
  const _ReadinessCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthSummary = ref.watch(healthSummaryProvider);

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
          _ActivityRing(
            progress: healthSummary.when(
              data: (summary) => summary != null ? 0.75 : 0.0,
              loading: () => 0.0,
              error: (e, s) => 0.0,
            ),
            size: 80,
            strokeWidth: 8,
            colors: const [AppTheme.move, AppTheme.exercise, AppTheme.stand],
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
                healthSummary.when(
                  data: (summary) => Text(
                    summary != null ? '87' : '—',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      // Purple for readiness score — matches design prototype
                      color: summary != null ? AppTheme.purple : AppTheme.label,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, s) => Text(
                    'Error',
                    style: GoogleFonts.inter(fontSize: 24, color: Colors.red),
                  ),
                ),
                const Gap(6),
                Text(
                  healthSummary.when(
                    data: (summary) => summary != null
                        ? 'Great recovery. Optimal conditions for a high-intensity interval run today.'
                        : 'Connect HealthKit to unlock your daily readiness.',
                    loading: () => 'Calculating readiness...',
                    error: (e, s) => 'Could not calculate readiness.',
                  ),
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

class _ConnectCard extends ConsumerWidget {
  const _ConnectCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  onPressed: () async {
                    final repo = ref.read(healthRepositoryProvider);
                    final success = await repo.requestPermissions();
                    if (success) {
                      ref.invalidate(healthSummaryProvider);
                    }
                  },
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

// ── Privacy notice ──────────────────────────────────────────────────────────

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, size: 14, color: AppTheme.tertiaryLabel),
        const Gap(tokens.Spacing.sm),
        Text(
          'All data stays on your device',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.tertiaryLabel),
        ),
      ],
    );
  }
}
