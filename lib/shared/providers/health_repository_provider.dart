// Legacy re-export — prefer [healthRepositoryProvider] from health_providers.dart.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/health_repository.dart';
import 'package:kynos/shared/providers/health_providers.dart';

export 'package:kynos/shared/providers/health_providers.dart'
    show healthRepositoryProvider;

/// @deprecated Use [healthRepositoryProvider] instead.
@Deprecated('Use healthRepositoryProvider from health_providers.dart instead.')
final sharedHealthRepositoryProvider = Provider<HealthRepository>((ref) {
  return ref.watch(healthRepositoryProvider);
});
