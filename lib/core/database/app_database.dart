import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/clinical_session_summary.dart';

part 'app_database.g.dart';

class ClinicalSessions extends Table {
  TextColumn get id => text()();

  TextColumn get patientId => text()();

  TextColumn get gameType => text()();

  TextColumn get gameName => text()();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get endedAt => dateTime()();

  RealColumn get durationSeconds => real()();

  IntColumn get score => integer()();

  TextColumn get objectiveLabel => text()();

  IntColumn get completedObjective => integer()();

  IntColumn get targetObjective => integer()();

  IntColumn get redSuccess => integer()();

  IntColumn get redErrors => integer()();

  IntColumn get greenSuccess => integer()();

  IntColumn get greenErrors => integer()();

  IntColumn get eventsCount => integer()();

  TextColumn get observation => text()();

  RealColumn get averageReactionTimeMs => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ClinicalSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'vision_kids_db',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 2;

  Future<void> saveClinicalSummary(ClinicalSessionSummary summary) async {
    final companion = ClinicalSessionsCompanion(
      id: Value(summary.id),
      patientId: Value(summary.patientId),
      gameType: Value(summary.gameType.name),
      gameName: Value(summary.gameName),
      startedAt: Value(summary.startedAt),
      endedAt: Value(summary.endedAt),
      durationSeconds: Value(summary.durationSeconds),
      score: Value(summary.score),
      objectiveLabel: Value(summary.objectiveLabel),
      completedObjective: Value(summary.completedObjective),
      targetObjective: Value(summary.targetObjective),
      redSuccess: Value(summary.redSuccess),
      redErrors: Value(summary.redErrors),
      greenSuccess: Value(summary.greenSuccess),
      greenErrors: Value(summary.greenErrors),
      eventsCount: Value(summary.eventsCount),
      observation: Value(summary.observation),
      averageReactionTimeMs: Value(summary.averageReactionTimeMs),
    );

    await into(
      clinicalSessions,
    ).insert(companion, mode: InsertMode.insertOrReplace);
  }

  Future<List<ClinicalSessionSummary>> getClinicalSummaries() async {
    final rows = await (select(
      clinicalSessions,
    )..orderBy([(table) => OrderingTerm.desc(table.startedAt)])).get();

    return rows.map((row) {
      return ClinicalSessionSummary(
        id: row.id,
        patientId: row.patientId,
        gameType: ClinicalGameType.values.byName(row.gameType),
        gameName: row.gameName,
        startedAt: row.startedAt,
        endedAt: row.endedAt,
        durationSeconds: row.durationSeconds,
        score: row.score,
        objectiveLabel: row.objectiveLabel,
        completedObjective: row.completedObjective,
        targetObjective: row.targetObjective,
        redSuccess: row.redSuccess,
        redErrors: row.redErrors,
        greenSuccess: row.greenSuccess,
        greenErrors: row.greenErrors,
        eventsCount: row.eventsCount,
        observation: row.observation,
        averageReactionTimeMs: row.averageReactionTimeMs,
      );
    }).toList();
  }

  Future<void> deleteAllClinicalSessions() async {
    await delete(clinicalSessions).go();
  }
}
