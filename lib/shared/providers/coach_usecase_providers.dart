import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/usecases/coach/build_coach_context_usecase.dart';
import 'package:kynos/domain/usecases/coach/send_coach_message_usecase.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';

final buildCoachContextUseCaseProvider = Provider<BuildCoachContextUseCase>(
  (ref) => const BuildCoachContextUseCase(),
);

final sendCoachMessageUseCaseProvider = Provider<SendCoachMessageUseCase>(
  (ref) => SendCoachMessageUseCase(
    aiCoachRepository: ref.watch(chatAiCoachRepositoryProvider),
  ),
);
