enum FarmCrossingEndReason { manual, maxLivesLost, targetCompleted }

enum FarmCrossingEventType {
  objectiveCollected,
  objectiveMissed,
  laneCrossed,
  collision,
  roundCompleted,
}

class FarmCrossingEvent {
  const FarmCrossingEvent({
    required this.id,
    required this.type,
    required this.occurredAtSeconds,
    required this.roundNumber,
    this.laneIndex,
    this.laneTimeMs,
  });

  final int id;
  final FarmCrossingEventType type;

  final double occurredAtSeconds;

  /// Ronda en la que ocurrió el evento.
  /// Empieza en 1.
  final int roundNumber;

  /// Carril relacionado con el evento.
  /// null cuando el evento no corresponde a un carril.
  final int? laneIndex;

  /// Tiempo que el niño permaneció en el carril antes de
  /// cruzarlo correctamente o sufrir una colisión.
  final int? laneTimeMs;
}

class FarmCrossingStats {
  const FarmCrossingStats({
    required this.roundsCompleted,
    required this.collisions,
    required this.objectivesCollected,
    required this.objectivesMissed,
    required this.lanesCrossed,
    required this.livesLost,
  });

  factory FarmCrossingStats.empty() {
    return const FarmCrossingStats(
      roundsCompleted: 0,
      collisions: 0,
      objectivesCollected: 0,
      objectivesMissed: 0,
      lanesCrossed: 0,
      livesLost: 0,
    );
  }

  final int roundsCompleted;

  final int collisions;

  final int objectivesCollected;
  final int objectivesMissed;

  final int lanesCrossed;

  final int livesLost;

  int get totalObjectives => objectivesCollected + objectivesMissed;

  double get objectiveSuccessRate {
    if (totalObjectives == 0) return 0;

    return objectivesCollected / totalObjectives;
  }

  FarmCrossingStats copyWith({
    int? roundsCompleted,
    int? collisions,
    int? objectivesCollected,
    int? objectivesMissed,
    int? lanesCrossed,
    int? livesLost,
  }) {
    return FarmCrossingStats(
      roundsCompleted: roundsCompleted ?? this.roundsCompleted,
      collisions: collisions ?? this.collisions,
      objectivesCollected: objectivesCollected ?? this.objectivesCollected,
      objectivesMissed: objectivesMissed ?? this.objectivesMissed,
      lanesCrossed: lanesCrossed ?? this.lanesCrossed,
      livesLost: livesLost ?? this.livesLost,
    );
  }
}

class FarmCrossingSessionResult {
  const FarmCrossingSessionResult({
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

  final FarmCrossingEndReason endReason;

  final FarmCrossingStats stats;

  final List<FarmCrossingEvent> events;

  bool get completedTarget =>
      endReason == FarmCrossingEndReason.targetCompleted;

  bool get endedByMaxLives => endReason == FarmCrossingEndReason.maxLivesLost;

  double? get averageLaneTimeMs {
    final times = events
        .where(
          (event) =>
              event.type == FarmCrossingEventType.laneCrossed &&
              event.laneTimeMs != null,
        )
        .map((event) => event.laneTimeMs!)
        .toList();

    if (times.isEmpty) return null;

    final sum = times.reduce((a, b) => a + b);

    return sum / times.length;
  }

  String get mainObservation {
    final objectiveTotal = stats.objectivesCollected + stats.objectivesMissed;

    if (objectiveTotal == 0) {
      return 'La sesión no tuvo suficientes objetivos para evaluar el desempeño.';
    }

    final objectiveRate = stats.objectivesCollected / objectiveTotal;

    if (stats.collisions >= 3) {
      return 'Se observaron varias colisiones durante el cruce de los carriles.';
    }

    if (objectiveRate < 0.60) {
      return 'Se observó dificultad para localizar o recoger los objetivos del canal rojo.';
    }

    if (stats.collisions == 0) {
      return 'La sesión se completó sin colisiones y con buen control durante los cruces.';
    }

    return 'La sesión mostró un desempeño general adecuado durante los cruces.';
  }
}
