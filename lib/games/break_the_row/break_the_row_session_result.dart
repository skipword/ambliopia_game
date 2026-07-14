enum BreakTheRowChannel { red, green }

enum BreakTheRowEndReason { manual, maxLivesLost, targetCompleted }

enum BreakTheRowPieceResult { placed, failed }

class BreakTheRowPieceEvent {
  const BreakTheRowPieceEvent({
    required this.id,
    required this.channel,
    required this.spawnedAtSeconds,
    required this.completedAtSeconds,
    required this.result,
    required this.movements,
    required this.rotations,
    required this.usedFastDrop,
    required this.completedLines,
  });

  final int id;
  final BreakTheRowChannel channel;
  final double spawnedAtSeconds;
  final double completedAtSeconds;
  final BreakTheRowPieceResult result;

  final int movements;
  final int rotations;
  final bool usedFastDrop;
  final int completedLines;
}

class BreakTheRowStats {
  const BreakTheRowStats({
    required this.score,
    required this.linesCompleted,
    required this.livesLost,
    required this.piecesPlaced,
    required this.piecesFailed,
    required this.redPiecesPlaced,
    required this.greenPiecesPlaced,
    required this.redPiecesFailed,
    required this.greenPiecesFailed,
  });

  factory BreakTheRowStats.empty() {
    return const BreakTheRowStats(
      score: 0,
      linesCompleted: 0,
      livesLost: 0,
      piecesPlaced: 0,
      piecesFailed: 0,
      redPiecesPlaced: 0,
      greenPiecesPlaced: 0,
      redPiecesFailed: 0,
      greenPiecesFailed: 0,
    );
  }

  final int score;
  final int linesCompleted;
  final int livesLost;

  final int piecesPlaced;
  final int piecesFailed;

  final int redPiecesPlaced;
  final int greenPiecesPlaced;
  final int redPiecesFailed;
  final int greenPiecesFailed;

  int get totalPieces => piecesPlaced + piecesFailed;

  BreakTheRowStats copyWith({
    int? score,
    int? linesCompleted,
    int? livesLost,
    int? piecesPlaced,
    int? piecesFailed,
    int? redPiecesPlaced,
    int? greenPiecesPlaced,
    int? redPiecesFailed,
    int? greenPiecesFailed,
  }) {
    return BreakTheRowStats(
      score: score ?? this.score,
      linesCompleted: linesCompleted ?? this.linesCompleted,
      livesLost: livesLost ?? this.livesLost,
      piecesPlaced: piecesPlaced ?? this.piecesPlaced,
      piecesFailed: piecesFailed ?? this.piecesFailed,
      redPiecesPlaced: redPiecesPlaced ?? this.redPiecesPlaced,
      greenPiecesPlaced: greenPiecesPlaced ?? this.greenPiecesPlaced,
      redPiecesFailed: redPiecesFailed ?? this.redPiecesFailed,
      greenPiecesFailed: greenPiecesFailed ?? this.greenPiecesFailed,
    );
  }
}

class BreakTheRowSessionResult {
  const BreakTheRowSessionResult({
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.endReason,
    required this.stats,
    required this.events,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final double durationSeconds;
  final BreakTheRowEndReason endReason;
  final BreakTheRowStats stats;
  final List<BreakTheRowPieceEvent> events;

  bool get endedByMaxLives => endReason == BreakTheRowEndReason.maxLivesLost;

  bool get completedTarget => endReason == BreakTheRowEndReason.targetCompleted;
}
