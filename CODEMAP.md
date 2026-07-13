# KYNOS Code Map

> **Agents: read this file first** before editing code. For rules and PR workflow see [AGENTS.md](AGENTS.md).

## Quick Start by Task

| Task | Start here |
|------|------------|
| Agent onboarding | [`docs/agents/README.md`](docs/agents/README.md) |
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

### coach_chat (the AI coach — core surface)
- **Entry:** [`lib/features/coach_chat/presentation/pages/coach_chat_page.dart`](lib/features/coach_chat/presentation/pages/coach_chat_page.dart)
- **Providers:** [`lib/features/coach_chat/providers/`](lib/features/coach_chat/providers/) — `coach_chat_provider.dart` runs the agentic ReAct tool-calling loop
- **Routes:** `/coach` (modal push from the FAB, dashboard hero card, and insight cards)
- **AI DI:** [`lib/shared/providers/ai_repository_providers.dart`](lib/shared/providers/ai_repository_providers.dart)
- **Agentic tools:** [`lib/domain/entities/coach/coach_tool_definition.dart`](lib/domain/entities/coach/coach_tool_definition.dart) (catalog), [`lib/domain/usecases/coach/execute_coach_tool_usecase.dart`](lib/domain/usecases/coach/execute_coach_tool_usecase.dart) (execution), [`lib/domain/utils/coach_tool_call_parser.dart`](lib/domain/utils/coach_tool_call_parser.dart) (parsing)

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
| Coach agent tools | [`lib/domain/entities/coach/coach_tool_definition.dart`](lib/domain/entities/coach/coach_tool_definition.dart) |
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
| `lib/app/app.dart` | 27 | `KynosApp` |
| `lib/app/not_found_page.dart` | 46 | `NotFoundPage` |
| `lib/app/page_transitions.dart` | 100 | `Route transition presets for [GoRouter] [pageBuilder] callbacks.` |
| `lib/app/router.dart` | 245 | `_RouterRefreshNotifier` |
| `lib/app/shell_navigation_scope.dart` | 33 | `ShellNavigationScope, CoachTab` |
| `lib/app/shell_page.dart` | 174 | `ShellPage, _AnimatedShellBody, _AnimatedShellBodyState, …` |
| `lib/core/constants/app_constants.dart` | 54 | `Compile-time constants for KYNOS.` |
| `lib/core/constants/gamification_constants.dart` | 46 | `Gameplay tuning for Summit Camp.` |
| `lib/core/constants/imported_workout_ids.dart` | 10 | `Prefix and helpers for locally imported workout identifiers.` |
| `lib/core/errors/failures.dart` | 38 | `Base class for all domain-level failures in KYNOS.` |
| `lib/core/theme/app_theme.dart` | 191 | `AppTheme` |
| `lib/core/theme/colors.dart` | 82 | `KYNOS colour palette — iOS system colours, Apple Fitness aesthetic.` |
| `lib/core/theme/elevation.dart` | 33 | `Shadow presets for the KYNOS design system.` |
| `lib/core/theme/kynos_theme_extension.dart` | 229 | `KynosThemeExtension` |
| `lib/core/theme/layout.dart` | 85 | `Layout constants for consistent page structure.` |
| `lib/core/theme/liquid_glass_tokens.dart` | 54 | `Design tokens for Apple Liquid Glass materials — blur, vibrancy, specular edges.` |
| `lib/core/theme/motion.dart` | 17 | `Design token: motion durations and curves shared across the app.` |
| `lib/core/theme/spacing.dart` | 20 | `Design token: spacing scale (4-point grid).` |
| `lib/core/theme/theme.dart` | 12 | `KYNOS design system — barrel export.` |
| `lib/core/theme/typography.dart` | 171 | `Named text styles for the KYNOS design system.` |
| `lib/domain/catalog/on_device_model_catalog.dart` | 275 | `Curated catalog of LiteRT-LM models supported by KYNOS on-device coach.` |
| `lib/domain/entities/ai_inference_backend.dart` | 6 | `Where the last coach inference ran.` |
| `lib/domain/entities/ai_task_kind.dart` | 9 | `Classification for hybrid local/cloud AI routing.` |
| `lib/domain/entities/athlete_profile.dart` | 55 | `AthleteProfile` |
| `lib/domain/entities/chat_message.dart` | 139 | `ChatMessage` |
| `lib/domain/entities/cloud_data_level.dart` | 10 | `How much health context may be included in OpenRouter prompts.` |
| `lib/domain/entities/coach/athlete_coach_profile.dart` | 53 | `AthleteCoachProfile` |
| `lib/domain/entities/coach/coach_backend_mode.dart` | 9 | `Per-conversation inference routing preference.` |
| `lib/domain/entities/coach/coach_chat_seed.dart` | 36 | `CoachChatSeedData` |
| `lib/domain/entities/coach/coach_context.dart` | 83 | `CoachContext` |
| `lib/domain/entities/coach/coach_context_preferences.dart` | 65 | `CoachContextPreferences` |
| `lib/domain/entities/coach/coach_conversation.dart` | 61 | `CoachConversation` |
| `lib/domain/entities/coach/coach_conversation_settings.dart` | 57 | `CoachConversationSettings` |
| `lib/domain/entities/coach/coach_conversation_summary.dart` | 48 | `CoachConversationSummary` |
| `lib/domain/entities/coach/coach_data_source.dart` | 21 | `Data sections that may be included in coach prompts.` |
| `lib/domain/entities/coach/coach_data_source_snapshot.dart` | 18 | `CoachDataSourceSnapshot` |
| `lib/domain/entities/coach/coach_seed_topic.dart` | 13 | `Entry-point hint for tailoring coach context and seed prompts.` |
| `lib/domain/entities/coach/coach_tool_call.dart` | 42 | `A structured tool invocation requested by the coach model mid-answer.` |
| `lib/domain/entities/coach/coach_tool_definition.dart` | 156 | `CoachToolDefinition` |
| `lib/domain/entities/coach/daily_coach_brief.dart` | 21 | `DailyCoachBrief` |
| `lib/domain/entities/coach/morning_check_in.dart` | 30 | `MorningCheckIn` |
| `lib/domain/entities/dashboard/dashboard_summary.dart` | 60 | `DashboardSummary` |
| `lib/domain/entities/gamification/camp_building.dart` | 87 | `PlacedBuilding` |
| `lib/domain/entities/gamification/camp_resources.dart` | 74 | `CampResources` |
| `lib/domain/entities/gamification/camp_state.dart` | 238 | `CampState` |
| `lib/domain/entities/gamification/camp_tile.dart` | 56 | `CampTile` |
| `lib/domain/entities/gamification/character_class.dart` | 156 | `Dart module` |
| `lib/domain/entities/gamification/character_stats.dart` | 128 | `CharacterStats` |
| `lib/domain/entities/gamification/earned_title.dart` | 64 | `EarnedTitle` |
| `lib/domain/entities/gamification/expedition_event.dart` | 47 | `ExpeditionEvent` |
| `lib/domain/entities/gamification/quest.dart` | 203 | `QuestObjective, Quest` |
| `lib/domain/entities/gamification/runner_character.dart` | 134 | `RunnerCharacter` |
| `lib/domain/entities/gamification/xp_gain.dart` | 21 | `XpGain` |
| `lib/domain/entities/health/health_coach_models.dart` | 152 | `Dart module` |
| `lib/domain/entities/health/health_metric.dart` | 42 | `Health signals the wellbeing coach may inspect and visualise.` |
| `lib/domain/entities/health/health_visual_artifact.dart` | 142 | `Dart module` |
| `lib/domain/entities/health_summary.dart` | 114 | `HealthSummary` |
| `lib/domain/entities/insights/insight_confidence.dart` | 14 | `Dart module` |
| `lib/domain/entities/insights/today_insights.dart` | 41 | `TodayInsights` |
| `lib/domain/entities/insights/training_insights.dart` | 33 | `TrainingInsights` |
| `lib/domain/entities/on_device_model.dart` | 68 | `OnDeviceModel` |
| `lib/domain/entities/openrouter_model.dart` | 51 | `OpenRouterModelPricing, OpenRouterModel` |
| `lib/domain/entities/openrouter_model_filters.dart` | 112 | `OpenRouterModelFilters` |
| `lib/domain/entities/workout_route_point.dart` | 27 | `WorkoutRoutePoint` |
| `lib/domain/entities/workout_session.dart` | 37 | `WorkoutSession` |
| `lib/domain/repositories/ai_coach_repository.dart` | 38 | `Streaming response chunk from the on-device or cloud LLM.` |
| `lib/domain/repositories/ai_model_repository.dart` | 25 | `Contract for managing the lifecycle of the on-device AI model file.` |
| `lib/domain/repositories/biomechanics_repository.dart` | 40 | `BiomechanicsSample` |
| `lib/domain/repositories/character_repository.dart` | 15 | `Dart module` |
| `lib/domain/repositories/cloud_ai_repository.dart` | 21 | `Cloud inference backend for BYOK OpenRouter requests.` |
| `lib/domain/repositories/coach_conversation_repository.dart` | 32 | `Persists coach chat threads locally.` |
| `lib/domain/repositories/gamekit_repository.dart` | 42 | `Dart module` |
| `lib/domain/repositories/health_coach_repository.dart` | 10 | `Dart module` |
| `lib/domain/repositories/health_repository.dart` | 39 | `Contract for accessing biometric data from the platform health store.` |
| `lib/domain/repositories/openrouter_models_repository.dart` | 12 | `Contract for fetching the OpenRouter model catalog.` |
| `lib/domain/usecases/coach/build_coach_context_usecase.dart` | 94 | `BuildCoachContextUseCase` |
| `lib/domain/usecases/coach/build_daily_coach_brief_usecase.dart` | 64 | `BuildDailyCoachBriefUseCase` |
| `lib/domain/usecases/coach/coach_tool_context_queries.dart` | 150 | `CoachToolContextQueries` |
| `lib/domain/usecases/coach/coach_tool_health_queries.dart` | 521 | `CoachToolHealthQueries` |
| `lib/domain/usecases/coach/coach_tool_wellbeing_queries.dart` | 387 | `CoachToolWellbeingQueries` |
| `lib/domain/usecases/coach/create_coach_conversation_usecase.dart` | 35 | `CreateCoachConversationUseCase` |
| `lib/domain/usecases/coach/delete_coach_conversation_usecase.dart` | 17 | `DeleteCoachConversationUseCase` |
| `lib/domain/usecases/coach/describe_coach_context_usecase.dart` | 93 | `DescribeCoachContextUseCase` |
| `lib/domain/usecases/coach/execute_coach_tool_usecase.dart` | 120 | `ExecuteCoachToolUseCase` |
| `lib/domain/usecases/coach/export_coach_conversation_usecase.dart` | 33 | `ExportCoachConversationUseCase` |
| `lib/domain/usecases/coach/filter_coach_context_usecase.dart` | 88 | `FilterCoachContextUseCase` |
| `lib/domain/usecases/coach/get_coach_conversation_usecase.dart` | 20 | `GetCoachConversationUseCase` |
| `lib/domain/usecases/coach/list_coach_conversations_usecase.dart` | 44 | `ListCoachConversationsUseCase` |
| `lib/domain/usecases/coach/migrate_legacy_coach_chat_usecase.dart` | 26 | `MigrateLegacyCoachChatUseCase` |
| `lib/domain/usecases/coach/send_coach_message_usecase.dart` | 74 | `SendCoachMessageUseCase` |
| `lib/domain/usecases/coach/update_coach_conversation_usecase.dart` | 29 | `UpdateCoachConversationUseCase` |
| `lib/domain/usecases/gamification/advance_weekly_summit_usecase.dart` | 31 | `AdvanceWeeklySummitUseCase` |
| `lib/domain/usecases/gamification/assign_character_class_usecase.dart` | 146 | `AssignCharacterClassUseCase` |
| `lib/domain/usecases/gamification/build_camp_structure_usecase.dart` | 96 | `BuildCampStructureResult, BuildCampStructureUseCase` |
| `lib/domain/usecases/gamification/compute_camp_resources_usecase.dart` | 82 | `ComputeCampResourcesUseCase` |
| `lib/domain/usecases/gamification/compute_xp_usecase.dart` | 122 | `ComputeXpUseCase` |
| `lib/domain/usecases/gamification/evaluate_quest_progress_usecase.dart` | 68 | `EvaluateQuestProgressUseCase` |
| `lib/domain/usecases/gamification/expand_camp_tile_usecase.dart` | 71 | `ExpandCampTileResult, ExpandCampTileUseCase` |
| `lib/domain/usecases/gamification/generate_camp_quests_usecase.dart` | 165 | `GenerateCampQuestsUseCase` |
| `lib/domain/usecases/gamification/resolve_expedition_usecase.dart` | 71 | `ResolveExpeditionResult, ResolveExpeditionUseCase` |
| `lib/domain/usecases/gamification/rest_camp_usecase.dart` | 62 | `RestCampResult, RestCampUseCase` |
| `lib/domain/usecases/health/build_daily_health_brief_usecase.dart` | 148 | `BuildDailyHealthBriefUseCase` |
| `lib/domain/usecases/health/import_apple_health_export_usecase.dart` | 144 | `ImportAppleHealthExportResult, ImportAppleHealthExportUseCase` |
| `lib/domain/usecases/health/import_workout_usecase.dart` | 48 | `ImportWorkoutUseCase` |
| `lib/domain/usecases/insights/generate_post_run_debrief_usecase.dart` | 98 | `PostRunDebrief, GeneratePostRunDebriefUseCase` |
| `lib/domain/usecases/insights/generate_today_insights_usecase.dart` | 69 | `GenerateTodayInsightsUseCase` |
| `lib/domain/usecases/insights/generate_training_insights_usecase.dart` | 287 | `GenerateTrainingInsightsUseCase` |
| `lib/domain/usecases/insights/today_insights_deterministic.dart` | 145 | `Builds deterministic today insights from health metrics.` |
| `lib/domain/usecases/insights/today_insights_model_refiner.dart` | 128 | `TodayInsightsModelRefiner` |
| `lib/domain/usecases/nexus_lab/calibrate_gait_model_usecase.dart` | 155 | `CalibrateGaitModelUseCase, _SteadyStateExtractionTool` |
| `lib/domain/utils/acwr.dart` | 38 | `Acute:chronic workload ratio from daily running distance.` |
| `lib/domain/utils/ai_inference_error_policy.dart` | 149 | `Classifies on-device LLM failures and maps them to user-facing copy.` |
| `lib/domain/utils/ai_task_router.dart` | 37 | `Routes AI tasks to local Gemma or OpenRouter cloud backends.` |
| `lib/domain/utils/cloud_health_text_redactor.dart` | 28 | `Converts free-form text into an approved, non-identifying intent.` |
| `lib/domain/utils/cloud_prompt_sanitizer.dart` | 29 | `Strips sensitive fields from cloud-bound prompts.` |
| `lib/domain/utils/coach_backend_mode_mapper.dart` | 13 | `Maps per-conversation backend mode to repository preferred backend.` |
| `lib/domain/utils/coach_context_formatter.dart` | 205 | `Formats [CoachContext] into a privacy-safe LLM prompt block.` |
| `lib/domain/utils/coach_fallback_reply.dart` | 28 | `Deterministic coach reply when on-device Gemma is unavailable.` |
| `lib/domain/utils/coach_follow_up_suggestions.dart` | 34 | `Deterministic follow-up suggestions after a coach reply.` |
| `lib/domain/utils/coach_prompt_truncator.dart` | 48 | `Marker for the athlete question block — must match [coach_prompt_builder].` |
| `lib/domain/utils/coach_tool_call_parser.dart` | 107 | `Parses ReAct-style `TOOL_CALL: {...}` directives from coach model output.` |
| `lib/domain/utils/coach_tool_result_helpers.dart` | 61 | `Shared argument coercion and result-factory helpers for coach tool` |
| `lib/domain/utils/gemma_device_capability.dart` | 62 | `On-device Gemma inference tier based on device resources.` |
| `lib/domain/utils/gemma_inference_limits.dart` | 19 | `Token budgets keyed by on-device Gemma inference tier.` |
| `lib/domain/utils/geo_distance.dart` | 40 | `Haversine distance between two WGS-84 coordinates in meters.` |
| `lib/domain/utils/health_coach_analysis.dart` | 139 | `Dart module` |
| `lib/domain/utils/health_context_formatter.dart` | 58 | `Formats [HealthSummary] rows for LLM prompts without raw GPS or device IDs.` |
| `lib/domain/utils/health_safety_policy.dart` | 30 | `Deterministic guardrail for severe symptoms entered in the private check-in.` |
| `lib/domain/utils/metric_trends.dart` | 85 | `MetricDelta` |
| `lib/domain/utils/pace_format.dart` | 28 | `Formats pace as `m:ss /km` from seconds per kilometer.` |
| `lib/domain/utils/personal_bests.dart` | 63 | `Finds short personal-best callouts for dashboard chips.` |
| `lib/domain/utils/readiness_score.dart` | 123 | `ReadinessDimensions` |
| `lib/domain/utils/run_route_analytics.dart` | 274 | `PaceProfilePoint, KilometerSplit, RunRouteAnalytics, …` |
| `lib/domain/utils/run_streak.dart` | 65 | `Dart module` |
| `lib/domain/utils/running_distance.dart` | 12 | `Running-only distance in meters for a daily summary.` |
| `lib/domain/utils/seeded_roll.dart` | 17 | `Deterministic 32-bit roll safe for VM and JavaScript (no >53-bit intermediates).` |
| `lib/domain/utils/weekly_momentum.dart` | 87 | `WeeklyMomentum` |
| `lib/features/character/presentation/pages/character_page.dart` | 302 | `CharacterPage, EmptyCharacterState` |
| `lib/features/character/presentation/widgets/camp_build_sheet.dart` | 133 | `CampBuildSheet` |
| `lib/features/character/presentation/widgets/camp_game_panel.dart` | 145 | `CampGamePanel, _CampGamePanelState` |
| `lib/features/character/presentation/widgets/camp_grid.dart` | 119 | `CampGrid, _CampTileCell` |
| `lib/features/character/presentation/widgets/camp_resources_bar.dart` | 122 | `CampResourcesBar, _ResourceChip` |
| `lib/features/character/presentation/widgets/character_hero_card.dart` | 107 | `CharacterHeroCard` |
| `lib/features/character/presentation/widgets/character_shield_icon.dart` | 35 | `CharacterShieldPainter` |
| `lib/features/character/presentation/widgets/expedition_card.dart` | 89 | `ExpeditionCard` |
| `lib/features/character/presentation/widgets/gamekit_panel.dart` | 104 | `GameKitPanel, GameKitButton` |
| `lib/features/character/presentation/widgets/quest_card.dart` | 269 | `QuestPanel, QuestCard` |
| `lib/features/character/presentation/widgets/signatory_power_card.dart` | 68 | `SignatoryPowerCard` |
| `lib/features/character/presentation/widgets/stats_panel.dart` | 96 | `StatsPanel, StatRow` |
| `lib/features/character/presentation/widgets/summit_progress_card.dart` | 70 | `SummitProgressCard` |
| `lib/features/character/presentation/widgets/titles_panel.dart` | 37 | `TitlesPanel` |
| `lib/features/character/presentation/widgets/wellbeing_quest_panel.dart` | 49 | `WellbeingQuestPanel` |
| `lib/features/character/presentation/widgets/xp_bar.dart` | 69 | `XpBar` |
| `lib/features/character/providers/character_provider.dart` | 1 | `Dart module` |
| `lib/features/character/providers/quest_provider.dart` | 48 | `QuestNotifier` |
| `lib/features/coach_chat/presentation/pages/coach_chat_page.dart` | 426 | `CoachChatPage, _CoachChatPageState, _ModelProgressBanner` |
| `lib/features/coach_chat/presentation/widgets/agent_tool_step_list.dart` | 89 | `AgentToolStepList, _AgentToolStepRow` |
| `lib/features/coach_chat/presentation/widgets/animated_message_entrance.dart` | 63 | `AnimatedMessageEntrance, _AnimatedMessageEntranceState` |
| `lib/features/coach_chat/presentation/widgets/assistant_bubble.dart` | 192 | `AssistantBubble` |
| `lib/features/coach_chat/presentation/widgets/chat_input_bar.dart` | 84 | `ChatInputBar` |
| `lib/features/coach_chat/presentation/widgets/cloud_consent_banner.dart` | 57 | `CloudConsentBanner` |
| `lib/features/coach_chat/presentation/widgets/coach_chat_app_bar.dart` | 121 | `CoachChatAppBar` |
| `lib/features/coach_chat/presentation/widgets/coach_markdown_text.dart` | 62 | `CoachMarkdownText` |
| `lib/features/coach_chat/presentation/widgets/context_inspector_sheet.dart` | 233 | `ContextInspectorSheet, _ContextInspectorSheetState, _BudgetMeter` |
| `lib/features/coach_chat/presentation/widgets/conversation_list_sheet.dart` | 258 | `ConversationListSheet, _ConversationListSheetState` |
| `lib/features/coach_chat/presentation/widgets/daily_health_brief_card.dart` | 91 | `DailyHealthBriefCard` |
| `lib/features/coach_chat/presentation/widgets/focus_run_picker_sheet.dart` | 118 | `FocusRunPickerSheet` |
| `lib/features/coach_chat/presentation/widgets/follow_up_chips.dart` | 35 | `FollowUpChips` |
| `lib/features/coach_chat/presentation/widgets/glass_suggestion_chip.dart` | 89 | `GlassSuggestionChip, _GlassSuggestionChipState` |
| `lib/features/coach_chat/presentation/widgets/health_check_in_sheet.dart` | 134 | `HealthCheckInSheet, _HealthCheckInSheetState` |
| `lib/features/coach_chat/presentation/widgets/health_visual_artifact_card.dart` | 404 | `HealthVisualArtifactCard, _HealthVisualArtifactCardState, _ValueRow` |
| `lib/features/coach_chat/presentation/widgets/inference_mode_bar.dart` | 94 | `InferenceModeBar` |
| `lib/features/coach_chat/presentation/widgets/inference_settings_sheet.dart` | 104 | `InferenceSettingsSheet` |
| `lib/features/coach_chat/presentation/widgets/message_list.dart` | 269 | `MessageList, _MessageListState, MessageBubble, …` |
| `lib/features/coach_chat/presentation/widgets/model_setup_screen.dart` | 116 | `ModelSetupScreen` |
| `lib/features/coach_chat/presentation/widgets/pending_coach_action_card.dart` | 46 | `PendingCoachActionCard` |
| `lib/features/coach_chat/presentation/widgets/streaming_text_pulse.dart` | 67 | `StreamingTextPulse, _StreamingTextPulseState` |
| `lib/features/coach_chat/presentation/widgets/typing_indicator.dart` | 52 | `TypingIndicator, _TypingIndicatorState` |
| `lib/features/coach_chat/providers/active_coach_conversation_provider.dart` | 23 | `ActiveCoachConversation` |
| `lib/features/coach_chat/providers/coach_chat_provider.dart` | 736 | `CoachChat, LastAiInferenceBackend` |
| `lib/features/coach_chat/providers/coach_chat_seed_provider.dart` | 1 | `Dart module` |
| `lib/features/coach_chat/providers/coach_conversations_provider.dart` | 116 | `ActiveCoachConversationId, CoachConversations` |
| `lib/features/coach_chat/providers/last_coach_context_provider.dart` | 13 | `LastCoachContext` |
| `lib/features/coach_chat/providers/model_setup_provider.dart` | 2 | `Dart module` |
| `lib/features/coach_chat/providers/model_setup_state.dart` | 1 | `Dart module` |
| `lib/features/coach_chat/utils/chat_history_codec.dart` | 85 | `Serialises coach chat history to SharedPreferences JSON.` |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart` | 402 | `DashboardPage, _DashboardPageState` |
| `lib/features/dashboard/presentation/pages/run_history_page.dart` | 138 | `RunHistoryPage` |
| `lib/features/dashboard/presentation/pages/run_route_missing_page.dart` | 53 | `RunRouteMissingPage` |
| `lib/features/dashboard/presentation/pages/run_route_page.dart` | 183 | `RunRoutePage, _RunRouteScaffold, _RouteContent` |
| `lib/features/dashboard/presentation/widgets/activity_ring.dart` | 214 | `ActivityRing, AnimatedActivityRing, _AnimatedActivityRingState, …` |
| `lib/features/dashboard/presentation/widgets/character_glance_card.dart` | 116 | `CharacterGlanceCard` |
| `lib/features/dashboard/presentation/widgets/coach_agent_hero_card.dart` | 128 | `CoachAgentHeroCard, _PromptChip` |
| `lib/features/dashboard/presentation/widgets/coach_insight_card.dart` | 214 | `CoachInsightCard, _CoachInsightContent, _AcwrOnlyCard, …` |
| `lib/features/dashboard/presentation/widgets/connect_healthkit_card.dart` | 88 | `ConnectHealthkitCard` |
| `lib/features/dashboard/presentation/widgets/dashboard_header_sliver.dart` | 99 | `DashboardHeaderSliver` |
| `lib/features/dashboard/presentation/widgets/gait_teaser_card.dart` | 94 | `GaitTeaserCard` |
| `lib/features/dashboard/presentation/widgets/health_metrics_grid.dart` | 254 | `HealthMetricsGrid` |
| `lib/features/dashboard/presentation/widgets/hrv_sparkline.dart` | 68 | `HrvSparkline` |
| `lib/features/dashboard/presentation/widgets/last_run_preview.dart` | 76 | `LastRunPreview` |
| `lib/features/dashboard/presentation/widgets/metric_detail_sheet.dart` | 196 | `MetricDetailSheet, _MetricMeta` |
| `lib/features/dashboard/presentation/widgets/readiness_card.dart` | 216 | `ReadinessCard, _ReadinessCardContent, ConfidenceBadgeRow` |
| `lib/features/dashboard/presentation/widgets/run_detail/route_polyline_painter.dart` | 171 | `RoutePolylinePainter, _Bounds` |
| `lib/features/dashboard/presentation/widgets/run_detail/run_insight_chips.dart` | 84 | `RunInsightChips` |
| `lib/features/dashboard/presentation/widgets/run_detail/run_pace_chart.dart` | 137 | `RunPaceChart, _PaceLineChart` |
| `lib/features/dashboard/presentation/widgets/run_detail/run_route_map_section.dart` | 163 | `RunRouteMapSection, _RouteMapBody, _PolylineMap, …` |
| `lib/features/dashboard/presentation/widgets/run_detail/run_split_list.dart` | 116 | `RunSplitList, _SplitRow` |
| `lib/features/dashboard/presentation/widgets/run_detail/run_summary_metrics.dart` | 91 | `RunSummaryMetrics` |
| `lib/features/dashboard/presentation/widgets/trend_carousel.dart` | 96 | `TrendCarousel, _TrendCarouselState, _TrendPage` |
| `lib/features/dashboard/presentation/widgets/week_momentum_card.dart` | 204 | `WeekMomentumCard` |
| `lib/features/dashboard/presentation/widgets/what_changed_chips.dart` | 45 | `WhatChangedChips` |
| `lib/features/dashboard/providers/dashboard_summary_provider.dart` | 60 | `Dart module` |
| `lib/features/dashboard/providers/post_run_debrief_provider.dart` | 123 | `PostRunDebriefState, PostRunDebriefNotifier` |
| `lib/features/dashboard/providers/today_insights_provider.dart` | 54 | `TodayInsightsState` |
| `lib/features/legal/content/legal_documents.dart` | 162 | `Static legal copy bundled with the app.` |
| `lib/features/legal/models/legal_document.dart` | 27 | `LegalSection, LegalDocument` |
| `lib/features/legal/presentation/pages/privacy_policy_page.dart` | 17 | `PrivacyPolicyPage` |
| `lib/features/legal/presentation/pages/terms_of_service_page.dart` | 17 | `TermsOfServicePage` |
| `lib/features/legal/presentation/widgets/legal_document_view.dart` | 71 | `LegalDocumentView` |
| `lib/features/nexus_lab/presentation/nexus_lab_page.dart` | 211 | `NexusLabPage, _Content, _LoadingState, …` |
| `lib/features/onboarding/presentation/onboarding_page.dart` | 278 | `OnboardingItem, OnboardingPage, _OnboardingPageState, …` |
| `lib/features/onboarding/providers/onboarding_provider.dart` | 1 | `Dart module` |
| `lib/features/settings/presentation/on_device_model_capability_ui.dart` | 43 | `Shared UI mapping for [OnDeviceModelCapability] labels and theme colors.` |
| `lib/features/settings/presentation/on_device_model_selection_result.dart` | 10 | `OnDeviceModelSelectionResult` |
| `lib/features/settings/presentation/pages/health_import_page.dart` | 118 | `HealthImportPage` |
| `lib/features/settings/presentation/pages/manual_run_page.dart` | 167 | `ManualRunPage, _ManualRunPageState` |
| `lib/features/settings/presentation/pages/on_device_model_picker_page.dart` | 220 | `OnDeviceModelPickerPage, _OnDeviceModelPickerPageState, _FilterChip` |
| `lib/features/settings/presentation/pages/openrouter_model_picker_page.dart` | 215 | `OpenRouterModelPickerPage` |
| `lib/features/settings/presentation/pages/settings_page.dart` | 689 | `SettingsPage, _SettingsPageState, _SwitchTile, …` |
| `lib/features/settings/presentation/widgets/apple_health_export_preview_card.dart` | 104 | `AppleHealthExportPreviewCard` |
| `lib/features/settings/presentation/widgets/coach_personalization_card.dart` | 193 | `CoachPersonalizationCard` |
| `lib/features/settings/presentation/widgets/gpx_import_preview_card.dart` | 82 | `GpxImportPreviewCard` |
| `lib/features/settings/presentation/widgets/health_import_preview_row.dart` | 27 | `HealthImportPreviewRow` |
| `lib/features/settings/presentation/widgets/health_import_progress_card.dart` | 58 | `HealthImportProgressCard` |
| `lib/features/settings/presentation/widgets/on_device_model_card.dart` | 116 | `OnDeviceModelCard` |
| `lib/features/settings/presentation/widgets/openrouter_model_card.dart` | 80 | `OpenRouterModelCard` |
| `lib/features/settings/presentation/widgets/settings_appearance_section.dart` | 39 | `SettingsAppearanceSection` |
| `lib/features/settings/providers/health_import_provider.dart` | 280 | `HealthImportState, HealthImport` |
| `lib/features/settings/providers/manual_run_provider.dart` | 104 | `ManualRunState, ManualRun` |
| `lib/features/settings/providers/openrouter_models_provider.dart` | 121 | `OpenRouterCatalogState, OpenRouterCatalog` |
| `lib/features/settings/providers/settings_provider.dart` | 1 | `Dart module` |
| `lib/features/training/presentation/pages/training_page.dart` | 581 | `TrainingPage, _TrainingPageState, _SectionAnchor, …` |
| `lib/features/training/presentation/widgets/past_runs_list.dart` | 73 | `PastRunsList` |
| `lib/features/training/presentation/widgets/training_chip.dart` | 33 | `TrainingChip` |
| `lib/features/training/presentation/widgets/training_insight_cards.dart` | 133 | `TrainingInsightsCards` |
| `lib/features/training/presentation/widgets/training_insight_list_card.dart` | 28 | `TrainingInsightListCard` |
| `lib/features/training/presentation/widgets/training_insight_text_card.dart` | 34 | `TrainingInsightTextCard` |
| `lib/features/training/presentation/widgets/trend_cards.dart` | 76 | `TrendCards` |
| `lib/features/training/presentation/widgets/weekly_stats_grid.dart` | 86 | `WeeklyStatsGrid` |
| `lib/features/training/presentation/widgets/wellbeing_panels.dart` | 155 | `DailyHealthOverview, CheckInHistoryPanel, WellbeingExperimentsPanel` |
| `lib/features/training/providers/training_insights_provider.dart` | 56 | `TrainingInsightsState` |
| `lib/infrastructure/ai/ai_infrastructure_providers.dart` | 8 | `Provides the [AiModelRepository] singleton.` |
| `lib/infrastructure/ai/biomechanics/biomechanics_coefficients_protobuf.dart` | 169 | `BiomechanicsCoefficientsProtobuf` |
| `lib/infrastructure/ai/biomechanics/on_device_biomechanics_repository.dart` | 238 | `OnDeviceBiomechanicsRepository` |
| `lib/infrastructure/ai/gemma/ai_isolate_bridge.dart` | 3 | `Dart module` |
| `lib/infrastructure/ai/gemma/ai_isolate_entrypoint.dart` | 187 | `Dart module` |
| `lib/infrastructure/ai/gemma/ai_isolate_messages.dart` | 126 | `AiInitRequest, AiChatRequest, AiReloadChatRequest, …` |
| `lib/infrastructure/ai/gemma/ai_regression_math.dart` | 99 | `Fits multivariate regression coefficients for stride length prediction.` |
| `lib/infrastructure/ai/gemma/coach_prompt_builder.dart` | 61 | `Builds the user turn for coach chat (system instruction lives on [InferenceChat]).` |
| `lib/infrastructure/ai/gemma/gemma_device_ram_probe.dart` | 51 | `Dart module` |
| `lib/infrastructure/ai/gemma/gemma_inference_session.dart` | 91 | `Dart module` |
| `lib/infrastructure/ai/gemma/gemma_runtime.dart` | 83 | `Central bootstrap for flutter_gemma 1.x opt-in inference engines.` |
| `lib/infrastructure/ai/gemma/gemma_runtime_tier.dart` | 18 | `Resolves the current on-device Gemma tier from platform RAM and thermal probes.` |
| `lib/infrastructure/ai/gemma/gemma_thermal_probe.dart` | 19 | `Reads platform thermal / power-save signals for conservative Gemma routing.` |
| `lib/infrastructure/ai/gemma/on_device_model_installer.dart` | 24 | `Maps domain [OnDeviceModel] specs to flutter_gemma install APIs.` |
| `lib/infrastructure/ai/gemma/regression_isolate_entrypoint.dart` | 42 | `Lightweight background worker for gait regression math (no LLM deps).` |
| `lib/infrastructure/ai/hybrid_ai_coach_repository.dart` | 174 | `HybridAiCoachConfig, HybridAiCoachRepository` |
| `lib/infrastructure/ai/isolate_ai_coach_repository.dart` | 390 | `IsolateAiCoachRepository` |
| `lib/infrastructure/ai/on_device_model_repository.dart` | 94 | `OnDeviceModelRepository` |
| `lib/infrastructure/ai/openrouter/openrouter_api_client.dart` | 215 | `OpenRouterApiClient` |
| `lib/infrastructure/ai/openrouter/openrouter_cloud_ai_repository.dart` | 53 | `OpenRouterCloudAiRepository` |
| `lib/infrastructure/ai/openrouter/openrouter_models_repository_impl.dart` | 46 | `OpenRouterModelsRepositoryImpl` |
| `lib/infrastructure/ai/secure_api_key_storage.dart` | 41 | `SecureApiKeyStorage` |
| `lib/infrastructure/coach/coach_conversation_codec.dart` | 357 | `Serialises coach conversations to SharedPreferences JSON.` |
| `lib/infrastructure/coach/coach_conversation_repository_impl.dart` | 213 | `CoachConversationRepositoryImpl` |
| `lib/infrastructure/gamification/character_persistence_repository.dart` | 120 | `CharacterPersistenceRepository` |
| `lib/infrastructure/gamification/gamekit_repository_impl.dart` | 80 | `GameKitRepositoryImpl` |
| `lib/infrastructure/health/apple_workout_route_channel.dart` | 36 | `AppleWorkoutRouteChannel` |
| `lib/infrastructure/health/composite_health_repository.dart` | 195 | `CompositeHealthRepository` |
| `lib/infrastructure/health/drift_imported_health_store.dart` | 177 | `DriftImportedHealthStore` |
| `lib/infrastructure/health/health_data_aggregator.dart` | 173 | `_DailyAccumulator` |
| `lib/infrastructure/health/health_infrastructure_providers.dart` | 28 | `Dart module` |
| `lib/infrastructure/health/health_kit_repository.dart` | 251 | `HealthKitRepository` |
| `lib/infrastructure/health/health_kit_workout_mapper.dart` | 110 | `Returns true when [point] represents a running workout.` |
| `lib/infrastructure/health/health_summary_merge.dart` | 46 | `HealthSummaryMerge` |
| `lib/infrastructure/health/import/apple_health_date_parser.dart` | 22 | `Parses timestamps from Apple Health `export.xml` attributes.` |
| `lib/infrastructure/health/import/apple_health_export_isolate.dart` | 30 | `Parses Apple Health zip archives off the UI isolate.` |
| `lib/infrastructure/health/import/apple_health_export_parser.dart` | 296 | `AppleHealthWorkoutImport, AppleHealthExportParseResult, AppleHealthExportParser` |
| `lib/infrastructure/health/import/apple_health_record_aggregator.dart` | 250 | `AppleHealthRecordAggregator, _DailyAccumulator` |
| `lib/infrastructure/health/import/apple_health_unit_converter.dart` | 62 | `Converts Apple Health export units into KYNOS canonical units.` |
| `lib/infrastructure/health/import/apple_health_workout_builder.dart` | 48 | `AppleHealthWorkoutBuilder` |
| `lib/infrastructure/health/import/apple_health_xml_event_stream.dart` | 35 | `Chunk size for streaming `export.xml` without loading the full file.` |
| `lib/infrastructure/health/import/gpx_workout_parser.dart` | 78 | `GpxParseResult, GpxWorkoutParser` |
| `lib/infrastructure/health/imported_health_connection_native.dart` | 14 | `Dart module` |
| `lib/infrastructure/health/imported_health_connection_stub.dart` | 5 | `Dart module` |
| `lib/infrastructure/health/imported_health_database.dart` | 59 | `ImportedWorkouts, ImportedRoutePoints, ImportedDailySummaries, …` |
| `lib/infrastructure/health/imported_health_database_providers.dart` | 8 | `Dart module` |
| `lib/infrastructure/health/imported_health_repository.dart` | 109 | `ImportedHealthRepository` |
| `lib/infrastructure/health/imported_health_store.dart` | 124 | `Contract for locally persisted imported workouts.` |
| `lib/infrastructure/health/imported_summary_merger.dart` | 60 | `Merges imported daily summaries, preferring stored metrics and adding` |
| `lib/infrastructure/health/imported_workout_summary_aggregator.dart` | 59 | `_DayRollup` |
| `lib/infrastructure/health/platform_imported_health_store_native.dart` | 8 | `Dart module` |
| `lib/infrastructure/health/platform_imported_health_store_web.dart` | 8 | `Dart module` |
| `lib/infrastructure/health/prefs_health_coach_repository.dart` | 74 | `PrefsHealthCoachRepository` |
| `lib/infrastructure/health/prefs_imported_health_store.dart` | 162 | `PrefsImportedHealthStore` |
| `lib/infrastructure/privacy/local_sync_privacy_guard.dart` | 58 | `LocalSyncPrivacyGuard` |
| `lib/main.dart` | 39 | `Dart module` |
| `lib/shared/constants/hero_tags.dart` | 8 | `Shared Hero tag constants for cross-route transitions.` |
| `lib/shared/providers/ai_insights_usecase_provider.dart` | 23 | `Dart module` |
| `lib/shared/providers/ai_reconnect_provider.dart` | 14 | `AiReconnectState` |
| `lib/shared/providers/ai_repository_providers.dart` | 93 | `Dart module` |
| `lib/shared/providers/biomechanics_provider.dart` | 20 | `Dart module` |
| `lib/shared/providers/camp_providers.dart` | 232 | `CampViewState, CampSessionNotifier` |
| `lib/shared/providers/character_providers.dart` | 29 | `Loads the persisted [RunnerCharacter], creating one via class assignment` |
| `lib/shared/providers/coach_chat_seed_provider.dart` | 28 | `CoachChatSeed` |
| `lib/shared/providers/coach_context_provider.dart` | 103 | `Builds unified runner context for coach inference.` |
| `lib/shared/providers/coach_conversation_providers.dart` | 76 | `Dart module` |
| `lib/shared/providers/coach_personalization_provider.dart` | 74 | `CoachPersonalizationState, CoachPersonalizationNotifier` |
| `lib/shared/providers/coach_usecase_providers.dart` | 29 | `Dart module` |
| `lib/shared/providers/daily_quests_provider.dart` | 56 | `Dart module` |
| `lib/shared/providers/dashboard_summary_provider.dart` | 1 | `Dart module` |
| `lib/shared/providers/gamification_providers.dart` | 73 | `Dart module` |
| `lib/shared/providers/gemma_tier_provider.dart` | 8 | `Resolves the current on-device Gemma inference tier for UI routing decisions.` |
| `lib/shared/providers/health_coach_providers.dart` | 215 | `HealthCoachData` |
| `lib/shared/providers/health_import_providers.dart` | 23 | `Dart module` |
| `lib/shared/providers/health_providers.dart` | 148 | `HealthPermissionsNotifier, ImportedHealthDataNotifier` |
| `lib/shared/providers/health_repository_provider.dart` | 15 | `Dart module` |
| `lib/shared/providers/huggingface_token_provider.dart` | 25 | `HuggingFaceTokenManager` |
| `lib/shared/providers/measurable_quest_sync_provider.dart` | 79 | `MeasurableQuestSync` |
| `lib/shared/providers/model_setup_provider.dart` | 121 | `MissingHuggingFaceTokenException, ModelSetupNotifier` |
| `lib/shared/providers/model_setup_state.dart` | 17 | `ModelSetupState` |
| `lib/shared/providers/nexus_lab_provider.dart` | 74 | `NexusLabState, NexusLabNotifier` |
| `lib/shared/providers/onboarding_provider.dart` | 27 | `OnboardingCompleted` |
| `lib/shared/providers/openrouter_api_key_provider.dart` | 28 | `OpenRouterApiKeyManager` |
| `lib/shared/providers/post_run_debrief_provider.dart` | 1 | `Dart module` |
| `lib/shared/providers/settings_provider.dart` | 186 | `SettingsState, Settings` |
| `lib/shared/providers/shared_preferences_provider.dart` | 12 | `Synchronously accessible [SharedPreferences] — override at app startup.` |
| `lib/shared/providers/today_insights_provider.dart` | 1 | `Dart module` |
| `lib/shared/providers/training_insights_provider.dart` | 1 | `Dart module` |
| `lib/shared/providers/workout_session_lookup_provider.dart` | 16 | `Resolves a [WorkoutSession] by id for deep-linked run routes.` |
| `lib/shared/utils/date_label.dart` | 20 | `Formats today's date as "Mon, Jan 5".` |
| `lib/shared/utils/health_permission_feedback.dart` | 14 | `User-facing copy for health permission flows — never expose raw exceptions.` |
| `lib/shared/utils/health_platform_labels.dart` | 41 | `Platform-aware labels for health data sources.` |
| `lib/shared/utils/insight_text_formatter.dart` | 48 | `Formats coaching insight text for concise, beginner-friendly UI labels.` |
| `lib/shared/utils/navigation_utils.dart` | 11 | `Pops the current route or navigates to [fallbackRoute] when nothing to pop.` |
| `lib/shared/utils/open_coach_chat.dart` | 37 | `Opens coach chat with an optional structured seed.` |
| `lib/shared/utils/picked_file_bytes.dart` | 2 | `Dart module` |
| `lib/shared/utils/picked_file_bytes_io.dart` | 15 | `Dart module` |
| `lib/shared/utils/picked_file_bytes_web.dart` | 9 | `Dart module` |
| `lib/shared/utils/run_date_label.dart` | 18 | `Formats a workout date for run cards and Hero transitions.` |
| `lib/shared/utils/url_opener.dart` | 20 | `Opens an external URL in the platform browser.` |
| `lib/shared/widgets/ai_lifecycle_guard.dart` | 74 | `AiLifecycleGuard, _AiLifecycleGuardState` |
| `lib/shared/widgets/animated_async_content.dart` | 84 | `AnimatedAsyncContent, FadeInOnAppear, _FadeInOnAppearState` |
| `lib/shared/widgets/animated_progress_bar.dart` | 43 | `AnimatedProgressBar` |
| `lib/shared/widgets/charts/chart_placeholder.dart` | 15 | `ChartPlaceholder` |
| `lib/shared/widgets/charts/health_trend_chart.dart` | 279 | `HealthTrendPoint, HealthTrendChart, _HealthTrendChartState` |
| `lib/shared/widgets/charts/hrv_chart.dart` | 86 | `HrvChart` |
| `lib/shared/widgets/charts/load_chart.dart` | 85 | `LoadChart` |
| `lib/shared/widgets/daily_quest_teaser.dart` | 129 | `DailyQuestTeaser` |
| `lib/shared/widgets/gait_model_card.dart` | 247 | `GaitModelCard, _CoefficientsRow, GaitModelCardAsync` |
| `lib/shared/widgets/glass_card.dart` | 43 | `GlassCard` |
| `lib/shared/widgets/insight_expandable_card.dart` | 221 | `InsightExpandableCard, _InsightExpandableCardState, InsightTextExpandableCard, …` |
| `lib/shared/widgets/kynos_bottom_nav.dart` | 185 | `KynosBottomNavItem, KynosBottomNav, _NavBarItem` |
| `lib/shared/widgets/kynos_card.dart` | 57 | `KynosCard` |
| `lib/shared/widgets/kynos_chip.dart` | 128 | `KynosChip, _MetricChip, _AccentChip` |
| `lib/shared/widgets/kynos_collapsible_section.dart` | 105 | `KynosCollapsibleSection, _KynosCollapsibleSectionState` |
| `lib/shared/widgets/kynos_floating_nav.dart` | 593 | `KynosFloatingNavItem, KynosFloatingNavAction, KynosFloatingNav, …` |
| `lib/shared/widgets/kynos_hero_banner.dart` | 125 | `KynosHeroBanner` |
| `lib/shared/widgets/kynos_inline_error_card.dart` | 53 | `KynosInlineErrorCard` |
| `lib/shared/widgets/kynos_loading_line.dart` | 59 | `KynosLoadingLine` |
| `lib/shared/widgets/kynos_page_dots.dart` | 45 | `KynosPageDots` |
| `lib/shared/widgets/kynos_page_header.dart` | 101 | `KynosPageHeader` |
| `lib/shared/widgets/kynos_privacy_footer.dart` | 25 | `KynosPrivacyFooter` |
| `lib/shared/widgets/kynos_section_header.dart` | 21 | `KynosSectionHeader` |
| `lib/shared/widgets/kynos_section_jump_bar.dart` | 87 | `KynosSectionJumpBar, _JumpChip` |
| `lib/shared/widgets/kynos_section_row.dart` | 38 | `KynosSectionRow` |
| `lib/shared/widgets/kynos_segmented_control.dart` | 98 | `KynosSegmentedControl, _Segment` |
| `lib/shared/widgets/kynos_skeleton.dart` | 41 | `KynosSkeleton` |
| `lib/shared/widgets/kynos_user_bubble.dart` | 57 | `KynosUserBubble` |
| `lib/shared/widgets/liquid_glass_button.dart` | 142 | `LiquidGlassButton, LiquidGlassIconButton` |
| `lib/shared/widgets/liquid_glass_surface.dart` | 103 | `LiquidGlassSurface` |
| `lib/shared/widgets/metric_tile.dart` | 131 | `MetricTile` |
| `lib/shared/widgets/nav_icon.dart` | 238 | `NavIconDefinition, NavIconPainter` |
| `lib/shared/widgets/responsive_center.dart` | 30 | `ResponsiveCenter` |
| `lib/shared/widgets/run_card.dart` | 113 | `RunCard` |
| `lib/shared/widgets/widgets.dart` | 30 | `KYNOS shared widgets — barrel export.` |

