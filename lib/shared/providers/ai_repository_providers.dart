// Bridge: exposes AI infrastructure providers to the feature layer.
// Features must import from here; never from infrastructure directly.
export 'package:kynos/infrastructure/ai/ai_infrastructure_providers.dart'
    show aiCoachRepositoryProvider, aiModelRepositoryProvider;
