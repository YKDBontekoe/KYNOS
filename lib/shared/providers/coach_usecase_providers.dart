import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/usecases/coach/build_coach_context_usecase.dart';
import 'package:kynos/domain/usecases/coach/build_daily_coach_brief_usecase.dart';
import 'package:kynos/domain/usecases/coach/build_morning_fact_pack_usecase.dart';
import 'package:kynos/domain/usecases/coach/build_proactive_health_agent_run_usecase.dart';
import 'package:kynos/domain/usecases/coach/build_today_directive_usecase.dart';
import 'package:kynos/domain/usecases/coach/execute_coach_tool_usecase.dart';
import 'package:kynos/domain/usecases/coach/propose_training_plan_usecase.dart';
import 'package:kynos/domain/usecases/coach/send_coach_message_usecase.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';

final buildCoachContextUseCaseProvider = Provider<BuildCoachContextUseCase>(
  (ref) => const BuildCoachContextUseCase(),
);

final buildDailyCoachBriefUseCaseProvider =
    Provider<BuildDailyCoachBriefUseCase>(
      (ref) => const BuildDailyCoachBriefUseCase(),
    );

final buildTodayDirectiveUseCaseProvider = Provider<BuildTodayDirectiveUseCase>(
  (ref) => const BuildTodayDirectiveUseCase(),
);

final buildMorningFactPackUseCaseProvider =
    Provider<BuildMorningFactPackUseCase>(
      (ref) => const BuildMorningFactPackUseCase(),
    );

final buildProactiveHealthAgentRunUseCaseProvider =
    Provider<BuildProactiveHealthAgentRunUseCase>(
      (ref) => const BuildProactiveHealthAgentRunUseCase(),
    );

final proposeTrainingPlanUseCaseProvider = Provider<ProposeTrainingPlanUseCase>(
  (ref) => const ProposeTrainingPlanUseCase(),
);

final sendCoachMessageUseCaseProvider = Provider<SendCoachMessageUseCase>(
  (ref) => SendCoachMessageUseCase(
    aiCoachRepository: ref.watch(chatAiCoachRepositoryProvider),
  ),
);

/// Executes agentic coach tool calls (see [ExecuteCoachToolUseCase]).
final executeCoachToolUseCaseProvider = Provider<ExecuteCoachToolUseCase>(
  (ref) => ExecuteCoachToolUseCase(
    healthRepository: ref.watch(healthRepositoryProvider),
  ),
);
