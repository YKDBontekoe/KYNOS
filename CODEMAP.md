# KYNOS Code Map

> **Agents: read this file first** before editing code. For rules and PR workflow see [AGENTS.md](AGENTS.md).

## Quick Start by Task

| Task | Start here |
|------|------------|
| Add a route | [`lib/app/router.dart`](lib/app/router.dart) |
| Add a feature | [`lib/features/<name>/`](lib/features/) + AGENTS.md §17 |
| Wire a repository | [`lib/shared/providers/`](lib/shared/providers/) |
| Edit AI isolate | [`lib/infrastructure/ai/gemma/`](lib/infrastructure/ai/gemma/) |
| Edit health data | [`lib/infrastructure/health/`](lib/infrastructure/health/) |
| Shared widgets | [`lib/shared/widgets/`](lib/shared/widgets/) |
| Domain logic | [`lib/domain/`](lib/domain/) |
| Regenerate this map | `dart run tool/generate_codemap.dart` |

## Architecture (actual)

```
features/  →  domain/  ←  infrastructure/
     ↘         ↑
      shared/providers/  (DI composition — only layer that imports infrastructure)
```

There is **no `data/` layer yet**. Repository implementations live in `infrastructure/`; `shared/providers/` binds them to Riverpod.

## Feature Index

### dashboard (Today tab)
- **Entry:** [`lib/features/dashboard/presentation/pages/dashboard_page.dart`](lib/features/dashboard/presentation/pages/dashboard_page.dart)
- **Providers:** [`lib/features/dashboard/providers/`](lib/features/dashboard/providers/)
- **Widgets:** [`lib/features/dashboard/presentation/widgets/`](lib/features/dashboard/presentation/widgets/)
- **Routes:** `/` (shell tab 0), `/run-history`, `/run-route`
- **Shared health data:** [`lib/shared/providers/health_providers.dart`](lib/shared/providers/health_providers.dart)

### training (Training tab)
- **Entry:** [`lib/features/training/presentation/pages/training_page.dart`](lib/features/training/presentation/pages/training_page.dart)
- **Providers:** [`lib/features/training/providers/training_insights_provider.dart`](lib/features/training/providers/training_insights_provider.dart)
- **Widgets:** [`lib/features/training/presentation/widgets/`](lib/features/training/presentation/widgets/)
- **Routes:** shell tab 1

### character (Character tab)
- **Entry:** [`lib/features/character/presentation/pages/character_page.dart`](lib/features/character/presentation/pages/character_page.dart)
- **Providers:** [`lib/features/character/providers/`](lib/features/character/providers/)
- **Widgets:** [`lib/features/character/presentation/widgets/`](lib/features/character/presentation/widgets/)
- **Routes:** shell tab 2
- **Gamification DI:** [`lib/shared/providers/gamification_providers.dart`](lib/shared/providers/gamification_providers.dart)

### onboarding
- **Entry:** [`lib/features/onboarding/presentation/onboarding_page.dart`](lib/features/onboarding/presentation/onboarding_page.dart)
- **Route:** `/onboarding`

### coach_chat (orphan — not routed)
- **Entry:** [`lib/features/coach_chat/presentation/pages/coach_chat_page.dart`](lib/features/coach_chat/presentation/pages/coach_chat_page.dart)
- **Providers:** [`lib/features/coach_chat/providers/`](lib/features/coach_chat/providers/)
- **AI DI:** [`lib/shared/providers/ai_repository_providers.dart`](lib/shared/providers/ai_repository_providers.dart)

### nexus_lab (orphan — embedded in Training tab, not routed)
- **Entry:** [`lib/features/nexus_lab/presentation/nexus_lab_page.dart`](lib/features/nexus_lab/presentation/nexus_lab_page.dart)
- **State:** [`lib/shared/providers/nexus_lab_provider.dart`](lib/shared/providers/nexus_lab_provider.dart)

### settings (orphan — not routed)
- **Entry:** [`lib/features/settings/presentation/pages/settings_page.dart`](lib/features/settings/presentation/pages/settings_page.dart)
- **Providers:** [`lib/features/settings/providers/settings_provider.dart`](lib/features/settings/providers/settings_provider.dart)

