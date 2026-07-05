import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/infrastructure/health/imported_health_database.dart';

final importedHealthDatabaseProvider = Provider<ImportedHealthDatabase>((ref) {
  final db = ImportedHealthDatabase(openImportedHealthConnection());
  ref.onDispose(db.close);
  return db;
});
