import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/features/coach_chat/presentation/coach_chat_page.dart';
import 'package:kynos/features/dashboard/presentation/dashboard_page.dart';

/// Root app shell — owns the floating bottom nav and the [IndexedStack] of tabs.
///
/// Lives in [lib/app/] because it is the only layer allowed to import multiple
/// feature subtrees simultaneously.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellState();
}

class _ShellState extends State<ShellPage> {
  int _index = 0;

  static const _labels = ['Today', 'Coach', 'Lab', 'Plan', 'Profile'];

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
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardPage(),
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
          cx = next(); cy = next();
          path.moveTo(cx, cy);
          cmd = 'L';
        case 'L':
          cx = next(); cy = next();
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
          cx = next(); cy = next();
          path.cubicTo(x1, y1, x2, y2, cx, cy);
        case 'Q':
          final x1 = next(), y1 = next();
          cx = next(); cy = next();
          path.quadraticBezierTo(x1, y1, cx, cy);
        case 'A':
          final rx = next(), ry = next();
          final rot = next();
          final largeArc = next() == 1;
          final sweep = next() == 1;
          cx = next(); cy = next();
          path.arcToPoint(
            Offset(cx, cy),
            radius: Radius.elliptical(rx, ry),
            rotation: rot,
            largeArc: largeArc,
            clockwise: sweep,
          );
        case 'Z': case 'z':
          path.close();
        case 'l':
          cx += next(); cy += next();
          path.lineTo(cx, cy);
        case 'm':
          cx += next(); cy += next();
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
          path.cubicTo(cx + dx1, cy + dy1, cx + dx2, cy + dy2, cx + dx, cy + dy);
          cx += dx; cy += dy;
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
          cx = ex; cy = ey;
        default:
          i++;
      }
    }
    return path;
  }
}

// ── Nav SVG path constants (24×24 viewBox, Lucide stroke icons) ────────────

abstract final class _NavPaths {
  static const bolt = 'M13 2 3 14 12 14 11 22 21 10 12 10 13 2';
  static const chat = 'M7.9 20A9 9 0 1 0 4 16.1L2 22Z';
  static const lab =
      'M10 2v7.31l-5.24 9.65A1 1 0 0 0 5.68 21h12.64a1 1 0 0 0 .88-1.54L14 9.31V2 M8.5 2h7 M7 16h10';
  static const plan =
      'M3 4h18a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z M16 2v4 M8 2v4 M1 10h22 M9 16l2 2 4-4';
  static const profile =
      'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Z M12 7a3 3 0 1 0 0 6 3 3 0 0 0 0-6Z M6.168 18.849A4 4 0 0 1 10 16h4a4 4 0 0 1 3.834 2.855';
}

// ── Placeholder tabs ───────────────────────────────────────────────────────

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

