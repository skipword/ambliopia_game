// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClinicalSessionsTable extends ClinicalSessions
    with TableInfo<$ClinicalSessionsTable, ClinicalSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClinicalSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameTypeMeta = const VerificationMeta(
    'gameType',
  );
  @override
  late final GeneratedColumn<String> gameType = GeneratedColumn<String>(
    'game_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameNameMeta = const VerificationMeta(
    'gameName',
  );
  @override
  late final GeneratedColumn<String> gameName = GeneratedColumn<String>(
    'game_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<double> durationSeconds = GeneratedColumn<double>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectiveLabelMeta = const VerificationMeta(
    'objectiveLabel',
  );
  @override
  late final GeneratedColumn<String> objectiveLabel = GeneratedColumn<String>(
    'objective_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedObjectiveMeta =
      const VerificationMeta('completedObjective');
  @override
  late final GeneratedColumn<int> completedObjective = GeneratedColumn<int>(
    'completed_objective',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetObjectiveMeta = const VerificationMeta(
    'targetObjective',
  );
  @override
  late final GeneratedColumn<int> targetObjective = GeneratedColumn<int>(
    'target_objective',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _redSuccessMeta = const VerificationMeta(
    'redSuccess',
  );
  @override
  late final GeneratedColumn<int> redSuccess = GeneratedColumn<int>(
    'red_success',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _redErrorsMeta = const VerificationMeta(
    'redErrors',
  );
  @override
  late final GeneratedColumn<int> redErrors = GeneratedColumn<int>(
    'red_errors',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _greenSuccessMeta = const VerificationMeta(
    'greenSuccess',
  );
  @override
  late final GeneratedColumn<int> greenSuccess = GeneratedColumn<int>(
    'green_success',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _greenErrorsMeta = const VerificationMeta(
    'greenErrors',
  );
  @override
  late final GeneratedColumn<int> greenErrors = GeneratedColumn<int>(
    'green_errors',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventsCountMeta = const VerificationMeta(
    'eventsCount',
  );
  @override
  late final GeneratedColumn<int> eventsCount = GeneratedColumn<int>(
    'events_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageReactionTimeMsMeta =
      const VerificationMeta('averageReactionTimeMs');
  @override
  late final GeneratedColumn<double> averageReactionTimeMs =
      GeneratedColumn<double>(
        'average_reaction_time_ms',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    gameType,
    gameName,
    startedAt,
    endedAt,
    durationSeconds,
    score,
    objectiveLabel,
    completedObjective,
    targetObjective,
    redSuccess,
    redErrors,
    greenSuccess,
    greenErrors,
    eventsCount,
    observation,
    averageReactionTimeMs,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clinical_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClinicalSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('game_type')) {
      context.handle(
        _gameTypeMeta,
        gameType.isAcceptableOrUnknown(data['game_type']!, _gameTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_gameTypeMeta);
    }
    if (data.containsKey('game_name')) {
      context.handle(
        _gameNameMeta,
        gameName.isAcceptableOrUnknown(data['game_name']!, _gameNameMeta),
      );
    } else if (isInserting) {
      context.missing(_gameNameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('objective_label')) {
      context.handle(
        _objectiveLabelMeta,
        objectiveLabel.isAcceptableOrUnknown(
          data['objective_label']!,
          _objectiveLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_objectiveLabelMeta);
    }
    if (data.containsKey('completed_objective')) {
      context.handle(
        _completedObjectiveMeta,
        completedObjective.isAcceptableOrUnknown(
          data['completed_objective']!,
          _completedObjectiveMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedObjectiveMeta);
    }
    if (data.containsKey('target_objective')) {
      context.handle(
        _targetObjectiveMeta,
        targetObjective.isAcceptableOrUnknown(
          data['target_objective']!,
          _targetObjectiveMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetObjectiveMeta);
    }
    if (data.containsKey('red_success')) {
      context.handle(
        _redSuccessMeta,
        redSuccess.isAcceptableOrUnknown(data['red_success']!, _redSuccessMeta),
      );
    } else if (isInserting) {
      context.missing(_redSuccessMeta);
    }
    if (data.containsKey('red_errors')) {
      context.handle(
        _redErrorsMeta,
        redErrors.isAcceptableOrUnknown(data['red_errors']!, _redErrorsMeta),
      );
    } else if (isInserting) {
      context.missing(_redErrorsMeta);
    }
    if (data.containsKey('green_success')) {
      context.handle(
        _greenSuccessMeta,
        greenSuccess.isAcceptableOrUnknown(
          data['green_success']!,
          _greenSuccessMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_greenSuccessMeta);
    }
    if (data.containsKey('green_errors')) {
      context.handle(
        _greenErrorsMeta,
        greenErrors.isAcceptableOrUnknown(
          data['green_errors']!,
          _greenErrorsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_greenErrorsMeta);
    }
    if (data.containsKey('events_count')) {
      context.handle(
        _eventsCountMeta,
        eventsCount.isAcceptableOrUnknown(
          data['events_count']!,
          _eventsCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventsCountMeta);
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationMeta);
    }
    if (data.containsKey('average_reaction_time_ms')) {
      context.handle(
        _averageReactionTimeMsMeta,
        averageReactionTimeMs.isAcceptableOrUnknown(
          data['average_reaction_time_ms']!,
          _averageReactionTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClinicalSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClinicalSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      gameType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_type'],
      )!,
      gameName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_seconds'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      objectiveLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objective_label'],
      )!,
      completedObjective: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_objective'],
      )!,
      targetObjective: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_objective'],
      )!,
      redSuccess: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}red_success'],
      )!,
      redErrors: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}red_errors'],
      )!,
      greenSuccess: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}green_success'],
      )!,
      greenErrors: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}green_errors'],
      )!,
      eventsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}events_count'],
      )!,
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      )!,
      averageReactionTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_reaction_time_ms'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $ClinicalSessionsTable createAlias(String alias) {
    return $ClinicalSessionsTable(attachedDatabase, alias);
  }
}

