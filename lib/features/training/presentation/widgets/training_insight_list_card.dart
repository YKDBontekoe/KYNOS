import 'package:flutter/material.dart';
import 'package:kynos/shared/widgets/insight_expandable_card.dart';

/// Expandable list insight for adjustments and debrief sections.
class TrainingInsightListCard extends StatelessWidget {
  const TrainingInsightListCard({
    super.key,
    required this.title,
    required this.icon,
    required this.lines,
    this.evidence = const [],
  });

  final String title;
  final IconData icon;
  final List<String> lines;
  final List<String> evidence;

  @override
  Widget build(BuildContext context) {
    return InsightExpandableCard(
      title: title,
      icon: icon,
      lines: lines,
      evidence: evidence,
    );
  }
}
