import 'package:kynos/domain/entities/health/health_coach_models.dart';

/// Deterministic guardrail for severe symptoms entered in the private check-in.
/// The language model never performs medical triage.
abstract final class HealthSafetyPolicy {
  static const _urgentPhrases = [
    'chest pain',
    'fainted',
    'fainting',
    'severe shortness of breath',
    'cannot breathe',
    'one-sided weakness',
    'face drooping',
    'slurred speech',
  ];

  static bool hasUrgentSelfReport(HealthCheckIn? checkIn) {
    return hasUrgentText(checkIn?.note);
  }

  static bool hasUrgentText(String? value) {
    final text = value?.toLowerCase().trim();
    if (text == null || text.isEmpty) return false;
    return _urgentPhrases.any(text.contains);
  }

  static const urgentGuidance =
      'KYNOS cannot assess urgent symptoms. Stop and contact local emergency '
      'services or seek immediate professional help now.';
}
