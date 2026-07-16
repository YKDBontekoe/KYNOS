import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/usecases/coach/build_proactive_health_agent_run_usecase.dart';
import 'package:kynos/shared/providers/coach_context_provider.dart';
import 'package:kynos/shared/providers/coach_usecase_providers.dart';

/// Deterministic proactive coaching runs for the coach home empty state.
final proactiveHealthAgentRunsProvider =
    FutureProvider.autoDispose<List<ProactiveHealthAgentRun>>((ref) async {
  final context = await ref.watch(coachContextProvider.future);
  return ref
      .read(buildProactiveHealthAgentRunUseCaseProvider)
      .buildHomeRuns(context: context);
});
