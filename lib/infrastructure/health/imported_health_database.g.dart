// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imported_health_database.dart';

// ignore_for_file: type=lint
class $ImportedWorkoutsTable extends ImportedWorkouts
    with TableInfo<$ImportedWorkoutsTable, ImportedWorkout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportedWorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<DateTime> start = GeneratedColumn<DateTime>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<DateTime> end = GeneratedColumn<DateTime>(
    'end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutTypeMeta = const VerificationMeta(
    'workoutType',
  );
  @override
  late final GeneratedColumn<String> workoutType = GeneratedColumn<String>(
    'workout_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyKcalMeta = const VerificationMeta(
    'energyKcal',
  );
  @override
  late final GeneratedColumn<double> energyKcal = GeneratedColumn<double>(
    'energy_kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startLatitudeMeta = const VerificationMeta(
    'startLatitude',
  );
  @override
  late final GeneratedColumn<double> startLatitude = GeneratedColumn<double>(
    'start_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startLongitudeMeta = const VerificationMeta(
    'startLongitude',
  );
  @override
  late final GeneratedColumn<double> startLongitude = GeneratedColumn<double>(
    'start_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endLatitudeMeta = const VerificationMeta(
    'endLatitude',
  );
  @override
  late final GeneratedColumn<double> endLatitude = GeneratedColumn<double>(
    'end_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endLongitudeMeta = const VerificationMeta(
    'endLongitude',
  );
  @override
  late final GeneratedColumn<double> endLongitude = GeneratedColumn<double>(
    'end_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    start,
    end,
    workoutType,
    distanceMeters,
    energyKcal,
    steps,
    sourceName,
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imported_workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportedWorkout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    if (data.containsKey('workout_type')) {
      context.handle(
        _workoutTypeMeta,
        workoutType.isAcceptableOrUnknown(
          data['workout_type']!,
          _workoutTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutTypeMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('energy_kcal')) {
      context.handle(
        _energyKcalMeta,
        energyKcal.isAcceptableOrUnknown(data['energy_kcal']!, _energyKcalMeta),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('start_latitude')) {
      context.handle(
        _startLatitudeMeta,
        startLatitude.isAcceptableOrUnknown(
          data['start_latitude']!,
          _startLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('start_longitude')) {
      context.handle(
        _startLongitudeMeta,
        startLongitude.isAcceptableOrUnknown(
          data['start_longitude']!,
          _startLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('end_latitude')) {
      context.handle(
        _endLatitudeMeta,
        endLatitude.isAcceptableOrUnknown(
          data['end_latitude']!,
          _endLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('end_longitude')) {
      context.handle(
        _endLongitudeMeta,
        endLongitude.isAcceptableOrUnknown(
          data['end_longitude']!,
          _endLongitudeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportedWorkout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportedWorkout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start'],
      )!,
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end'],
      )!,
      workoutType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_type'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      ),
      energyKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy_kcal'],
      ),
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      ),
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      )!,
      startLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_latitude'],
      ),
      startLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_longitude'],
      ),
      endLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_latitude'],
      ),
      endLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_longitude'],
      ),
    );
  }

  @override
  $ImportedWorkoutsTable createAlias(String alias) {
    return $ImportedWorkoutsTable(attachedDatabase, alias);
  }
}

class ImportedWorkout extends DataClass implements Insertable<ImportedWorkout> {
  final String id;
  final DateTime start;
  final DateTime end;
  final String workoutType;
  final double? distanceMeters;
  final double? energyKcal;
  final int? steps;
  final String sourceName;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  const ImportedWorkout({
    required this.id,
    required this.start,
    required this.end,
    required this.workoutType,
    this.distanceMeters,
    this.energyKcal,
    this.steps,
    required this.sourceName,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start'] = Variable<DateTime>(start);
    map['end'] = Variable<DateTime>(end);
    map['workout_type'] = Variable<String>(workoutType);
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<double>(distanceMeters);
    }
    if (!nullToAbsent || energyKcal != null) {
      map['energy_kcal'] = Variable<double>(energyKcal);
    }
    if (!nullToAbsent || steps != null) {
      map['steps'] = Variable<int>(steps);
    }
    map['source_name'] = Variable<String>(sourceName);
    if (!nullToAbsent || startLatitude != null) {
      map['start_latitude'] = Variable<double>(startLatitude);
    }
    if (!nullToAbsent || startLongitude != null) {
      map['start_longitude'] = Variable<double>(startLongitude);
    }
    if (!nullToAbsent || endLatitude != null) {
      map['end_latitude'] = Variable<double>(endLatitude);
    }
    if (!nullToAbsent || endLongitude != null) {
      map['end_longitude'] = Variable<double>(endLongitude);
    }
    return map;
  }

  ImportedWorkoutsCompanion toCompanion(bool nullToAbsent) {
    return ImportedWorkoutsCompanion(
      id: Value(id),
      start: Value(start),
      end: Value(end),
      workoutType: Value(workoutType),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      energyKcal: energyKcal == null && nullToAbsent
          ? const Value.absent()
          : Value(energyKcal),
      steps: steps == null && nullToAbsent
          ? const Value.absent()
          : Value(steps),
      sourceName: Value(sourceName),
      startLatitude: startLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(startLatitude),
      startLongitude: startLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(startLongitude),
      endLatitude: endLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(endLatitude),
      endLongitude: endLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(endLongitude),
    );
  }

  factory ImportedWorkout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportedWorkout(
      id: serializer.fromJson<String>(json['id']),
      start: serializer.fromJson<DateTime>(json['start']),
      end: serializer.fromJson<DateTime>(json['end']),
      workoutType: serializer.fromJson<String>(json['workoutType']),
      distanceMeters: serializer.fromJson<double?>(json['distanceMeters']),
      energyKcal: serializer.fromJson<double?>(json['energyKcal']),
      steps: serializer.fromJson<int?>(json['steps']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      startLatitude: serializer.fromJson<double?>(json['startLatitude']),
      startLongitude: serializer.fromJson<double?>(json['startLongitude']),
      endLatitude: serializer.fromJson<double?>(json['endLatitude']),
      endLongitude: serializer.fromJson<double?>(json['endLongitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'start': serializer.toJson<DateTime>(start),
      'end': serializer.toJson<DateTime>(end),
      'workoutType': serializer.toJson<String>(workoutType),
      'distanceMeters': serializer.toJson<double?>(distanceMeters),
      'energyKcal': serializer.toJson<double?>(energyKcal),
      'steps': serializer.toJson<int?>(steps),
      'sourceName': serializer.toJson<String>(sourceName),
      'startLatitude': serializer.toJson<double?>(startLatitude),
      'startLongitude': serializer.toJson<double?>(startLongitude),
      'endLatitude': serializer.toJson<double?>(endLatitude),
      'endLongitude': serializer.toJson<double?>(endLongitude),
    };
  }

  ImportedWorkout copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    String? workoutType,
    Value<double?> distanceMeters = const Value.absent(),
    Value<double?> energyKcal = const Value.absent(),
    Value<int?> steps = const Value.absent(),
    String? sourceName,
    Value<double?> startLatitude = const Value.absent(),
    Value<double?> startLongitude = const Value.absent(),
    Value<double?> endLatitude = const Value.absent(),
    Value<double?> endLongitude = const Value.absent(),
  }) => ImportedWorkout(
    id: id ?? this.id,
    start: start ?? this.start,
    end: end ?? this.end,
    workoutType: workoutType ?? this.workoutType,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    energyKcal: energyKcal.present ? energyKcal.value : this.energyKcal,
    steps: steps.present ? steps.value : this.steps,
    sourceName: sourceName ?? this.sourceName,
    startLatitude: startLatitude.present
        ? startLatitude.value
        : this.startLatitude,
    startLongitude: startLongitude.present
        ? startLongitude.value
        : this.startLongitude,
    endLatitude: endLatitude.present ? endLatitude.value : this.endLatitude,
    endLongitude: endLongitude.present ? endLongitude.value : this.endLongitude,
  );
  ImportedWorkout copyWithCompanion(ImportedWorkoutsCompanion data) {
    return ImportedWorkout(
      id: data.id.present ? data.id.value : this.id,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
      workoutType: data.workoutType.present
          ? data.workoutType.value
          : this.workoutType,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      energyKcal: data.energyKcal.present
          ? data.energyKcal.value
          : this.energyKcal,
      steps: data.steps.present ? data.steps.value : this.steps,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      startLatitude: data.startLatitude.present
          ? data.startLatitude.value
          : this.startLatitude,
      startLongitude: data.startLongitude.present
          ? data.startLongitude.value
          : this.startLongitude,
      endLatitude: data.endLatitude.present
          ? data.endLatitude.value
          : this.endLatitude,
      endLongitude: data.endLongitude.present
          ? data.endLongitude.value
          : this.endLongitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportedWorkout(')
          ..write('id: $id, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('workoutType: $workoutType, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('steps: $steps, ')
          ..write('sourceName: $sourceName, ')
          ..write('startLatitude: $startLatitude, ')
          ..write('startLongitude: $startLongitude, ')
          ..write('endLatitude: $endLatitude, ')
          ..write('endLongitude: $endLongitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    start,
    end,
    workoutType,
    distanceMeters,
    energyKcal,
    steps,
    sourceName,
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportedWorkout &&
          other.id == this.id &&
          other.start == this.start &&
          other.end == this.end &&
          other.workoutType == this.workoutType &&
          other.distanceMeters == this.distanceMeters &&
          other.energyKcal == this.energyKcal &&
          other.steps == this.steps &&
          other.sourceName == this.sourceName &&
          other.startLatitude == this.startLatitude &&
          other.startLongitude == this.startLongitude &&
          other.endLatitude == this.endLatitude &&
          other.endLongitude == this.endLongitude);
}

class ImportedWorkoutsCompanion extends UpdateCompanion<ImportedWorkout> {
  final Value<String> id;
  final Value<DateTime> start;
  final Value<DateTime> end;
  final Value<String> workoutType;
  final Value<double?> distanceMeters;
  final Value<double?> energyKcal;
  final Value<int?> steps;
  final Value<String> sourceName;
  final Value<double?> startLatitude;
  final Value<double?> startLongitude;
  final Value<double?> endLatitude;
  final Value<double?> endLongitude;
  final Value<int> rowid;
  const ImportedWorkoutsCompanion({
    this.id = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
    this.workoutType = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.energyKcal = const Value.absent(),
    this.steps = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.startLatitude = const Value.absent(),
    this.startLongitude = const Value.absent(),
    this.endLatitude = const Value.absent(),
    this.endLongitude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportedWorkoutsCompanion.insert({
    required String id,
    required DateTime start,
    required DateTime end,
    required String workoutType,
    this.distanceMeters = const Value.absent(),
    this.energyKcal = const Value.absent(),
    this.steps = const Value.absent(),
    required String sourceName,
    this.startLatitude = const Value.absent(),
    this.startLongitude = const Value.absent(),
    this.endLatitude = const Value.absent(),
    this.endLongitude = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       start = Value(start),
       end = Value(end),
       workoutType = Value(workoutType),
       sourceName = Value(sourceName);
  static Insertable<ImportedWorkout> custom({
    Expression<String>? id,
    Expression<DateTime>? start,
    Expression<DateTime>? end,
    Expression<String>? workoutType,
    Expression<double>? distanceMeters,
    Expression<double>? energyKcal,
    Expression<int>? steps,
    Expression<String>? sourceName,
    Expression<double>? startLatitude,
    Expression<double>? startLongitude,
    Expression<double>? endLatitude,
    Expression<double>? endLongitude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (workoutType != null) 'workout_type': workoutType,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (energyKcal != null) 'energy_kcal': energyKcal,
      if (steps != null) 'steps': steps,
      if (sourceName != null) 'source_name': sourceName,
      if (startLatitude != null) 'start_latitude': startLatitude,
      if (startLongitude != null) 'start_longitude': startLongitude,
      if (endLatitude != null) 'end_latitude': endLatitude,
      if (endLongitude != null) 'end_longitude': endLongitude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportedWorkoutsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? start,
    Value<DateTime>? end,
    Value<String>? workoutType,
    Value<double?>? distanceMeters,
    Value<double?>? energyKcal,
    Value<int?>? steps,
    Value<String>? sourceName,
    Value<double?>? startLatitude,
    Value<double?>? startLongitude,
    Value<double?>? endLatitude,
    Value<double?>? endLongitude,
    Value<int>? rowid,
  }) {
    return ImportedWorkoutsCompanion(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      workoutType: workoutType ?? this.workoutType,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      energyKcal: energyKcal ?? this.energyKcal,
      steps: steps ?? this.steps,
      sourceName: sourceName ?? this.sourceName,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (start.present) {
      map['start'] = Variable<DateTime>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<DateTime>(end.value);
    }
    if (workoutType.present) {
      map['workout_type'] = Variable<String>(workoutType.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (energyKcal.present) {
      map['energy_kcal'] = Variable<double>(energyKcal.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (startLatitude.present) {
      map['start_latitude'] = Variable<double>(startLatitude.value);
    }
    if (startLongitude.present) {
      map['start_longitude'] = Variable<double>(startLongitude.value);
    }
    if (endLatitude.present) {
      map['end_latitude'] = Variable<double>(endLatitude.value);
    }
    if (endLongitude.present) {
      map['end_longitude'] = Variable<double>(endLongitude.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportedWorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('workoutType: $workoutType, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('steps: $steps, ')
          ..write('sourceName: $sourceName, ')
          ..write('startLatitude: $startLatitude, ')
          ..write('startLongitude: $startLongitude, ')
          ..write('endLatitude: $endLatitude, ')
          ..write('endLongitude: $endLongitude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportedRoutePointsTable extends ImportedRoutePoints
    with TableInfo<$ImportedRoutePointsTable, ImportedRoutePoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportedRoutePointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imported_workouts (id)',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    latitude,
    longitude,
    timestamp,
    sequence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imported_route_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportedRoutePoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportedRoutePoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportedRoutePoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      ),
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
    );
  }

  @override
  $ImportedRoutePointsTable createAlias(String alias) {
    return $ImportedRoutePointsTable(attachedDatabase, alias);
  }
}

class ImportedRoutePoint extends DataClass
    implements Insertable<ImportedRoutePoint> {
  final int id;
  final String workoutId;
  final double latitude;
  final double longitude;
  final DateTime? timestamp;
  final int sequence;
  const ImportedRoutePoint({
    required this.id,
    required this.workoutId,
    required this.latitude,
    required this.longitude,
    this.timestamp,
    required this.sequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_id'] = Variable<String>(workoutId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<DateTime>(timestamp);
    }
    map['sequence'] = Variable<int>(sequence);
    return map;
  }

  ImportedRoutePointsCompanion toCompanion(bool nullToAbsent) {
    return ImportedRoutePointsCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      sequence: Value(sequence),
    );
  }

  factory ImportedRoutePoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportedRoutePoint(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      timestamp: serializer.fromJson<DateTime?>(json['timestamp']),
      sequence: serializer.fromJson<int>(json['sequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutId': serializer.toJson<String>(workoutId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'timestamp': serializer.toJson<DateTime?>(timestamp),
      'sequence': serializer.toJson<int>(sequence),
    };
  }

  ImportedRoutePoint copyWith({
    int? id,
    String? workoutId,
    double? latitude,
    double? longitude,
    Value<DateTime?> timestamp = const Value.absent(),
    int? sequence,
  }) => ImportedRoutePoint(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    timestamp: timestamp.present ? timestamp.value : this.timestamp,
    sequence: sequence ?? this.sequence,
  );
  ImportedRoutePoint copyWithCompanion(ImportedRoutePointsCompanion data) {
    return ImportedRoutePoint(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportedRoutePoint(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workoutId, latitude, longitude, timestamp, sequence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportedRoutePoint &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timestamp == this.timestamp &&
          other.sequence == this.sequence);
}

class ImportedRoutePointsCompanion extends UpdateCompanion<ImportedRoutePoint> {
  final Value<int> id;
  final Value<String> workoutId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime?> timestamp;
  final Value<int> sequence;
  const ImportedRoutePointsCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.sequence = const Value.absent(),
  });
  ImportedRoutePointsCompanion.insert({
    this.id = const Value.absent(),
    required String workoutId,
    required double latitude,
    required double longitude,
    this.timestamp = const Value.absent(),
    required int sequence,
  }) : workoutId = Value(workoutId),
       latitude = Value(latitude),
       longitude = Value(longitude),
       sequence = Value(sequence);
  static Insertable<ImportedRoutePoint> custom({
    Expression<int>? id,
    Expression<String>? workoutId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? timestamp,
    Expression<int>? sequence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp,
      if (sequence != null) 'sequence': sequence,
    });
  }

  ImportedRoutePointsCompanion copyWith({
    Value<int>? id,
    Value<String>? workoutId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime?>? timestamp,
    Value<int>? sequence,
  }) {
    return ImportedRoutePointsCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      sequence: sequence ?? this.sequence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportedRoutePointsCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }
}

class $ImportedDailySummariesTable extends ImportedDailySummaries
    with TableInfo<$ImportedDailySummariesTable, ImportedDailySummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportedDailySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [date, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imported_daily_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportedDailySummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  ImportedDailySummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportedDailySummary(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $ImportedDailySummariesTable createAlias(String alias) {
    return $ImportedDailySummariesTable(attachedDatabase, alias);
  }
}

class ImportedDailySummary extends DataClass
    implements Insertable<ImportedDailySummary> {
  final DateTime date;
  final String payload;
  const ImportedDailySummary({required this.date, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  ImportedDailySummariesCompanion toCompanion(bool nullToAbsent) {
    return ImportedDailySummariesCompanion(
      date: Value(date),
      payload: Value(payload),
    );
  }

  factory ImportedDailySummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportedDailySummary(
      date: serializer.fromJson<DateTime>(json['date']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'payload': serializer.toJson<String>(payload),
    };
  }

  ImportedDailySummary copyWith({DateTime? date, String? payload}) =>
      ImportedDailySummary(
        date: date ?? this.date,
        payload: payload ?? this.payload,
      );
  ImportedDailySummary copyWithCompanion(ImportedDailySummariesCompanion data) {
    return ImportedDailySummary(
      date: data.date.present ? data.date.value : this.date,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportedDailySummary(')
          ..write('date: $date, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportedDailySummary &&
          other.date == this.date &&
          other.payload == this.payload);
}

class ImportedDailySummariesCompanion
    extends UpdateCompanion<ImportedDailySummary> {
  final Value<DateTime> date;
  final Value<String> payload;
  final Value<int> rowid;
  const ImportedDailySummariesCompanion({
    this.date = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportedDailySummariesCompanion.insert({
    required DateTime date,
    required String payload,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       payload = Value(payload);
  static Insertable<ImportedDailySummary> custom({
    Expression<DateTime>? date,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportedDailySummariesCompanion copyWith({
    Value<DateTime>? date,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return ImportedDailySummariesCompanion(
      date: date ?? this.date,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportedDailySummariesCompanion(')
          ..write('date: $date, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ImportedHealthDatabase extends GeneratedDatabase {
  _$ImportedHealthDatabase(QueryExecutor e) : super(e);
  $ImportedHealthDatabaseManager get managers =>
      $ImportedHealthDatabaseManager(this);
  late final $ImportedWorkoutsTable importedWorkouts = $ImportedWorkoutsTable(
    this,
  );
  late final $ImportedRoutePointsTable importedRoutePoints =
      $ImportedRoutePointsTable(this);
  late final $ImportedDailySummariesTable importedDailySummaries =
      $ImportedDailySummariesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    importedWorkouts,
    importedRoutePoints,
    importedDailySummaries,
  ];
}

typedef $$ImportedWorkoutsTableCreateCompanionBuilder =
    ImportedWorkoutsCompanion Function({
      required String id,
      required DateTime start,
      required DateTime end,
      required String workoutType,
      Value<double?> distanceMeters,
      Value<double?> energyKcal,
      Value<int?> steps,
      required String sourceName,
      Value<double?> startLatitude,
      Value<double?> startLongitude,
      Value<double?> endLatitude,
      Value<double?> endLongitude,
      Value<int> rowid,
    });
typedef $$ImportedWorkoutsTableUpdateCompanionBuilder =
    ImportedWorkoutsCompanion Function({
      Value<String> id,
      Value<DateTime> start,
      Value<DateTime> end,
      Value<String> workoutType,
      Value<double?> distanceMeters,
      Value<double?> energyKcal,
      Value<int?> steps,
      Value<String> sourceName,
      Value<double?> startLatitude,
      Value<double?> startLongitude,
      Value<double?> endLatitude,
      Value<double?> endLongitude,
      Value<int> rowid,
    });

final class $$ImportedWorkoutsTableReferences
    extends
        BaseReferences<
          _$ImportedHealthDatabase,
          $ImportedWorkoutsTable,
          ImportedWorkout
        > {
  $$ImportedWorkoutsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ImportedRoutePointsTable,
    List<ImportedRoutePoint>
  >
  _importedRoutePointsRefsTable(_$ImportedHealthDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importedRoutePoints,
        aliasName: $_aliasNameGenerator(
          db.importedWorkouts.id,
          db.importedRoutePoints.workoutId,
        ),
      );

  $$ImportedRoutePointsTableProcessedTableManager get importedRoutePointsRefs {
    final manager = $$ImportedRoutePointsTableTableManager(
      $_db,
      $_db.importedRoutePoints,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importedRoutePointsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportedWorkoutsTableFilterComposer
    extends Composer<_$ImportedHealthDatabase, $ImportedWorkoutsTable> {
  $$ImportedWorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energyKcal => $composableBuilder(
    column: $table.energyKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLatitude => $composableBuilder(
    column: $table.startLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLongitude => $composableBuilder(
    column: $table.startLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLatitude => $composableBuilder(
    column: $table.endLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLongitude => $composableBuilder(
    column: $table.endLongitude,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> importedRoutePointsRefs(
    Expression<bool> Function($$ImportedRoutePointsTableFilterComposer f) f,
  ) {
    final $$ImportedRoutePointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importedRoutePoints,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportedRoutePointsTableFilterComposer(
            $db: $db,
            $table: $db.importedRoutePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportedWorkoutsTableOrderingComposer
    extends Composer<_$ImportedHealthDatabase, $ImportedWorkoutsTable> {
  $$ImportedWorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energyKcal => $composableBuilder(
    column: $table.energyKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLatitude => $composableBuilder(
    column: $table.startLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLongitude => $composableBuilder(
    column: $table.startLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLatitude => $composableBuilder(
    column: $table.endLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLongitude => $composableBuilder(
    column: $table.endLongitude,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportedWorkoutsTableAnnotationComposer
    extends Composer<_$ImportedHealthDatabase, $ImportedWorkoutsTable> {
  $$ImportedWorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<DateTime> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);

  GeneratedColumn<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get energyKcal => $composableBuilder(
    column: $table.energyKcal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startLatitude => $composableBuilder(
    column: $table.startLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startLongitude => $composableBuilder(
    column: $table.startLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endLatitude => $composableBuilder(
    column: $table.endLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endLongitude => $composableBuilder(
    column: $table.endLongitude,
    builder: (column) => column,
  );

  Expression<T> importedRoutePointsRefs<T extends Object>(
    Expression<T> Function($$ImportedRoutePointsTableAnnotationComposer a) f,
  ) {
    final $$ImportedRoutePointsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importedRoutePoints,
          getReferencedColumn: (t) => t.workoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportedRoutePointsTableAnnotationComposer(
                $db: $db,
                $table: $db.importedRoutePoints,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportedWorkoutsTableTableManager
    extends
        RootTableManager<
          _$ImportedHealthDatabase,
          $ImportedWorkoutsTable,
          ImportedWorkout,
          $$ImportedWorkoutsTableFilterComposer,
          $$ImportedWorkoutsTableOrderingComposer,
          $$ImportedWorkoutsTableAnnotationComposer,
          $$ImportedWorkoutsTableCreateCompanionBuilder,
          $$ImportedWorkoutsTableUpdateCompanionBuilder,
          (ImportedWorkout, $$ImportedWorkoutsTableReferences),
          ImportedWorkout,
          PrefetchHooks Function({bool importedRoutePointsRefs})
        > {
  $$ImportedWorkoutsTableTableManager(
    _$ImportedHealthDatabase db,
    $ImportedWorkoutsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportedWorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportedWorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportedWorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> start = const Value.absent(),
                Value<DateTime> end = const Value.absent(),
                Value<String> workoutType = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<double?> energyKcal = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<double?> startLatitude = const Value.absent(),
                Value<double?> startLongitude = const Value.absent(),
                Value<double?> endLatitude = const Value.absent(),
                Value<double?> endLongitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportedWorkoutsCompanion(
                id: id,
                start: start,
                end: end,
                workoutType: workoutType,
                distanceMeters: distanceMeters,
                energyKcal: energyKcal,
                steps: steps,
                sourceName: sourceName,
                startLatitude: startLatitude,
                startLongitude: startLongitude,
                endLatitude: endLatitude,
                endLongitude: endLongitude,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime start,
                required DateTime end,
                required String workoutType,
                Value<double?> distanceMeters = const Value.absent(),
                Value<double?> energyKcal = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                required String sourceName,
                Value<double?> startLatitude = const Value.absent(),
                Value<double?> startLongitude = const Value.absent(),
                Value<double?> endLatitude = const Value.absent(),
                Value<double?> endLongitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportedWorkoutsCompanion.insert(
                id: id,
                start: start,
                end: end,
                workoutType: workoutType,
                distanceMeters: distanceMeters,
                energyKcal: energyKcal,
                steps: steps,
                sourceName: sourceName,
                startLatitude: startLatitude,
                startLongitude: startLongitude,
                endLatitude: endLatitude,
                endLongitude: endLongitude,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportedWorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({importedRoutePointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (importedRoutePointsRefs) db.importedRoutePoints,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (importedRoutePointsRefs)
                    await $_getPrefetchedData<
                      ImportedWorkout,
                      $ImportedWorkoutsTable,
                      ImportedRoutePoint
                    >(
                      currentTable: table,
                      referencedTable: $$ImportedWorkoutsTableReferences
                          ._importedRoutePointsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ImportedWorkoutsTableReferences(
                            db,
                            table,
                            p0,
                          ).importedRoutePointsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.workoutId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ImportedWorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportedHealthDatabase,
      $ImportedWorkoutsTable,
      ImportedWorkout,
      $$ImportedWorkoutsTableFilterComposer,
      $$ImportedWorkoutsTableOrderingComposer,
      $$ImportedWorkoutsTableAnnotationComposer,
      $$ImportedWorkoutsTableCreateCompanionBuilder,
      $$ImportedWorkoutsTableUpdateCompanionBuilder,
      (ImportedWorkout, $$ImportedWorkoutsTableReferences),
      ImportedWorkout,
      PrefetchHooks Function({bool importedRoutePointsRefs})
    >;
typedef $$ImportedRoutePointsTableCreateCompanionBuilder =
    ImportedRoutePointsCompanion Function({
      Value<int> id,
      required String workoutId,
      required double latitude,
      required double longitude,
      Value<DateTime?> timestamp,
      required int sequence,
    });
typedef $$ImportedRoutePointsTableUpdateCompanionBuilder =
    ImportedRoutePointsCompanion Function({
      Value<int> id,
      Value<String> workoutId,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime?> timestamp,
      Value<int> sequence,
    });

final class $$ImportedRoutePointsTableReferences
    extends
        BaseReferences<
          _$ImportedHealthDatabase,
          $ImportedRoutePointsTable,
          ImportedRoutePoint
        > {
  $$ImportedRoutePointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportedWorkoutsTable _workoutIdTable(_$ImportedHealthDatabase db) =>
      db.importedWorkouts.createAlias(
        $_aliasNameGenerator(
          db.importedRoutePoints.workoutId,
          db.importedWorkouts.id,
        ),
      );

  $$ImportedWorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workout_id')!;

    final manager = $$ImportedWorkoutsTableTableManager(
      $_db,
      $_db.importedWorkouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportedRoutePointsTableFilterComposer
    extends Composer<_$ImportedHealthDatabase, $ImportedRoutePointsTable> {
  $$ImportedRoutePointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportedWorkoutsTableFilterComposer get workoutId {
    final $$ImportedWorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.importedWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportedWorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.importedWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportedRoutePointsTableOrderingComposer
    extends Composer<_$ImportedHealthDatabase, $ImportedRoutePointsTable> {
  $$ImportedRoutePointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportedWorkoutsTableOrderingComposer get workoutId {
    final $$ImportedWorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.importedWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportedWorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.importedWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportedRoutePointsTableAnnotationComposer
    extends Composer<_$ImportedHealthDatabase, $ImportedRoutePointsTable> {
  $$ImportedRoutePointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  $$ImportedWorkoutsTableAnnotationComposer get workoutId {
    final $$ImportedWorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.importedWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportedWorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.importedWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportedRoutePointsTableTableManager
    extends
        RootTableManager<
          _$ImportedHealthDatabase,
          $ImportedRoutePointsTable,
          ImportedRoutePoint,
          $$ImportedRoutePointsTableFilterComposer,
          $$ImportedRoutePointsTableOrderingComposer,
          $$ImportedRoutePointsTableAnnotationComposer,
          $$ImportedRoutePointsTableCreateCompanionBuilder,
          $$ImportedRoutePointsTableUpdateCompanionBuilder,
          (ImportedRoutePoint, $$ImportedRoutePointsTableReferences),
          ImportedRoutePoint,
          PrefetchHooks Function({bool workoutId})
        > {
  $$ImportedRoutePointsTableTableManager(
    _$ImportedHealthDatabase db,
    $ImportedRoutePointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportedRoutePointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportedRoutePointsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImportedRoutePointsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime?> timestamp = const Value.absent(),
                Value<int> sequence = const Value.absent(),
              }) => ImportedRoutePointsCompanion(
                id: id,
                workoutId: workoutId,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
                sequence: sequence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String workoutId,
                required double latitude,
                required double longitude,
                Value<DateTime?> timestamp = const Value.absent(),
                required int sequence,
              }) => ImportedRoutePointsCompanion.insert(
                id: id,
                workoutId: workoutId,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
                sequence: sequence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportedRoutePointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutId,
                                referencedTable:
                                    $$ImportedRoutePointsTableReferences
                                        ._workoutIdTable(db),
                                referencedColumn:
                                    $$ImportedRoutePointsTableReferences
                                        ._workoutIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportedRoutePointsTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportedHealthDatabase,
      $ImportedRoutePointsTable,
      ImportedRoutePoint,
      $$ImportedRoutePointsTableFilterComposer,
      $$ImportedRoutePointsTableOrderingComposer,
      $$ImportedRoutePointsTableAnnotationComposer,
      $$ImportedRoutePointsTableCreateCompanionBuilder,
      $$ImportedRoutePointsTableUpdateCompanionBuilder,
      (ImportedRoutePoint, $$ImportedRoutePointsTableReferences),
      ImportedRoutePoint,
      PrefetchHooks Function({bool workoutId})
    >;
typedef $$ImportedDailySummariesTableCreateCompanionBuilder =
    ImportedDailySummariesCompanion Function({
      required DateTime date,
      required String payload,
      Value<int> rowid,
    });
typedef $$ImportedDailySummariesTableUpdateCompanionBuilder =
    ImportedDailySummariesCompanion Function({
      Value<DateTime> date,
      Value<String> payload,
      Value<int> rowid,
    });

class $$ImportedDailySummariesTableFilterComposer
    extends Composer<_$ImportedHealthDatabase, $ImportedDailySummariesTable> {
  $$ImportedDailySummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportedDailySummariesTableOrderingComposer
    extends Composer<_$ImportedHealthDatabase, $ImportedDailySummariesTable> {
  $$ImportedDailySummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportedDailySummariesTableAnnotationComposer
    extends Composer<_$ImportedHealthDatabase, $ImportedDailySummariesTable> {
  $$ImportedDailySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$ImportedDailySummariesTableTableManager
    extends
        RootTableManager<
          _$ImportedHealthDatabase,
          $ImportedDailySummariesTable,
          ImportedDailySummary,
          $$ImportedDailySummariesTableFilterComposer,
          $$ImportedDailySummariesTableOrderingComposer,
          $$ImportedDailySummariesTableAnnotationComposer,
          $$ImportedDailySummariesTableCreateCompanionBuilder,
          $$ImportedDailySummariesTableUpdateCompanionBuilder,
          (
            ImportedDailySummary,
            BaseReferences<
              _$ImportedHealthDatabase,
              $ImportedDailySummariesTable,
              ImportedDailySummary
            >,
          ),
          ImportedDailySummary,
          PrefetchHooks Function()
        > {
  $$ImportedDailySummariesTableTableManager(
    _$ImportedHealthDatabase db,
    $ImportedDailySummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportedDailySummariesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ImportedDailySummariesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImportedDailySummariesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportedDailySummariesCompanion(
                date: date,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => ImportedDailySummariesCompanion.insert(
                date: date,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportedDailySummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportedHealthDatabase,
      $ImportedDailySummariesTable,
      ImportedDailySummary,
      $$ImportedDailySummariesTableFilterComposer,
      $$ImportedDailySummariesTableOrderingComposer,
      $$ImportedDailySummariesTableAnnotationComposer,
      $$ImportedDailySummariesTableCreateCompanionBuilder,
      $$ImportedDailySummariesTableUpdateCompanionBuilder,
      (
        ImportedDailySummary,
        BaseReferences<
          _$ImportedHealthDatabase,
          $ImportedDailySummariesTable,
          ImportedDailySummary
        >,
      ),
      ImportedDailySummary,
      PrefetchHooks Function()
    >;

class $ImportedHealthDatabaseManager {
  final _$ImportedHealthDatabase _db;
  $ImportedHealthDatabaseManager(this._db);
  $$ImportedWorkoutsTableTableManager get importedWorkouts =>
      $$ImportedWorkoutsTableTableManager(_db, _db.importedWorkouts);
  $$ImportedRoutePointsTableTableManager get importedRoutePoints =>
      $$ImportedRoutePointsTableTableManager(_db, _db.importedRoutePoints);
  $$ImportedDailySummariesTableTableManager get importedDailySummaries =>
      $$ImportedDailySummariesTableTableManager(
        _db,
        _db.importedDailySummaries,
      );
}
