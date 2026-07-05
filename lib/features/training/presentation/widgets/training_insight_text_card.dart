import 'package:flutter/material.dart';
import 'package:kynos/shared/widgets/insight_expandable_card.dart';

/// Session intent insight with confidence and model metadata.
class TrainingInsightTextCard extends StatelessWidget {
  const TrainingInsightTextCard({
    super.key,
    required this.title,
    required this.icon,
    required this.text,
    required this.confidence,
    required this.usedModel,
  });

  final String title;
  final IconData icon;
  final String text;
  final String confidence;
  final bool usedModel;

  @override
  Widget build(BuildContext context) {
    final modeLabel = usedModel ? 'Gemma' : 'Rules';
    return InsightTextExpandableCard(
      title: title,
      icon: icon,
      text: text,
      extraChips: [
        'Confidence $confidence',
        modeLabel,
      ],
    );
  }
}
