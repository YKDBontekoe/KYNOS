import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/entities/coach/athlete_coach_profile.dart';
import 'package:kynos/domain/entities/coach/morning_check_in.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachPersonalizationState {
  const CoachPersonalizationState({this.profile, this.morningCheckIn});

  final AthleteCoachProfile? profile;
  final MorningCheckIn? morningCheckIn;
}

final coachPersonalizationProvider =
    NotifierProvider<CoachPersonalizationNotifier, CoachPersonalizationState>(
      CoachPersonalizationNotifier.new,
    );

class CoachPersonalizationNotifier extends Notifier<CoachPersonalizationState> {
  @override
  CoachPersonalizationState build() =>
      _load(ref.read(sharedPreferencesProvider));

  static const _profileKey = 'coach.athlete_profile';
  static const _checkInKey = 'coach.morning_check_in';

  Future<void> saveProfile(AthleteCoachProfile profile) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    state = CoachPersonalizationState(
      profile: profile,
      morningCheckIn: state.morningCheckIn,
    );
  }

  Future<void> saveMorningCheckIn(MorningCheckIn checkIn) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_checkInKey, jsonEncode(checkIn.toJson()));
    state = CoachPersonalizationState(
      profile: state.profile,
      morningCheckIn: checkIn,
    );
  }

  static CoachPersonalizationState _load(SharedPreferences prefs) {
    AthleteCoachProfile? profile;
    MorningCheckIn? checkIn;
    final profileJson = prefs.getString(_profileKey);
    final checkInJson = prefs.getString(_checkInKey);
    if (profileJson != null) {
      try {
        profile = AthleteCoachProfile.fromJson(
          jsonDecode(profileJson) as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    if (checkInJson != null) {
      try {
        final parsed = MorningCheckIn.fromJson(
          jsonDecode(checkInJson) as Map<String, dynamic>,
        );
        final now = DateTime.now();
        if (parsed.date.year == now.year &&
            parsed.date.month == now.month &&
            parsed.date.day == now.day) {
          checkIn = parsed;
        }
      } catch (_) {}
    }
    return CoachPersonalizationState(profile: profile, morningCheckIn: checkIn);
  }
}
