/// Data sections that may be included in coach prompts.
enum CoachDataSource {
  readinessAcwr('Readiness & ACWR'),
  healthMetrics('Health metrics'),
  recentRuns('Recent runs'),
  weeklyMomentum('Weekly momentum'),
  todayInsights('Today insights'),
  trainingInsights('Training insights'),
  characterQuests('Character & quests'),
  gaitBiomechanics('Gait biomechanics'),
  athletePreferences('Athlete preferences'),
  postRunDebrief('Post-run debrief'),
  healthCheckIns('Daily check-ins'),
  coachMemory('Coach memory'),
  wellbeingExperiments('Wellbeing experiments');

  const CoachDataSource(this.label);
  final String label;

  static Set<CoachDataSource> get all => CoachDataSource.values.toSet();
}
