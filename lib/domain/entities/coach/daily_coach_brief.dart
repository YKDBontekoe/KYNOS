import 'package:kynos/domain/entities/coach/athlete_coach_profile.dart';
import 'package:kynos/domain/entities/coach/morning_check_in.dart';

/// Compact, interpretable signals used to guide the daily coach response.
class DailyCoachBrief {
  const DailyCoachBrief({
    required this.recommendation,
    required this.confidence,
    required this.evidence,
    required this.dataQuality,
    this.checkIn,
    this.profile,
  });

  final String recommendation;
  final String confidence;
  final List<String> evidence;
  final String dataQuality;
  final MorningCheckIn? checkIn;
  final AthleteCoachProfile? profile;
}
