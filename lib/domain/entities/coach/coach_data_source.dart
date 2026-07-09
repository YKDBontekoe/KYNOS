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
  postRunDebrief('Post-run debrief');

  const CoachDataSource(this.label);
  final String label;

  static Set<CoachDataSource> get all => CoachDataSource.values.toSet();
}