## Cross-Cutting Concerns

| Concern | Canonical location |
|---------|-------------------|
| Readiness score | [`lib/domain/utils/readiness_score.dart`](lib/domain/utils/readiness_score.dart) |
| Date labels | [`lib/shared/utils/date_label.dart`](lib/shared/utils/date_label.dart) |
| Insight cards | [`lib/shared/widgets/insight_expandable_card.dart`](lib/shared/widgets/insight_expandable_card.dart) |
| Gait model UI | [`lib/shared/widgets/gait_model_card.dart`](lib/shared/widgets/gait_model_card.dart) |
| Nav icons | [`lib/shared/widgets/nav_icon.dart`](lib/shared/widgets/nav_icon.dart) |
| Health providers | [`lib/shared/providers/health_providers.dart`](lib/shared/providers/health_providers.dart) |
| AI repositories | [`lib/shared/providers/ai_repository_providers.dart`](lib/shared/providers/ai_repository_providers.dart) |
| Router constants | [`lib/app/router.dart`](lib/app/router.dart) → `Routes` |

## Dependency Rules (agents)

1. **Never** import `infrastructure/` from `features/`.
2. **Never** import one feature's `providers/` from another feature — use `shared/providers/`.
3. Keep hand-written files **under ~250 lines**; extract widgets to `presentation/widgets/`.
4. Run `dart run tool/generate_codemap.dart` after structural changes.

<!-- CODEMAP_AUTO_BEGIN -->

## Layer Map (auto-generated)

