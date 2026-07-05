import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/domain/entities/health_summary.dart';
import 'package:kynos/features/dashboard/presentation/widgets/hrv_sparkline.dart';
import 'package:kynos/features/training/presentation/widgets/chart_placeholder.dart';
import 'package:kynos/features/training/presentation/widgets/load_chart.dart';
import 'package:kynos/shared/widgets/kynos_card.dart';
import 'package:kynos/shared/widgets/kynos_page_dots.dart';

/// Swipeable 7-day recovery and load trend cards for the Today tab.
class TrendCarousel extends StatefulWidget {
  const TrendCarousel({super.key, required this.history});

  final List<HealthSummary> history;

  @override
  State<TrendCarousel> createState() => _TrendCarouselState();
}

class _TrendCarouselState extends State<TrendCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = List<HealthSummary>.from(widget.history)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              _TrendPage(
                title: 'Recovery (7 days)',
                caption: 'HRV trend across recent sessions.',
                child: points.isEmpty
                    ? const ChartPlaceholder(label: 'No HRV data yet')
                    : HrvSparkline(history: points),
              ),
              _TrendPage(
                title: 'Training load (7 days)',
                caption: 'Daily running distance and active calories.',
                child: points.isEmpty
                    ? const ChartPlaceholder(label: 'No run history yet')
                    : LoadChart(points: points),
              ),
            ],
          ),
        ),
        const Gap(tokens.Spacing.md),
        KynosPageDots(count: 2, activeIndex: _page),
      ],
    );
  }
}

class _TrendPage extends StatelessWidget {
  const _TrendPage({
    required this.title,
    required this.caption,
    required this.child,
  });

  final String title;
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KynosCard(
      padding: const EdgeInsets.all(tokens.Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Gap(tokens.Spacing.xs),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
          const Gap(tokens.Spacing.lg),
          Expanded(child: child),
        ],
      ),
    );
  }
}
