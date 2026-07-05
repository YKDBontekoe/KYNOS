import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/usecases/insights/generate_today_insights_usecase.dart';
import 'package:kynos/domain/usecases/insights/generate_training_insights_usecase.dart';
import 'package:kynos/shared/providers/ai_repository_providers.dart';
import 'package:kynos/shared/providers/health_providers.dart';

final generateTodayInsightsUseCaseProvider =
    Provider<GenerateTodayInsightsUseCase>((ref) {
      return GenerateTodayInsightsUseCase(
        healthRepository: ref.watch(healthRepositoryProvider),
        aiCoachRepository: ref.watch(aiCoachRepositoryProvider),
        aiModelRepository: ref.watch(aiModelRepositoryProvider),
      );
    });

final generateTrainingInsightsUseCaseProvider =
    Provider<GenerateTrainingInsightsUseCase>((ref) {
      return GenerateTrainingInsightsUseCase(
        healthRepository: ref.watch(healthRepositoryProvider),
        aiCoachRepository: ref.watch(aiCoachRepositoryProvider),
        aiModelRepository: ref.watch(aiModelRepositoryProvider),
      );
    });
