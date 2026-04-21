// Re-exports infrastructure AI providers through the shared/providers path.
// Features must import from here — never directly from lib/infrastructure/.
export 'package:kynos/infrastructure/ai/ai_infrastructure_providers.dart'
    show aiCoachRepositoryProvider, aiModelRepositoryProvider;
