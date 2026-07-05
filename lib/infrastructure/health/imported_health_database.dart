import 'package:drift/drift.dart';
import 'package:kynos/infrastructure/health/imported_health_connection_stub.dart'
    if (dart.library.io) 'package:kynos/infrastructure/health/imported_health_connection_native.dart';

part 'imported_health_database.g.dart';

class ImportedWorkouts extends Table {
  TextColumn get id => text()();
  DateTimeColumn get start => dateTime()();
  DateTimeColumn get end => dateTime()();
  TextColumn get workoutType => text()();
  RealColumn get distanceMeters => real().nullable()();
  RealColumn get energyKcal => real().nullable()();
  IntColumn get steps => integer().nullable()();
  TextColumn get sourceName => text()();
  RealColumn get startLatitude => real().nullable()();
  RealColumn get startLongitude => real().nullable()();
  RealColumn get endLatitude => real().nullable()();
  RealColumn get endLongitude => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ImportedRoutePoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get workoutId => text().references(ImportedWorkouts, #id)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get timestamp => dateTime().nullable()();
  IntColumn get sequence => integer()();
}

class ImportedDailySummaries extends Table {
  DateTimeColumn get date => dateTime()();
  TextColumn get payload => text()();

  @override
  Set<Column<Object>> get primaryKey => {date};
}

@DriftDatabase(tables: [ImportedWorkouts, ImportedRoutePoints, ImportedDailySummaries])
class ImportedHealthDatabase extends _$ImportedHealthDatabase {
  ImportedHealthDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(importedDailySummaries);
          }
        },
      );
}

QueryExecutor openImportedHealthConnection() => createImportedHealthConnection();
