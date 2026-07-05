import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/app_theme.dart';
import 'package:kynos/core/theme/kynos_theme_extension.dart';
import 'package:kynos/core/theme/layout.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/typography.dart';
import 'package:kynos/features/character/presentation/character_page.dart';
import 'package:kynos/features/dashboard/presentation/dashboard_page.dart';
import 'package:kynos/features/training/presentation/training_page.dart';
import 'package:kynos/shared/widgets/glass_card.dart';

/// Root app shell — floating bottom nav with three focused tabs.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellState();
}

class _ShellState extends State<ShellPage> {
  int _index = 0;

  static const _labels = ['Today', 'Training', 'Character'];

  static const _navPaths = [
    _NavPaths.home,
    _NavPaths.activity,
    _NavPaths.character,
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
          TrainingPage(),
          CharacterPage(),
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

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.labels,
    required this.paths,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> labels;
  final List<String> paths;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: LayoutTokens.shellNavPadding,
          child: GlassCard(
            borderRadius: tokens.Radius.full,
            blurSigma: 40,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            tintColor: context.kynosTheme.glassFill.withValues(alpha: 0.93),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
              width: 0.5,
            ),
            child: SizedBox(
              height: 64,
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
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.svgPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String svgPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kynos = context.kynosTheme;
    final color = selected ? kynos.stand : kynos.navUnselected;
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
          const Gap(tokens.Spacing.xs),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: KynosTypography.navLabel(
              selected: selected,
              color: color,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

// ── Nav icon SVG path painter ──────────────────────────────────────────────────

class _NavIconPainter extends CustomPainter {
  const _NavIconPainter({
    required this.pathData,
    required this.color,
    required this.strokeWidth,
  });

  final String pathData;
  final Color color;
  final double strokeWidth;

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
          path.cubicTo(
            cx + dx1, cy + dy1,
            cx + dx2, cy + dy2,
            cx + dx, cy + dy,
          );
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

// ── Nav icon paths (24×24 viewBox, Lucide stroke icons) ──────────────────────

abstract final class _NavPaths {
  /// Lucide "home" — house outline
  static const home =
      'M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z M9 22V12h6v10';

  /// Lucide "activity" — EKG waveform
  static const activity = 'M22 12H18L15 21 9 3 6 12H2';

  /// Lucide "shield" — character class icon
  static const character =
      'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z';
}

