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
- **Entry:** [`lib/features/coach_chat/presentation/coach_chat_page.dart`](lib/features/coach_chat/presentation/coach_chat_page.dart)
- **Providers:** [`lib/features/coach_chat/providers/`](lib/features/coach_chat/providers/)
- **AI DI:** [`lib/shared/providers/ai_repository_providers.dart`](lib/shared/providers/ai_repository_providers.dart)

### nexus_lab (orphan — embedded in Training tab, not routed)
- **Entry:** [`lib/features/nexus_lab/presentation/nexus_lab_page.dart`](lib/features/nexus_lab/presentation/nexus_lab_page.dart)
- **State:** [`lib/shared/providers/nexus_lab_provider.dart`](lib/shared/providers/nexus_lab_provider.dart)

### settings (orphan — not routed)
- **Entry:** [`lib/features/settings/presentation/pages/settings_page.dart`](lib/features/settings/presentation/pages/settings_page.dart)
- **Providers:** [`lib/features/settings/providers/settings_controller.dart`](lib/features/settings/providers/settings_controller.dart)

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
| `lib/app/app.dart` | 33 | KynosApp |
| `lib/app/router.dart` | 54 | All named route paths — single source of truth. |
| `lib/app/shell_page.dart` | 172 | ShellPage, _ShellState, _BottomBar, … |
| `lib/core/constants/app_constants.dart` | 52 | Compile-time constants for KYNOS. |
| `lib/core/errors/failures.dart` | 30 | Base class for all domain-level failures in KYNOS. |
| `lib/core/theme/app_theme.dart` | 181 | AppTheme |
| `lib/core/theme/colors.dart` | 83 | KYNOS colour palette — iOS system colours, Apple Fitness aesthetic. |
| `lib/core/theme/elevation.dart` | 34 | Shadow presets for the KYNOS design system. |
| `lib/core/theme/kynos_theme_extension.dart` | 186 | KynosThemeExtension |
| `lib/core/theme/layout.dart` | 40 | Layout constants for consistent page structure. |
| `lib/core/theme/spacing.dart` | 21 | Design token: spacing scale (4-point grid). |
| `lib/core/theme/theme.dart` | 11 | KYNOS design system — barrel export. |
| `lib/core/theme/typography.dart` | 150 | Named text styles for the KYNOS design system. |
| `lib/domain/entities/athlete_profile.dart` | 56 | AthleteProfile |
| `lib/domain/entities/chat_message.dart` | 45 | ChatMessage |
| `lib/domain/entities/gamification/character_class.dart` | 157 | Dart module |
| `lib/domain/entities/gamification/character_stats.dart` | 129 | CharacterStats |
| `lib/domain/entities/gamification/earned_title.dart` | 65 | EarnedTitle |
| `lib/domain/entities/gamification/quest.dart` | 148 | Quest |
| `lib/domain/entities/gamification/runner_character.dart` | 135 | RunnerCharacter |
| `lib/domain/entities/gamification/xp_gain.dart` | 22 | XpGain |
| `lib/domain/entities/health_summary.dart` | 115 | HealthSummary |
| `lib/domain/entities/insights/insight_confidence.dart` | 15 | Dart module |
| `lib/domain/entities/insights/today_insights.dart` | 42 | TodayInsights |
| `lib/domain/entities/insights/training_insights.dart` | 34 | TrainingInsights |
| `lib/domain/entities/workout_route_point.dart` | 28 | WorkoutRoutePoint |
| `lib/domain/entities/workout_session.dart` | 38 | WorkoutSession |
| `lib/domain/repositories/ai_coach_repository.dart` | 29 | Streaming response chunk from the on-device LLM. |
| `lib/domain/repositories/ai_model_repository.dart` | 17 | Contract for managing the lifecycle of the on-device AI model file. |
| `lib/domain/repositories/biomechanics_repository.dart` | 41 | BiomechanicsSample |
| `lib/domain/repositories/character_repository.dart` | 12 | Dart module |
| `lib/domain/repositories/gamekit_repository.dart` | 43 | Dart module |
| `lib/domain/repositories/health_repository.dart` | 32 | Contract for accessing biometric data from the platform health store. |
| `lib/domain/usecases/gamification/assign_character_class_usecase.dart` | 147 | AssignCharacterClassUseCase |
| `lib/domain/usecases/gamification/compute_xp_usecase.dart` | 123 | ComputeXpUseCase |
| `lib/domain/usecases/gamification/generate_daily_quests_usecase.dart` | 240 | GenerateDailyQuestsUseCase |
| `lib/domain/usecases/insights/generate_today_insights_usecase.dart` | 70 | GenerateTodayInsightsUseCase |
| `lib/domain/usecases/insights/generate_training_insights_usecase.dart` | 295 | GenerateTrainingInsightsUseCase |
| `lib/domain/usecases/insights/today_insights_deterministic.dart` | 146 | Builds deterministic today insights from health metrics. |
| `lib/domain/usecases/insights/today_insights_model_refiner.dart` | 125 | TodayInsightsModelRefiner |
| `lib/domain/usecases/nexus_lab/calibrate_gait_model_usecase.dart` | 156 | CalibrateGaitModelUseCase, _SteadyStateExtractionTool |
| `lib/domain/utils/readiness_score.dart` | 46 | Composite recovery readiness score (0–100) from daily health metrics. |
| `lib/features/character/presentation/pages/character_page.dart` | 159 | CharacterPage, EmptyCharacterState |
| `lib/features/character/presentation/widgets/character_hero_card.dart` | 93 | CharacterHeroCard |
| `lib/features/character/presentation/widgets/character_shield_icon.dart` | 36 | CharacterShieldPainter |
| `lib/features/character/presentation/widgets/gamekit_panel.dart` | 99 | GameKitPanel, GameKitButton |
| `lib/features/character/presentation/widgets/quest_card.dart` | 189 | QuestPanel, QuestCard |
| `lib/features/character/presentation/widgets/signatory_power_card.dart` | 69 | SignatoryPowerCard |
| `lib/features/character/presentation/widgets/stats_panel.dart` | 97 | StatsPanel, StatRow |
| `lib/features/character/presentation/widgets/titles_panel.dart` | 53 | TitlesPanel |
| `lib/features/character/presentation/widgets/xp_bar.dart` | 70 | XpBar |
| `lib/features/character/providers/character_provider.dart` | 30 | Loads the persisted [RunnerCharacter], creating one via class assignment |
| `lib/features/character/providers/quest_provider.dart` | 70 | QuestNotifier |
| `lib/features/coach_chat/presentation/pages/coach_chat_page.dart` | 109 | CoachChatPage, _CoachChatPageState |
| `lib/features/coach_chat/presentation/widgets/assistant_bubble.dart` | 38 | AssistantBubble |
| `lib/features/coach_chat/presentation/widgets/chat_input_bar.dart` | 52 | ChatInputBar |
| `lib/features/coach_chat/presentation/widgets/coach_chat_app_bar.dart` | 76 | CoachChatAppBar, OnDeviceBadge |
| `lib/features/coach_chat/presentation/widgets/message_list.dart` | 101 | MessageList, MessageBubble, CoachChatEmptyState |
| `lib/features/coach_chat/presentation/widgets/model_setup_screen.dart` | 75 | ModelSetupScreen |
| `lib/features/coach_chat/presentation/widgets/typing_indicator.dart` | 53 | TypingIndicator, _TypingIndicatorState |
| `lib/features/coach_chat/providers/coach_chat_provider.dart` | 80 | CoachChatNotifier |
| `lib/features/coach_chat/providers/model_setup_provider.dart` | 36 | ModelSetupNotifier |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart` | 99 | DashboardPage |
| `lib/features/dashboard/presentation/pages/run_history_page.dart` | 127 | RunHistoryPage |
| `lib/features/dashboard/presentation/pages/run_route_page.dart` | 167 | RunRoutePage, _RouteContent, _AppleRouteMap, … |
| `lib/features/dashboard/presentation/widgets/activity_ring.dart` | 83 | ActivityRing, RingPainter |
| `lib/features/dashboard/presentation/widgets/connect_healthkit_card.dart` | 74 | ConnectHealthkitCard |
| `lib/features/dashboard/presentation/widgets/health_metrics_grid.dart` | 94 | HealthMetricsGrid |
| `lib/features/dashboard/presentation/widgets/readiness_card.dart` | 143 | ReadinessCard, ConfidenceBadgeRow |
| `lib/features/dashboard/presentation/widgets/today_insight_cards.dart` | 186 | TodayInsightCards, ActionCompactCard, _ActionCompactCardState, … |
| `lib/features/dashboard/providers/ai_insight_provider.dart` | 59 | Generates a single coaching sentence from today's health data using the |
| `lib/features/dashboard/providers/today_insights_provider.dart` | 55 | TodayInsightsState |
| `lib/features/nexus_lab/presentation/nexus_lab_page.dart` | 203 | NexusLabPage, _Content, _LoadingState, … |
| `lib/features/onboarding/presentation/onboarding_page.dart` | 232 | OnboardingItem, OnboardingPage, _OnboardingPageState, … |
| `lib/features/onboarding/providers/onboarding_provider.dart` | 29 | OnboardingCompleted |
| `lib/features/settings/presentation/pages/settings_page.dart` | 179 | SettingsPage, _SwitchTile, _DropdownTile, … |
| `lib/features/settings/providers/settings_controller.dart` | 47 | SettingsController |
| `lib/features/training/presentation/pages/training_page.dart` | 120 | TrainingPage |
| `lib/features/training/presentation/widgets/chart_placeholder.dart` | 16 | ChartPlaceholder |
| `lib/features/training/presentation/widgets/hrv_chart.dart` | 84 | HrvChart |
| `lib/features/training/presentation/widgets/load_chart.dart` | 88 | LoadChart |
| `lib/features/training/presentation/widgets/past_runs_list.dart` | 36 | PastRunsList |
| `lib/features/training/presentation/widgets/training_chip.dart` | 34 | TrainingChip |
| `lib/features/training/presentation/widgets/training_insight_cards.dart` | 65 | TrainingInsightsCards |
| `lib/features/training/presentation/widgets/training_insight_list_card.dart` | 29 | TrainingInsightListCard |
| `lib/features/training/presentation/widgets/training_insight_text_card.dart` | 35 | TrainingInsightTextCard |
| `lib/features/training/presentation/widgets/trend_cards.dart` | 77 | TrendCards |
| `lib/features/training/presentation/widgets/weekly_stats_grid.dart` | 91 | WeeklyStatsGrid |
| `lib/features/training/providers/training_insights_provider.dart` | 57 | TrainingInsightsState |
| `lib/infrastructure/ai/ai_infrastructure_providers.dart` | 21 | Provides the [AiCoachRepository] singleton. |
| `lib/infrastructure/ai/biomechanics/biomechanics_coefficients_protobuf.dart` | 170 | BiomechanicsCoefficientsProtobuf |
| `lib/infrastructure/ai/biomechanics/on_device_biomechanics_repository.dart` | 235 | OnDeviceBiomechanicsRepository |
| `lib/infrastructure/ai/gemma/ai_isolate_bridge.dart` | 3 | Dart module |
| `lib/infrastructure/ai/gemma/ai_isolate_entrypoint.dart` | 164 | Dart module |
| `lib/infrastructure/ai/gemma/ai_isolate_messages.dart` | 92 | AiInitRequest, AiChatRequest, AiTrainRegressionRequest, … |
| `lib/infrastructure/ai/gemma/ai_regression_math.dart` | 100 | Fits multivariate regression coefficients for stride length prediction. |
| `lib/infrastructure/ai/on_device_ai_coach_repository.dart` | 59 | OnDeviceAiCoachRepository |
| `lib/infrastructure/ai/on_device_model_repository.dart` | 21 | OnDeviceModelRepository |
| `lib/infrastructure/gamification/character_persistence_repository.dart` | 87 | CharacterPersistenceRepository |
| `lib/infrastructure/gamification/gamekit_repository_impl.dart` | 81 | GameKitRepositoryImpl |
| `lib/infrastructure/health/apple_workout_route_channel.dart` | 37 | AppleWorkoutRouteChannel |
| `lib/infrastructure/health/health_data_aggregator.dart` | 182 | _DailyAccumulator |
| `lib/infrastructure/health/health_infrastructure_providers.dart` | 14 | Platform binding for Apple HealthKit. |
| `lib/infrastructure/health/health_kit_repository.dart` | 152 | HealthKitRepository |
| `lib/infrastructure/health/health_kit_workout_mapper.dart` | 111 | Returns true when [point] represents a running workout. |
| `lib/infrastructure/privacy/local_sync_privacy_guard.dart` | 59 | LocalSyncPrivacyGuard |
| `lib/main.dart` | 30 | Dart module |
| `lib/shared/providers/ai_insights_usecase_provider.dart` | 24 | Dart module |
| `lib/shared/providers/ai_repository_providers.dart` | 5 | Dart module |
| `lib/shared/providers/biomechanics_provider.dart` | 21 | Dart module |
| `lib/shared/providers/gamification_providers.dart` | 38 | Dart module |
| `lib/shared/providers/health_providers.dart` | 111 | HealthPermissionsNotifier |
| `lib/shared/providers/health_repository_provider.dart` | 15 | Dart module |
| `lib/shared/providers/nexus_lab_provider.dart` | 75 | NexusLabState, NexusLabNotifier |
| `lib/shared/utils/date_label.dart` | 21 | Formats today's date as "Mon, Jan 5". |
| `lib/shared/utils/insight_text_formatter.dart` | 49 | Formats coaching insight text for concise, beginner-friendly UI labels. |
| `lib/shared/widgets/gait_model_card.dart` | 226 | GaitModelCard, _CoefficientsRow, GaitModelCardAsync |
| `lib/shared/widgets/glass_card.dart` | 65 | GlassCard |
| `lib/shared/widgets/insight_expandable_card.dart` | 198 | InsightExpandableCard, _InsightExpandableCardState, InsightTextExpandableCard, … |
| `lib/shared/widgets/kynos_card.dart` | 58 | KynosCard |
| `lib/shared/widgets/kynos_chip.dart` | 129 | KynosChip, _MetricChip, _AccentChip |
| `lib/shared/widgets/kynos_hero_banner.dart` | 111 | KynosHeroBanner |
| `lib/shared/widgets/kynos_loading_line.dart` | 54 | KynosLoadingLine |
| `lib/shared/widgets/kynos_privacy_footer.dart` | 26 | KynosPrivacyFooter |
| `lib/shared/widgets/kynos_section_header.dart` | 22 | KynosSectionHeader |
| `lib/shared/widgets/kynos_skeleton.dart` | 42 | KynosSkeleton |
| `lib/shared/widgets/kynos_user_bubble.dart` | 46 | KynosUserBubble |
| `lib/shared/widgets/metric_tile.dart` | 92 | MetricTile |
| `lib/shared/widgets/nav_icon.dart` | 159 | NavIconPainter |
| `lib/shared/widgets/run_card.dart` | 116 | RunCard |
| `lib/shared/widgets/widgets.dart` | 15 | KYNOS shared widgets — barrel export. |

## Hot Files (do not grow)

| File | Lines | Target |
|------|------:|--------|
| `lib/domain/usecases/insights/generate_training_insights_usecase.dart` | 295 | Split if > 250 lines |
| `lib/domain/usecases/gamification/generate_daily_quests_usecase.dart` | 240 | Split if > 250 lines |
| `lib/infrastructure/ai/biomechanics/on_device_biomechanics_repository.dart` | 235 | Split if > 250 lines |
| `lib/features/onboarding/presentation/onboarding_page.dart` | 232 | Split if > 250 lines |
| `lib/shared/widgets/gait_model_card.dart` | 226 | Split if > 250 lines |
| `lib/features/nexus_lab/presentation/nexus_lab_page.dart` | 203 | Split if > 250 lines |

_Generated by `dart run tool/generate_codemap.dart` — 131 hand-written Dart files._

<!-- CODEMAP_AUTO_END -->