| File | Lines | Summary |
|------|------:|---------|
| `lib/app/app.dart` | 24 | KynosApp |
| `lib/app/router.dart` | 53 | All named route paths — single source of truth. |
| `lib/app/shell_page.dart` | 171 | ShellPage, _ShellState, _BottomBar, … |
| `lib/core/constants/app_constants.dart` | 51 | Compile-time constants for KYNOS. |
| `lib/core/errors/failures.dart` | 29 | Base class for all domain-level failures in KYNOS. |
| `lib/core/theme/app_theme.dart` | 180 | AppTheme |
| `lib/core/theme/colors.dart` | 82 | KYNOS colour palette — iOS system colours, Apple Fitness aesthetic. |
| `lib/core/theme/elevation.dart` | 33 | Shadow presets for the KYNOS design system. |
| `lib/core/theme/kynos_theme_extension.dart` | 185 | KynosThemeExtension |
| `lib/core/theme/layout.dart` | 39 | Layout constants for consistent page structure. |
| `lib/core/theme/spacing.dart` | 20 | Design token: spacing scale (4-point grid). |
| `lib/core/theme/theme.dart` | 10 | KYNOS design system — barrel export. |
| `lib/core/theme/typography.dart` | 149 | Named text styles for the KYNOS design system. |
| `lib/domain/entities/athlete_profile.dart` | 55 | AthleteProfile |
| `lib/domain/entities/chat_message.dart` | 44 | ChatMessage |
| `lib/domain/entities/gamification/character_class.dart` | 156 | Dart module |
| `lib/domain/entities/gamification/character_stats.dart` | 128 | CharacterStats |
| `lib/domain/entities/gamification/earned_title.dart` | 64 | EarnedTitle |
| `lib/domain/entities/gamification/quest.dart` | 147 | Quest |
| `lib/domain/entities/gamification/runner_character.dart` | 134 | RunnerCharacter |
| `lib/domain/entities/gamification/xp_gain.dart` | 21 | XpGain |
| `lib/domain/entities/health_summary.dart` | 114 | HealthSummary |
| `lib/domain/entities/insights/insight_confidence.dart` | 14 | Dart module |
| `lib/domain/entities/insights/today_insights.dart` | 41 | TodayInsights |
| `lib/domain/entities/insights/training_insights.dart` | 33 | TrainingInsights |
| `lib/domain/entities/workout_route_point.dart` | 27 | WorkoutRoutePoint |
| `lib/domain/entities/workout_session.dart` | 37 | WorkoutSession |
| `lib/domain/repositories/ai_coach_repository.dart` | 28 | Streaming response chunk from the on-device LLM. |
| `lib/domain/repositories/ai_model_repository.dart` | 16 | Contract for managing the lifecycle of the on-device AI model file. |
| `lib/domain/repositories/biomechanics_repository.dart` | 40 | BiomechanicsSample |
| `lib/domain/repositories/character_repository.dart` | 11 | Dart module |
| `lib/domain/repositories/gamekit_repository.dart` | 42 | Dart module |
| `lib/domain/repositories/health_repository.dart` | 31 | Contract for accessing biometric data from the platform health store. |
| `lib/domain/usecases/gamification/assign_character_class_usecase.dart` | 146 | AssignCharacterClassUseCase |
| `lib/domain/usecases/gamification/compute_xp_usecase.dart` | 122 | ComputeXpUseCase |
| `lib/domain/usecases/gamification/generate_daily_quests_usecase.dart` | 239 | GenerateDailyQuestsUseCase |
| `lib/domain/usecases/insights/generate_today_insights_usecase.dart` | 69 | GenerateTodayInsightsUseCase |
| `lib/domain/usecases/insights/generate_training_insights_usecase.dart` | 294 | GenerateTrainingInsightsUseCase |
| `lib/domain/usecases/insights/today_insights_deterministic.dart` | 145 | Builds deterministic today insights from health metrics. |
| `lib/domain/usecases/insights/today_insights_model_refiner.dart` | 126 | TodayInsightsModelRefiner |
| `lib/domain/usecases/nexus_lab/calibrate_gait_model_usecase.dart` | 155 | CalibrateGaitModelUseCase, _SteadyStateExtractionTool |
| `lib/domain/utils/readiness_score.dart` | 73 | Dart module |
| `lib/features/character/presentation/pages/character_page.dart` | 156 | CharacterPage, EmptyCharacterState |
| `lib/features/character/presentation/widgets/character_hero_card.dart` | 92 | CharacterHeroCard |
| `lib/features/character/presentation/widgets/character_shield_icon.dart` | 35 | CharacterShieldPainter |
| `lib/features/character/presentation/widgets/gamekit_panel.dart` | 99 | GameKitPanel, GameKitButton |
| `lib/features/character/presentation/widgets/quest_card.dart` | 188 | QuestPanel, QuestCard |
| `lib/features/character/presentation/widgets/signatory_power_card.dart` | 68 | SignatoryPowerCard |
| `lib/features/character/presentation/widgets/stats_panel.dart` | 96 | StatsPanel, StatRow |
| `lib/features/character/presentation/widgets/titles_panel.dart` | 37 | TitlesPanel |
| `lib/features/character/presentation/widgets/xp_bar.dart` | 69 | XpBar |
| `lib/features/character/providers/character_provider.dart` | 29 | Loads the persisted [RunnerCharacter], creating one via class assignment |
| `lib/features/character/providers/quest_provider.dart` | 69 | QuestNotifier |
| `lib/features/coach_chat/presentation/pages/coach_chat_page.dart` | 110 | CoachChatPage, _CoachChatPageState |
| `lib/features/coach_chat/presentation/widgets/assistant_bubble.dart` | 37 | AssistantBubble |
| `lib/features/coach_chat/presentation/widgets/chat_input_bar.dart` | 53 | ChatInputBar |
| `lib/features/coach_chat/presentation/widgets/coach_chat_app_bar.dart` | 74 | CoachChatAppBar, OnDeviceBadge |
| `lib/features/coach_chat/presentation/widgets/message_list.dart` | 100 | MessageList, MessageBubble, CoachChatEmptyState |
| `lib/features/coach_chat/presentation/widgets/model_setup_screen.dart` | 74 | ModelSetupScreen |
| `lib/features/coach_chat/presentation/widgets/typing_indicator.dart` | 52 | TypingIndicator, _TypingIndicatorState |
| `lib/features/coach_chat/providers/coach_chat_provider.dart` | 79 | CoachChatNotifier |
| `lib/features/coach_chat/providers/model_setup_provider.dart` | 35 | ModelSetupNotifier |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart` | 98 | DashboardPage |
| `lib/features/dashboard/presentation/pages/run_history_page.dart` | 126 | RunHistoryPage |
| `lib/features/dashboard/presentation/pages/run_route_page.dart` | 166 | RunRoutePage, _RouteContent, _AppleRouteMap, … |
| `lib/features/dashboard/presentation/widgets/activity_ring.dart` | 82 | ActivityRing, RingPainter |
| `lib/features/dashboard/presentation/widgets/connect_healthkit_card.dart` | 73 | ConnectHealthkitCard |
| `lib/features/dashboard/presentation/widgets/health_metrics_grid.dart` | 93 | HealthMetricsGrid |
| `lib/features/dashboard/presentation/widgets/readiness_card.dart` | 142 | ReadinessCard, ConfidenceBadgeRow |
| `lib/features/dashboard/presentation/widgets/today_insight_cards.dart` | 185 | TodayInsightCards, ActionCompactCard, _ActionCompactCardState, … |
| `lib/features/dashboard/providers/ai_insight_provider.dart` | 58 | Generates a single coaching sentence from today's health data using the |
| `lib/features/dashboard/providers/today_insights_provider.dart` | 54 | TodayInsightsState |
| `lib/features/nexus_lab/presentation/nexus_lab_page.dart` | 202 | NexusLabPage, _Content, _LoadingState, … |
| `lib/features/onboarding/presentation/onboarding_page.dart` | 231 | OnboardingItem, OnboardingPage, _OnboardingPageState, … |
| `lib/features/onboarding/providers/onboarding_provider.dart` | 28 | OnboardingCompleted |
| `lib/features/settings/presentation/pages/settings_page.dart` | 179 | SettingsPage, _SwitchTile, _DropdownTile, … |
| `lib/features/settings/providers/settings_provider.dart` | 57 | SettingsState, Settings |
| `lib/features/training/presentation/pages/training_page.dart` | 139 | TrainingPage |
| `lib/features/training/presentation/widgets/chart_placeholder.dart` | 15 | ChartPlaceholder |
| `lib/features/training/presentation/widgets/hrv_chart.dart` | 83 | HrvChart |
| `lib/features/training/presentation/widgets/load_chart.dart` | 87 | LoadChart |
| `lib/features/training/presentation/widgets/past_runs_list.dart` | 35 | PastRunsList |
| `lib/features/training/presentation/widgets/training_chip.dart` | 33 | TrainingChip |
| `lib/features/training/presentation/widgets/training_insight_cards.dart` | 74 | TrainingInsightsCards |
| `lib/features/training/presentation/widgets/training_insight_list_card.dart` | 28 | TrainingInsightListCard |
| `lib/features/training/presentation/widgets/training_insight_text_card.dart` | 34 | TrainingInsightTextCard |
| `lib/features/training/presentation/widgets/trend_cards.dart` | 76 | TrendCards |
| `lib/features/training/presentation/widgets/weekly_stats_grid.dart` | 90 | WeeklyStatsGrid |
| `lib/features/training/providers/training_insights_provider.dart` | 56 | TrainingInsightsState |
| `lib/infrastructure/ai/ai_infrastructure_providers.dart` | 20 | Provides the [AiCoachRepository] singleton. |
| `lib/infrastructure/ai/biomechanics/biomechanics_coefficients_protobuf.dart` | 169 | BiomechanicsCoefficientsProtobuf |
| `lib/infrastructure/ai/biomechanics/on_device_biomechanics_repository.dart` | 234 | OnDeviceBiomechanicsRepository |
| `lib/infrastructure/ai/gemma/ai_isolate_bridge.dart` | 2 | Dart module |
| `lib/infrastructure/ai/gemma/ai_isolate_entrypoint.dart` | 163 | Dart module |
| `lib/infrastructure/ai/gemma/ai_isolate_messages.dart` | 91 | AiInitRequest, AiChatRequest, AiTrainRegressionRequest, … |
| `lib/infrastructure/ai/gemma/ai_regression_math.dart` | 99 | Fits multivariate regression coefficients for stride length prediction. |
| `lib/infrastructure/ai/on_device_ai_coach_repository.dart` | 58 | OnDeviceAiCoachRepository |
| `lib/infrastructure/ai/on_device_model_repository.dart` | 20 | OnDeviceModelRepository |
| `lib/infrastructure/gamification/character_persistence_repository.dart` | 86 | CharacterPersistenceRepository |
| `lib/infrastructure/gamification/gamekit_repository_impl.dart` | 80 | GameKitRepositoryImpl |
| `lib/infrastructure/health/apple_workout_route_channel.dart` | 36 | AppleWorkoutRouteChannel |
| `lib/infrastructure/health/health_data_aggregator.dart` | 173 | _DailyAccumulator |
| `lib/infrastructure/health/health_infrastructure_providers.dart` | 13 | Platform binding for Apple HealthKit. |
| `lib/infrastructure/health/health_kit_repository.dart` | 151 | HealthKitRepository |
| `lib/infrastructure/health/health_kit_workout_mapper.dart` | 110 | Returns true when [point] represents a running workout. |
| `lib/infrastructure/privacy/local_sync_privacy_guard.dart` | 58 | LocalSyncPrivacyGuard |
| `lib/main.dart` | 29 | Dart module |
| `lib/shared/providers/ai_insights_usecase_provider.dart` | 23 | Dart module |
| `lib/shared/providers/ai_repository_providers.dart` | 4 | Dart module |
| `lib/shared/providers/biomechanics_provider.dart` | 20 | Dart module |
| `lib/shared/providers/gamification_providers.dart` | 37 | Dart module |
| `lib/shared/providers/health_providers.dart` | 110 | HealthPermissionsNotifier |
| `lib/shared/providers/health_repository_provider.dart` | 15 | Dart module |
| `lib/shared/providers/nexus_lab_provider.dart` | 74 | NexusLabState, NexusLabNotifier |
| `lib/shared/utils/date_label.dart` | 20 | Formats today's date as "Mon, Jan 5". |
| `lib/shared/utils/insight_text_formatter.dart` | 48 | Formats coaching insight text for concise, beginner-friendly UI labels. |
| `lib/shared/widgets/gait_model_card.dart` | 225 | GaitModelCard, _CoefficientsRow, GaitModelCardAsync |
| `lib/shared/widgets/glass_card.dart` | 64 | GlassCard |
| `lib/shared/widgets/insight_expandable_card.dart` | 197 | InsightExpandableCard, _InsightExpandableCardState, InsightTextExpandableCard, … |
| `lib/shared/widgets/kynos_card.dart` | 57 | KynosCard |
| `lib/shared/widgets/kynos_chip.dart` | 128 | KynosChip, _MetricChip, _AccentChip |
| `lib/shared/widgets/kynos_hero_banner.dart` | 110 | KynosHeroBanner |
| `lib/shared/widgets/kynos_loading_line.dart` | 53 | KynosLoadingLine |
| `lib/shared/widgets/kynos_privacy_footer.dart` | 25 | KynosPrivacyFooter |
| `lib/shared/widgets/kynos_section_header.dart` | 21 | KynosSectionHeader |
| `lib/shared/widgets/kynos_skeleton.dart` | 41 | KynosSkeleton |
| `lib/shared/widgets/kynos_user_bubble.dart` | 45 | KynosUserBubble |
| `lib/shared/widgets/metric_tile.dart` | 91 | MetricTile |
| `lib/shared/widgets/nav_icon.dart` | 190 | NavIconPainter |
| `lib/shared/widgets/run_card.dart` | 115 | RunCard |
| `lib/shared/widgets/widgets.dart` | 14 | KYNOS shared widgets — barrel export. |

## Hot Files (do not grow)

| File | Lines | Target |
|------|------:|--------|
| `lib/domain/usecases/insights/generate_training_insights_usecase.dart` | 294 | Split if > 250 lines |

_Generated by `dart run tool/generate_codemap.dart` — 131 hand-written Dart files._

<!-- CODEMAP_AUTO_END -->