class ClinicalSession extends DataClass implements Insertable<ClinicalSession> {
  final String id;
  final String patientId;
  final String gameType;
  final String gameName;
  final DateTime startedAt;
  final DateTime endedAt;
  final double durationSeconds;
  final int score;
  final String objectiveLabel;
  final int completedObjective;
  final int targetObjective;
  final int redSuccess;
  final int redErrors;
  final int greenSuccess;
  final int greenErrors;
  final int eventsCount;
  final String observation;
  final double? averageReactionTimeMs;
  final bool synced;
  const ClinicalSession({
    required this.id,
    required this.patientId,
    required this.gameType,
    required this.gameName,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.score,
    required this.objectiveLabel,
    required this.completedObjective,
    required this.targetObjective,
    required this.redSuccess,
    required this.redErrors,
    required this.greenSuccess,
    required this.greenErrors,
    required this.eventsCount,
    required this.observation,
    this.averageReactionTimeMs,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['game_type'] = Variable<String>(gameType);
    map['game_name'] = Variable<String>(gameName);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['duration_seconds'] = Variable<double>(durationSeconds);
    map['score'] = Variable<int>(score);
    map['objective_label'] = Variable<String>(objectiveLabel);
    map['completed_objective'] = Variable<int>(completedObjective);
    map['target_objective'] = Variable<int>(targetObjective);
    map['red_success'] = Variable<int>(redSuccess);
    map['red_errors'] = Variable<int>(redErrors);
    map['green_success'] = Variable<int>(greenSuccess);
    map['green_errors'] = Variable<int>(greenErrors);
    map['events_count'] = Variable<int>(eventsCount);
    map['observation'] = Variable<String>(observation);
    if (!nullToAbsent || averageReactionTimeMs != null) {
      map['average_reaction_time_ms'] = Variable<double>(averageReactionTimeMs);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ClinicalSessionsCompanion toCompanion(bool nullToAbsent) {
    return ClinicalSessionsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      gameType: Value(gameType),
      gameName: Value(gameName),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      durationSeconds: Value(durationSeconds),
      score: Value(score),
      objectiveLabel: Value(objectiveLabel),
      completedObjective: Value(completedObjective),
      targetObjective: Value(targetObjective),
      redSuccess: Value(redSuccess),
      redErrors: Value(redErrors),
      greenSuccess: Value(greenSuccess),
      greenErrors: Value(greenErrors),
      eventsCount: Value(eventsCount),
      observation: Value(observation),
      averageReactionTimeMs: averageReactionTimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(averageReactionTimeMs),
      synced: Value(synced),
    );
  }

  factory ClinicalSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClinicalSession(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      gameType: serializer.fromJson<String>(json['gameType']),
      gameName: serializer.fromJson<String>(json['gameName']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      durationSeconds: serializer.fromJson<double>(json['durationSeconds']),
      score: serializer.fromJson<int>(json['score']),
      objectiveLabel: serializer.fromJson<String>(json['objectiveLabel']),
      completedObjective: serializer.fromJson<int>(json['completedObjective']),
      targetObjective: serializer.fromJson<int>(json['targetObjective']),
      redSuccess: serializer.fromJson<int>(json['redSuccess']),
      redErrors: serializer.fromJson<int>(json['redErrors']),
      greenSuccess: serializer.fromJson<int>(json['greenSuccess']),
      greenErrors: serializer.fromJson<int>(json['greenErrors']),
      eventsCount: serializer.fromJson<int>(json['eventsCount']),
      observation: serializer.fromJson<String>(json['observation']),
      averageReactionTimeMs: serializer.fromJson<double?>(
        json['averageReactionTimeMs'],
      ),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'gameType': serializer.toJson<String>(gameType),
      'gameName': serializer.toJson<String>(gameName),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'durationSeconds': serializer.toJson<double>(durationSeconds),
      'score': serializer.toJson<int>(score),
      'objectiveLabel': serializer.toJson<String>(objectiveLabel),
      'completedObjective': serializer.toJson<int>(completedObjective),
      'targetObjective': serializer.toJson<int>(targetObjective),
      'redSuccess': serializer.toJson<int>(redSuccess),
      'redErrors': serializer.toJson<int>(redErrors),
      'greenSuccess': serializer.toJson<int>(greenSuccess),
      'greenErrors': serializer.toJson<int>(greenErrors),
      'eventsCount': serializer.toJson<int>(eventsCount),
      'observation': serializer.toJson<String>(observation),
      'averageReactionTimeMs': serializer.toJson<double?>(
        averageReactionTimeMs,
      ),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ClinicalSession copyWith({
    String? id,
    String? patientId,
    String? gameType,
    String? gameName,
    DateTime? startedAt,
    DateTime? endedAt,
    double? durationSeconds,
    int? score,
    String? objectiveLabel,
    int? completedObjective,
    int? targetObjective,
    int? redSuccess,
    int? redErrors,
    int? greenSuccess,
    int? greenErrors,
    int? eventsCount,
    String? observation,
    Value<double?> averageReactionTimeMs = const Value.absent(),
    bool? synced,
  }) => ClinicalSession(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    gameType: gameType ?? this.gameType,
    gameName: gameName ?? this.gameName,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    score: score ?? this.score,
    objectiveLabel: objectiveLabel ?? this.objectiveLabel,
    completedObjective: completedObjective ?? this.completedObjective,
    targetObjective: targetObjective ?? this.targetObjective,
    redSuccess: redSuccess ?? this.redSuccess,
    redErrors: redErrors ?? this.redErrors,
    greenSuccess: greenSuccess ?? this.greenSuccess,
    greenErrors: greenErrors ?? this.greenErrors,
    eventsCount: eventsCount ?? this.eventsCount,
    observation: observation ?? this.observation,
    averageReactionTimeMs: averageReactionTimeMs.present
        ? averageReactionTimeMs.value
        : this.averageReactionTimeMs,
    synced: synced ?? this.synced,
  );
  ClinicalSession copyWithCompanion(ClinicalSessionsCompanion data) {
    return ClinicalSession(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      gameName: data.gameName.present ? data.gameName.value : this.gameName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      score: data.score.present ? data.score.value : this.score,
      objectiveLabel: data.objectiveLabel.present
          ? data.objectiveLabel.value
          : this.objectiveLabel,
      completedObjective: data.completedObjective.present
          ? data.completedObjective.value
          : this.completedObjective,
      targetObjective: data.targetObjective.present
          ? data.targetObjective.value
          : this.targetObjective,
      redSuccess: data.redSuccess.present
          ? data.redSuccess.value
          : this.redSuccess,
      redErrors: data.redErrors.present ? data.redErrors.value : this.redErrors,
      greenSuccess: data.greenSuccess.present
          ? data.greenSuccess.value
          : this.greenSuccess,
      greenErrors: data.greenErrors.present
          ? data.greenErrors.value
          : this.greenErrors,
      eventsCount: data.eventsCount.present
          ? data.eventsCount.value
          : this.eventsCount,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
      averageReactionTimeMs: data.averageReactionTimeMs.present
          ? data.averageReactionTimeMs.value
          : this.averageReactionTimeMs,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalSession(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('gameType: $gameType, ')
          ..write('gameName: $gameName, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('score: $score, ')
          ..write('objectiveLabel: $objectiveLabel, ')
          ..write('completedObjective: $completedObjective, ')
          ..write('targetObjective: $targetObjective, ')
          ..write('redSuccess: $redSuccess, ')
          ..write('redErrors: $redErrors, ')
          ..write('greenSuccess: $greenSuccess, ')
          ..write('greenErrors: $greenErrors, ')
          ..write('eventsCount: $eventsCount, ')
          ..write('observation: $observation, ')
          ..write('averageReactionTimeMs: $averageReactionTimeMs, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    gameType,
    gameName,
    startedAt,
    endedAt,
    durationSeconds,
    score,
    objectiveLabel,
    completedObjective,
    targetObjective,
    redSuccess,
    redErrors,
    greenSuccess,
    greenErrors,
    eventsCount,
    observation,
    averageReactionTimeMs,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClinicalSession &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.gameType == this.gameType &&
          other.gameName == this.gameName &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.score == this.score &&
          other.objectiveLabel == this.objectiveLabel &&
          other.completedObjective == this.completedObjective &&
          other.targetObjective == this.targetObjective &&
          other.redSuccess == this.redSuccess &&
          other.redErrors == this.redErrors &&
          other.greenSuccess == this.greenSuccess &&
          other.greenErrors == this.greenErrors &&
          other.eventsCount == this.eventsCount &&
          other.observation == this.observation &&
          other.averageReactionTimeMs == this.averageReactionTimeMs &&
          other.synced == this.synced);
}

class ClinicalSessionsCompanion extends UpdateCompanion<ClinicalSession> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> gameType;
  final Value<String> gameName;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<double> durationSeconds;
  final Value<int> score;
  final Value<String> objectiveLabel;
  final Value<int> completedObjective;
  final Value<int> targetObjective;
  final Value<int> redSuccess;
  final Value<int> redErrors;
  final Value<int> greenSuccess;
  final Value<int> greenErrors;
  final Value<int> eventsCount;
  final Value<String> observation;
  final Value<double?> averageReactionTimeMs;
  final Value<bool> synced;
  final Value<int> rowid;
  const ClinicalSessionsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.gameType = const Value.absent(),
    this.gameName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.score = const Value.absent(),
    this.objectiveLabel = const Value.absent(),
    this.completedObjective = const Value.absent(),
    this.targetObjective = const Value.absent(),
    this.redSuccess = const Value.absent(),
    this.redErrors = const Value.absent(),
    this.greenSuccess = const Value.absent(),
    this.greenErrors = const Value.absent(),
    this.eventsCount = const Value.absent(),
    this.observation = const Value.absent(),
    this.averageReactionTimeMs = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClinicalSessionsCompanion.insert({
    required String id,
    required String patientId,
    required String gameType,
    required String gameName,
    required DateTime startedAt,
    required DateTime endedAt,
    required double durationSeconds,
    required int score,
    required String objectiveLabel,
    required int completedObjective,
    required int targetObjective,
    required int redSuccess,
    required int redErrors,
    required int greenSuccess,
    required int greenErrors,
    required int eventsCount,
    required String observation,
    this.averageReactionTimeMs = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       gameType = Value(gameType),
       gameName = Value(gameName),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       durationSeconds = Value(durationSeconds),
       score = Value(score),
       objectiveLabel = Value(objectiveLabel),
       completedObjective = Value(completedObjective),
       targetObjective = Value(targetObjective),
       redSuccess = Value(redSuccess),
       redErrors = Value(redErrors),
       greenSuccess = Value(greenSuccess),
       greenErrors = Value(greenErrors),
       eventsCount = Value(eventsCount),
       observation = Value(observation);
  static Insertable<ClinicalSession> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? gameType,
    Expression<String>? gameName,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? durationSeconds,
    Expression<int>? score,
    Expression<String>? objectiveLabel,
    Expression<int>? completedObjective,
    Expression<int>? targetObjective,
    Expression<int>? redSuccess,
    Expression<int>? redErrors,
    Expression<int>? greenSuccess,
    Expression<int>? greenErrors,
    Expression<int>? eventsCount,
    Expression<String>? observation,
    Expression<double>? averageReactionTimeMs,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (gameType != null) 'game_type': gameType,
      if (gameName != null) 'game_name': gameName,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (score != null) 'score': score,
      if (objectiveLabel != null) 'objective_label': objectiveLabel,
      if (completedObjective != null) 'completed_objective': completedObjective,
      if (targetObjective != null) 'target_objective': targetObjective,
      if (redSuccess != null) 'red_success': redSuccess,
      if (redErrors != null) 'red_errors': redErrors,
      if (greenSuccess != null) 'green_success': greenSuccess,
      if (greenErrors != null) 'green_errors': greenErrors,
      if (eventsCount != null) 'events_count': eventsCount,
      if (observation != null) 'observation': observation,
      if (averageReactionTimeMs != null)
        'average_reaction_time_ms': averageReactionTimeMs,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClinicalSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? gameType,
    Value<String>? gameName,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<double>? durationSeconds,
    Value<int>? score,
    Value<String>? objectiveLabel,
    Value<int>? completedObjective,
    Value<int>? targetObjective,
    Value<int>? redSuccess,
    Value<int>? redErrors,
    Value<int>? greenSuccess,
    Value<int>? greenErrors,
    Value<int>? eventsCount,
    Value<String>? observation,
    Value<double?>? averageReactionTimeMs,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return ClinicalSessionsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      gameType: gameType ?? this.gameType,
      gameName: gameName ?? this.gameName,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      score: score ?? this.score,
      objectiveLabel: objectiveLabel ?? this.objectiveLabel,
      completedObjective: completedObjective ?? this.completedObjective,
      targetObjective: targetObjective ?? this.targetObjective,
      redSuccess: redSuccess ?? this.redSuccess,
      redErrors: redErrors ?? this.redErrors,
      greenSuccess: greenSuccess ?? this.greenSuccess,
      greenErrors: greenErrors ?? this.greenErrors,
      eventsCount: eventsCount ?? this.eventsCount,
      observation: observation ?? this.observation,
      averageReactionTimeMs:
          averageReactionTimeMs ?? this.averageReactionTimeMs,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<String>(gameType.value);
    }
    if (gameName.present) {
      map['game_name'] = Variable<String>(gameName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<double>(durationSeconds.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (objectiveLabel.present) {
      map['objective_label'] = Variable<String>(objectiveLabel.value);
    }
    if (completedObjective.present) {
      map['completed_objective'] = Variable<int>(completedObjective.value);
    }
    if (targetObjective.present) {
      map['target_objective'] = Variable<int>(targetObjective.value);
    }
    if (redSuccess.present) {
      map['red_success'] = Variable<int>(redSuccess.value);
    }
    if (redErrors.present) {
      map['red_errors'] = Variable<int>(redErrors.value);
    }
    if (greenSuccess.present) {
      map['green_success'] = Variable<int>(greenSuccess.value);
    }
    if (greenErrors.present) {
      map['green_errors'] = Variable<int>(greenErrors.value);
    }
    if (eventsCount.present) {
      map['events_count'] = Variable<int>(eventsCount.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    if (averageReactionTimeMs.present) {
      map['average_reaction_time_ms'] = Variable<double>(
        averageReactionTimeMs.value,
      );
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalSessionsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('gameType: $gameType, ')
          ..write('gameName: $gameName, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('score: $score, ')
          ..write('objectiveLabel: $objectiveLabel, ')
          ..write('completedObjective: $completedObjective, ')
          ..write('targetObjective: $targetObjective, ')
          ..write('redSuccess: $redSuccess, ')
          ..write('redErrors: $redErrors, ')
          ..write('greenSuccess: $greenSuccess, ')
          ..write('greenErrors: $greenErrors, ')
          ..write('eventsCount: $eventsCount, ')
          ..write('observation: $observation, ')
          ..write('averageReactionTimeMs: $averageReactionTimeMs, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClinicalSessionsTable clinicalSessions = $ClinicalSessionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [clinicalSessions];
}

typedef $$ClinicalSessionsTableCreateCompanionBuilder =
    ClinicalSessionsCompanion Function({
      required String id,
      required String patientId,
      required String gameType,
      required String gameName,
      required DateTime startedAt,
      required DateTime endedAt,
      required double durationSeconds,
      required int score,
      required String objectiveLabel,
      required int completedObjective,
      required int targetObjective,
      required int redSuccess,
      required int redErrors,
      required int greenSuccess,
      required int greenErrors,
      required int eventsCount,
      required String observation,
      Value<double?> averageReactionTimeMs,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$ClinicalSessionsTableUpdateCompanionBuilder =
    ClinicalSessionsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> gameType,
      Value<String> gameName,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<double> durationSeconds,
      Value<int> score,
      Value<String> objectiveLabel,
      Value<int> completedObjective,
      Value<int> targetObjective,
      Value<int> redSuccess,
      Value<int> redErrors,
      Value<int> greenSuccess,
      Value<int> greenErrors,
      Value<int> eventsCount,
      Value<String> observation,
      Value<double?> averageReactionTimeMs,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$ClinicalSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ClinicalSessionsTable> {
  $$ClinicalSessionsTableFilterComposer({
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

  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameName => $composableBuilder(
    column: $table.gameName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectiveLabel => $composableBuilder(
    column: $table.objectiveLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedObjective => $composableBuilder(
    column: $table.completedObjective,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetObjective => $composableBuilder(
    column: $table.targetObjective,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get redSuccess => $composableBuilder(
    column: $table.redSuccess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get redErrors => $composableBuilder(
    column: $table.redErrors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get greenSuccess => $composableBuilder(
    column: $table.greenSuccess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get greenErrors => $composableBuilder(
    column: $table.greenErrors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventsCount => $composableBuilder(
    column: $table.eventsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageReactionTimeMs => $composableBuilder(
    column: $table.averageReactionTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClinicalSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClinicalSessionsTable> {
  $$ClinicalSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameName => $composableBuilder(
    column: $table.gameName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectiveLabel => $composableBuilder(
    column: $table.objectiveLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedObjective => $composableBuilder(
    column: $table.completedObjective,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetObjective => $composableBuilder(
    column: $table.targetObjective,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redSuccess => $composableBuilder(
    column: $table.redSuccess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redErrors => $composableBuilder(
    column: $table.redErrors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get greenSuccess => $composableBuilder(
    column: $table.greenSuccess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get greenErrors => $composableBuilder(
    column: $table.greenErrors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventsCount => $composableBuilder(
    column: $table.eventsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageReactionTimeMs => $composableBuilder(
    column: $table.averageReactionTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClinicalSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClinicalSessionsTable> {
  $$ClinicalSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get gameType =>
      $composableBuilder(column: $table.gameType, builder: (column) => column);

  GeneratedColumn<String> get gameName =>
      $composableBuilder(column: $table.gameName, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get objectiveLabel => $composableBuilder(
    column: $table.objectiveLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedObjective => $composableBuilder(
    column: $table.completedObjective,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetObjective => $composableBuilder(
    column: $table.targetObjective,
    builder: (column) => column,
  );

  GeneratedColumn<int> get redSuccess => $composableBuilder(
    column: $table.redSuccess,
    builder: (column) => column,
  );

  GeneratedColumn<int> get redErrors =>
      $composableBuilder(column: $table.redErrors, builder: (column) => column);

  GeneratedColumn<int> get greenSuccess => $composableBuilder(
    column: $table.greenSuccess,
    builder: (column) => column,
  );

  GeneratedColumn<int> get greenErrors => $composableBuilder(
    column: $table.greenErrors,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventsCount => $composableBuilder(
    column: $table.eventsCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageReactionTimeMs => $composableBuilder(
    column: $table.averageReactionTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ClinicalSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClinicalSessionsTable,
          ClinicalSession,
          $$ClinicalSessionsTableFilterComposer,
          $$ClinicalSessionsTableOrderingComposer,
          $$ClinicalSessionsTableAnnotationComposer,
          $$ClinicalSessionsTableCreateCompanionBuilder,
          $$ClinicalSessionsTableUpdateCompanionBuilder,
          (
            ClinicalSession,
            BaseReferences<
              _$AppDatabase,
              $ClinicalSessionsTable,
              ClinicalSession
            >,
          ),
          ClinicalSession,
          PrefetchHooks Function()
        > {
  $$ClinicalSessionsTableTableManager(
    _$AppDatabase db,
    $ClinicalSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClinicalSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClinicalSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClinicalSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> gameType = const Value.absent(),
                Value<String> gameName = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<double> durationSeconds = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String> objectiveLabel = const Value.absent(),
                Value<int> completedObjective = const Value.absent(),
                Value<int> targetObjective = const Value.absent(),
                Value<int> redSuccess = const Value.absent(),
                Value<int> redErrors = const Value.absent(),
                Value<int> greenSuccess = const Value.absent(),
                Value<int> greenErrors = const Value.absent(),
                Value<int> eventsCount = const Value.absent(),
                Value<String> observation = const Value.absent(),
                Value<double?> averageReactionTimeMs = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalSessionsCompanion(
                id: id,
                patientId: patientId,
                gameType: gameType,
                gameName: gameName,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                score: score,
                objectiveLabel: objectiveLabel,
                completedObjective: completedObjective,
                targetObjective: targetObjective,
                redSuccess: redSuccess,
                redErrors: redErrors,
                greenSuccess: greenSuccess,
                greenErrors: greenErrors,
                eventsCount: eventsCount,
                observation: observation,
                averageReactionTimeMs: averageReactionTimeMs,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String gameType,
                required String gameName,
                required DateTime startedAt,
                required DateTime endedAt,
                required double durationSeconds,
                required int score,
                required String objectiveLabel,
                required int completedObjective,
                required int targetObjective,
                required int redSuccess,
                required int redErrors,
                required int greenSuccess,
                required int greenErrors,
                required int eventsCount,
                required String observation,
                Value<double?> averageReactionTimeMs = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalSessionsCompanion.insert(
                id: id,
                patientId: patientId,
                gameType: gameType,
                gameName: gameName,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                score: score,
                objectiveLabel: objectiveLabel,
                completedObjective: completedObjective,
                targetObjective: targetObjective,
                redSuccess: redSuccess,
                redErrors: redErrors,
                greenSuccess: greenSuccess,
                greenErrors: greenErrors,
                eventsCount: eventsCount,
                observation: observation,
                averageReactionTimeMs: averageReactionTimeMs,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClinicalSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClinicalSessionsTable,
      ClinicalSession,
      $$ClinicalSessionsTableFilterComposer,
      $$ClinicalSessionsTableOrderingComposer,
      $$ClinicalSessionsTableAnnotationComposer,
      $$ClinicalSessionsTableCreateCompanionBuilder,
      $$ClinicalSessionsTableUpdateCompanionBuilder,
      (
        ClinicalSession,
        BaseReferences<_$AppDatabase, $ClinicalSessionsTable, ClinicalSession>,
      ),
      ClinicalSession,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClinicalSessionsTableTableManager get clinicalSessions =>
      $$ClinicalSessionsTableTableManager(_db, _db.clinicalSessions);
}