## Hot Files (do not grow)

| File | Lines | Target |
|------|------:|--------|
| `lib/features/coach_chat/providers/coach_chat_provider.dart` | 736 | Split if > 250 lines |
| `lib/features/settings/presentation/pages/settings_page.dart` | 689 | Split if > 250 lines |
| `lib/shared/widgets/kynos_floating_nav.dart` | 593 | Split if > 250 lines |
| `lib/features/training/presentation/pages/training_page.dart` | 581 | Split if > 250 lines |
| `lib/domain/usecases/coach/coach_tool_health_queries.dart` | 521 | Split if > 250 lines |
| `lib/features/coach_chat/presentation/pages/coach_chat_page.dart` | 426 | Split if > 250 lines |
| `lib/features/coach_chat/presentation/widgets/health_visual_artifact_card.dart` | 404 | Split if > 250 lines |
| `lib/features/dashboard/presentation/pages/dashboard_page.dart` | 402 | Split if > 250 lines |
| `lib/infrastructure/ai/isolate_ai_coach_repository.dart` | 390 | Split if > 250 lines |
| `lib/domain/usecases/coach/coach_tool_wellbeing_queries.dart` | 387 | Split if > 250 lines |
| `lib/infrastructure/coach/coach_conversation_codec.dart` | 357 | Split if > 250 lines |
| `lib/features/character/presentation/pages/character_page.dart` | 302 | Split if > 250 lines |
| `lib/infrastructure/health/import/apple_health_export_parser.dart` | 296 | Split if > 250 lines |
| `lib/domain/usecases/insights/generate_training_insights_usecase.dart` | 287 | Split if > 250 lines |
| `lib/features/settings/providers/health_import_provider.dart` | 280 | Split if > 250 lines |
| `lib/shared/widgets/charts/health_trend_chart.dart` | 279 | Split if > 250 lines |
| `lib/features/onboarding/presentation/onboarding_page.dart` | 278 | Split if > 250 lines |
| `lib/domain/catalog/on_device_model_catalog.dart` | 275 | Split if > 250 lines |
| `lib/domain/utils/run_route_analytics.dart` | 274 | Split if > 250 lines |
| `lib/features/character/presentation/widgets/quest_card.dart` | 269 | Split if > 250 lines |

_Generated by `dart run tool/generate_codemap.dart` — 386 hand-written Dart files._

<!-- CODEMAP_AUTO_END -->
