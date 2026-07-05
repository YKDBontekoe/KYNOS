import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';
import 'package:kynos/infrastructure/health/imported_health_store.dart';
import 'package:kynos/infrastructure/health/prefs_imported_health_store.dart';

ImportedHealthStore createPlatformImportedHealthStore(Ref ref) {
  return PrefsImportedHealthStore(ref.watch(sharedPreferencesProvider));
}
