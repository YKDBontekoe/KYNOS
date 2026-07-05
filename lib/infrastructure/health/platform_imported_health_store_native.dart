import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/infrastructure/health/drift_imported_health_store.dart';
import 'package:kynos/infrastructure/health/imported_health_database_providers.dart';
import 'package:kynos/infrastructure/health/imported_health_store.dart';

ImportedHealthStore createPlatformImportedHealthStore(Ref ref) {
  return DriftImportedHealthStore(ref.watch(importedHealthDatabaseProvider));
}
